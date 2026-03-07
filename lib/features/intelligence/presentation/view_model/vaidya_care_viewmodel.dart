import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/features/intelligence/domain/usecases/chat_with_ai_usecase.dart';
import 'package:vaidya/features/intelligence/presentation/models/vaidya_care_doctor_profile.dart';
import 'package:vaidya/features/intelligence/presentation/state/vaidya_care_state.dart';

final vaidyaCareViewModelProvider =
    NotifierProvider<VaidyaCareViewModel, VaidyaCareState>(
      VaidyaCareViewModel.new,
    );

class VaidyaCareViewModel extends Notifier<VaidyaCareState> {
  late final ChatWithAiUsecase _chatWithAiUsecase;

  @override
  VaidyaCareState build() {
    _chatWithAiUsecase = ref.read(chatWithAiUsecaseProvider);
    return VaidyaCareState.initial();
  }

  void updateSearchQuery(String value) {
    final query = value.trim().toLowerCase();
    final filtered = query.isEmpty
        ? state.doctors
        : state.doctors
              .where((doctor) {
                final haystack = [
                  doctor.name,
                  doctor.title,
                  doctor.specialty,
                  ...doctor.tags,
                ].join(' ').toLowerCase();
                return haystack.contains(query);
              })
              .toList(growable: false);

    state = state.copyWith(
      searchQuery: value,
      filteredDoctors: filtered,
      clearError: true,
    );
  }

  void startConsult({String? doctorId}) {
    final doctor = _resolveDoctor(doctorId);
    state = state.copyWith(
      selectedDoctor: doctor,
      messages: const [
        VaidyaCareMessage(
          role: 'assistant',
          content:
              "Hi there! I'm here to help with your health concern. What brings you in today?",
        ),
      ],
      status: VaidyaCareStatus.loaded,
      isThinking: false,
      micOn: true,
      cameraOn: true,
      captionsOn: true,
      shareOn: false,
      clearError: true,
      clearActionMessage: true,
    );
  }

  Future<String?> sendMessage(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || state.isThinking) {
      return null;
    }

    final nextMessages = [
      ...state.messages,
      VaidyaCareMessage(role: 'user', content: trimmed),
    ];

    state = state.copyWith(
      status: VaidyaCareStatus.loading,
      messages: nextMessages,
      isThinking: true,
      clearError: true,
      clearActionMessage: true,
    );

    final payload = nextMessages
        .map((message) => message.toApiPayload())
        .toList(growable: false);
    final requestMessages = payload.length <= 20
        ? payload
        : payload.sublist(payload.length - 20);

    final result = await _chatWithAiUsecase(
      ChatWithAiParams(
        messages: requestMessages,
        doctor: state.selectedDoctor.id,
      ),
    );

    String? reply;
    String? error;

    result.fold((failure) => error = failure.message, (response) {
      final text = response.reply.trim();
      reply = text.isEmpty
          ? "I'm sorry, I couldn't respond right now."
          : response.reply.trim();
    });

    final assistantMessage = VaidyaCareMessage(
      role: 'assistant',
      content: reply ?? 'I ran into an error. Please try again in a moment.',
    );

    state = state.copyWith(
      status: reply != null ? VaidyaCareStatus.loaded : VaidyaCareStatus.error,
      isThinking: false,
      messages: [...state.messages, assistantMessage],
      errorMessage: error,
      actionMessage: reply != null ? 'Response received' : null,
      clearError: reply != null,
    );

    return assistantMessage.content;
  }

  void toggleMic() => state = state.copyWith(micOn: !state.micOn);
  void toggleCamera() => state = state.copyWith(cameraOn: !state.cameraOn);
  void toggleCaptions() =>
      state = state.copyWith(captionsOn: !state.captionsOn);
  void toggleShare() => state = state.copyWith(shareOn: !state.shareOn);

  void clearMessages() {
    state = state.copyWith(clearActionMessage: true, clearError: true);
  }

  VaidyaCareDoctorProfile _resolveDoctor(String? doctorId) {
    if (doctorId == null || doctorId.trim().isEmpty) {
      return state.doctors.first;
    }
    final idx = state.doctors.indexWhere((doctor) => doctor.id == doctorId);
    if (idx == -1) {
      return state.doctors.first;
    }
    return state.doctors[idx];
  }
}
