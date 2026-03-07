import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/intelligence/domain/entities/intelligence_entity.dart';
import 'package:vaidya/features/intelligence/domain/usecases/chat_with_ai_usecase.dart';
import 'package:vaidya/features/intelligence/presentation/state/vaidya_care_state.dart';
import 'package:vaidya/features/intelligence/presentation/view_model/vaidya_care_viewmodel.dart';

class MockChatWithAiUsecase extends Mock implements ChatWithAiUsecase {}

class FakeChatWithAiParams extends Fake implements ChatWithAiParams {}

void main() {
  late MockChatWithAiUsecase mockChatWithAiUsecase;
  late ProviderContainer container;

  const tReply = AiChatReplyEntity(
    reply: 'Please monitor your hydration and rest today.',
    data: {'source': 'ai'},
  );
  const tFailure = ApiFailure(
    message: 'AI service unavailable',
    statusCode: 503,
  );

  setUpAll(() {
    registerFallbackValue(FakeChatWithAiParams());
  });

  setUp(() {
    mockChatWithAiUsecase = MockChatWithAiUsecase();
    container = ProviderContainer(
      overrides: [
        chatWithAiUsecaseProvider.overrideWith((ref) => mockChatWithAiUsecase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('VaidyaCareViewModel', () {
    test('1) build initializes expected default state', () {
      final state = container.read(vaidyaCareViewModelProvider);

      expect(state.status, VaidyaCareStatus.initial);
      expect(state.searchQuery, isEmpty);
      expect(state.doctors, isNotEmpty);
      expect(state.filteredDoctors.length, state.doctors.length);
      expect(state.selectedDoctor.id, state.doctors.first.id);
      expect(state.messages.first.role, 'assistant');
      expect(state.isThinking, isFalse);
    });

    test('2) updateSearchQuery with empty input keeps all doctors', () {
      final notifier = container.read(vaidyaCareViewModelProvider.notifier);

      notifier.updateSearchQuery('');
      final state = container.read(vaidyaCareViewModelProvider);

      expect(state.searchQuery, '');
      expect(state.filteredDoctors.length, state.doctors.length);
    });

    test('3) updateSearchQuery filters doctors by case-insensitive text', () {
      final notifier = container.read(vaidyaCareViewModelProvider.notifier);

      notifier.updateSearchQuery('cardiology');
      final state = container.read(vaidyaCareViewModelProvider);

      expect(state.filteredDoctors, isNotEmpty);
      expect(
        state.filteredDoctors.any((doctor) => doctor.id == 'trishan-wagle'),
        isTrue,
      );
    });

    test('4) updateSearchQuery returns empty list when nothing matches', () {
      final notifier = container.read(vaidyaCareViewModelProvider.notifier);

      notifier.updateSearchQuery('xyz-non-matching-specialty');
      final state = container.read(vaidyaCareViewModelProvider);

      expect(state.filteredDoctors, isEmpty);
    });

    test(
      '5) startConsult selects requested doctor and resets conversation',
      () {
        final notifier = container.read(vaidyaCareViewModelProvider.notifier);

        notifier.startConsult(doctorId: 'trishan-wagle');
        final state = container.read(vaidyaCareViewModelProvider);

        expect(state.selectedDoctor.id, 'trishan-wagle');
        expect(state.messages.length, 1);
        expect(state.messages.first.role, 'assistant');
        expect(state.status, VaidyaCareStatus.loaded);
        expect(state.micOn, isTrue);
        expect(state.cameraOn, isTrue);
        expect(state.captionsOn, isTrue);
        expect(state.shareOn, isFalse);
      },
    );

    test('6) startConsult falls back to first doctor for unknown id', () {
      final notifier = container.read(vaidyaCareViewModelProvider.notifier);
      final firstId = container
          .read(vaidyaCareViewModelProvider)
          .doctors
          .first
          .id;

      notifier.startConsult(doctorId: 'unknown-doctor-id');
      final state = container.read(vaidyaCareViewModelProvider);

      expect(state.selectedDoctor.id, firstId);
    });

    test(
      '7) sendMessage returns null for blank input and does not call usecase',
      () async {
        final notifier = container.read(vaidyaCareViewModelProvider.notifier);

        final result = await notifier.sendMessage('   ');

        expect(result, isNull);
        verifyNever(() => mockChatWithAiUsecase(any()));
      },
    );

    test(
      '8) sendMessage success appends user+assistant and sets action message',
      () async {
        when(
          () => mockChatWithAiUsecase(any()),
        ).thenAnswer((_) async => const Right(tReply));

        final notifier = container.read(vaidyaCareViewModelProvider.notifier);
        final result = await notifier.sendMessage('  I have mild headache  ');
        final state = container.read(vaidyaCareViewModelProvider);

        expect(result, tReply.reply);
        expect(state.status, VaidyaCareStatus.loaded);
        expect(state.isThinking, isFalse);
        expect(state.messages.last.role, 'assistant');
        expect(state.messages.last.content, tReply.reply);
        expect(
          state.messages.any(
            (message) =>
                message.role == 'user' &&
                message.content == 'I have mild headache',
          ),
          isTrue,
        );
        expect(state.actionMessage, 'Response received');
        final capturedCall = verify(() => mockChatWithAiUsecase(captureAny()));
        capturedCall.called(1);
        final captured = capturedCall.captured.single as ChatWithAiParams;
        expect(captured.doctor, state.selectedDoctor.id);
        expect(captured.messages.last['content'], 'I have mild headache');
      },
    );

    test(
      '9) sendMessage failure sets error state and fallback assistant message',
      () async {
        when(
          () => mockChatWithAiUsecase(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        final notifier = container.read(vaidyaCareViewModelProvider.notifier);
        final result = await notifier.sendMessage('Need help');
        final state = container.read(vaidyaCareViewModelProvider);

        expect(result, 'I ran into an error. Please try again in a moment.');
        expect(state.status, VaidyaCareStatus.error);
        expect(state.errorMessage, 'AI service unavailable');
        expect(state.isThinking, isFalse);
        expect(
          state.messages.last.content,
          'I ran into an error. Please try again in a moment.',
        );
      },
    );

    test('10) toggle controls update mic/camera/captions/share flags', () {
      final notifier = container.read(vaidyaCareViewModelProvider.notifier);

      notifier.toggleMic();
      notifier.toggleCamera();
      notifier.toggleCaptions();
      notifier.toggleShare();
      final state = container.read(vaidyaCareViewModelProvider);

      expect(state.micOn, isFalse);
      expect(state.cameraOn, isFalse);
      expect(state.captionsOn, isFalse);
      expect(state.shareOn, isTrue);
    });
  });
}
