import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/features/intelligence/domain/usecases/chat_with_ai_usecase.dart';
import 'package:vaidya/features/intelligence/domain/usecases/generate_ai_insights_usecase.dart';
import 'package:vaidya/features/intelligence/presentation/state/intelligence_state.dart';

final intelligenceViewModelProvider =
    NotifierProvider<IntelligenceViewModel, IntelligenceState>(
      IntelligenceViewModel.new,
    );

class IntelligenceViewModel extends Notifier<IntelligenceState> {
  late final GenerateAiInsightsUsecase _generateAiInsightsUsecase;
  late final ChatWithAiUsecase _chatWithAiUsecase;

  @override
  IntelligenceState build() {
    _generateAiInsightsUsecase = ref.read(generateAiInsightsUsecaseProvider);
    _chatWithAiUsecase = ref.read(chatWithAiUsecaseProvider);
    return const IntelligenceState();
  }

  Future<bool> generateInsights({
    required String input,
    int maxItems = 3,
    bool force = false,
  }) async {
    state = state.copyWith(
      status: IntelligenceStatus.loading,
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
    );

    final result = await _generateAiInsightsUsecase(
      GenerateAiInsightsParams(input: input, maxItems: maxItems, force: force),
    );

    bool ok = false;
    String? message;

    result.fold(
      (failure) => message = failure.message,
      (insights) {
        ok = true;
        state = state.copyWith(insights: insights, status: IntelligenceStatus.loaded);
      },
    );

    if (!ok) {
      state = state.copyWith(
        status: IntelligenceStatus.error,
        isSubmitting: false,
        errorMessage: message ?? 'Failed to generate insights',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'AI insights generated successfully',
      clearError: true,
    );
    return true;
  }

  Future<bool> chat({
    required List<Map<String, String>> messages,
    String? doctor,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearActionMessage: true,
      clearReply: true,
    );

    final result = await _chatWithAiUsecase(
      ChatWithAiParams(messages: messages, doctor: doctor),
    );

    bool ok = false;
    String? message;

    result.fold(
      (failure) => message = failure.message,
      (reply) {
        ok = true;
        state = state.copyWith(lastReply: reply, status: IntelligenceStatus.loaded);
      },
    );

    if (!ok) {
      state = state.copyWith(
        isSubmitting: false,
        status: IntelligenceStatus.error,
        errorMessage: message ?? 'Failed to get AI reply',
      );
      return false;
    }

    state = state.copyWith(
      isSubmitting: false,
      actionMessage: 'AI reply received',
      clearError: true,
    );
    return true;
  }

  void clearMessages() {
    state = state.copyWith(
      clearError: true,
      clearActionMessage: true,
    );
  }
}
