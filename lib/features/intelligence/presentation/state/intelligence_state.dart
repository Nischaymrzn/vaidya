import 'package:equatable/equatable.dart';
import 'package:vaidya/features/intelligence/domain/entities/intelligence_entity.dart';

enum IntelligenceStatus { initial, loading, loaded, error }

class IntelligenceState extends Equatable {
  final IntelligenceStatus status;
  final List<AiInsightEntity> insights;
  final AiChatReplyEntity? lastReply;
  final bool isSubmitting;
  final String? errorMessage;
  final String? actionMessage;

  const IntelligenceState({
    this.status = IntelligenceStatus.initial,
    this.insights = const [],
    this.lastReply,
    this.isSubmitting = false,
    this.errorMessage,
    this.actionMessage,
  });

  IntelligenceState copyWith({
    IntelligenceStatus? status,
    List<AiInsightEntity>? insights,
    AiChatReplyEntity? lastReply,
    bool? isSubmitting,
    String? errorMessage,
    String? actionMessage,
    bool clearReply = false,
    bool clearError = false,
    bool clearActionMessage = false,
  }) {
    return IntelligenceState(
      status: status ?? this.status,
      insights: insights ?? this.insights,
      lastReply: clearReply ? null : lastReply ?? this.lastReply,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      actionMessage:
          clearActionMessage ? null : actionMessage ?? this.actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        insights,
        lastReply,
        isSubmitting,
        errorMessage,
        actionMessage,
      ];
}
