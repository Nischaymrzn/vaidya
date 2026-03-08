import 'package:equatable/equatable.dart';
import 'package:vaidya/features/intelligence/presentation/models/vaidya_care_doctor_profile.dart';

enum VaidyaCareStatus { initial, loading, loaded, error }

class VaidyaCareMessage extends Equatable {
  final String role;
  final String content;

  const VaidyaCareMessage({required this.role, required this.content});

  bool get isUser => role == 'user';

  Map<String, String> toApiPayload() => {'role': role, 'content': content};

  @override
  List<Object?> get props => [role, content];
}

class VaidyaCareState extends Equatable {
  final VaidyaCareStatus status;
  final String searchQuery;
  final List<VaidyaCareDoctorProfile> doctors;
  final List<VaidyaCareDoctorProfile> filteredDoctors;
  final VaidyaCareDoctorProfile selectedDoctor;
  final List<VaidyaCareMessage> messages;
  final bool isThinking;
  final bool micOn;
  final bool cameraOn;
  final bool captionsOn;
  final bool shareOn;
  final String? errorMessage;
  final String? actionMessage;

  const VaidyaCareState({
    required this.status,
    required this.searchQuery,
    required this.doctors,
    required this.filteredDoctors,
    required this.selectedDoctor,
    required this.messages,
    required this.isThinking,
    required this.micOn,
    required this.cameraOn,
    required this.captionsOn,
    required this.shareOn,
    this.errorMessage,
    this.actionMessage,
  });

  factory VaidyaCareState.initial() {
    final doctors = VaidyaCareDoctorProfile.catalog;
    return VaidyaCareState(
      status: VaidyaCareStatus.initial,
      searchQuery: '',
      doctors: doctors,
      filteredDoctors: doctors,
      selectedDoctor: doctors.first,
      messages: const [
        VaidyaCareMessage(
          role: 'assistant',
          content:
              "Hi there! I'm here to help with your health concern. What brings you in today?",
        ),
      ],
      isThinking: false,
      micOn: true,
      cameraOn: true,
      captionsOn: true,
      shareOn: false,
    );
  }

  VaidyaCareState copyWith({
    VaidyaCareStatus? status,
    String? searchQuery,
    List<VaidyaCareDoctorProfile>? doctors,
    List<VaidyaCareDoctorProfile>? filteredDoctors,
    VaidyaCareDoctorProfile? selectedDoctor,
    List<VaidyaCareMessage>? messages,
    bool? isThinking,
    bool? micOn,
    bool? cameraOn,
    bool? captionsOn,
    bool? shareOn,
    String? errorMessage,
    String? actionMessage,
    bool clearError = false,
    bool clearActionMessage = false,
  }) {
    return VaidyaCareState(
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
      doctors: doctors ?? this.doctors,
      filteredDoctors: filteredDoctors ?? this.filteredDoctors,
      selectedDoctor: selectedDoctor ?? this.selectedDoctor,
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      micOn: micOn ?? this.micOn,
      cameraOn: cameraOn ?? this.cameraOn,
      captionsOn: captionsOn ?? this.captionsOn,
      shareOn: shareOn ?? this.shareOn,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    searchQuery,
    doctors,
    filteredDoctors,
    selectedDoctor,
    messages,
    isThinking,
    micOn,
    cameraOn,
    captionsOn,
    shareOn,
    errorMessage,
    actionMessage,
  ];
}
