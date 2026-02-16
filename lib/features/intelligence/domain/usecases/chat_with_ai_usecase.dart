import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/intelligence/data/repositories/intelligence_repository.dart';
import 'package:vaidya/features/intelligence/domain/entities/intelligence_entity.dart';
import 'package:vaidya/features/intelligence/domain/repositories/intelligence_repository.dart';

final chatWithAiUsecaseProvider = Provider<ChatWithAiUsecase>((ref) {
  return ChatWithAiUsecase(repository: ref.read(intelligenceRepositoryProvider));
});

class ChatWithAiParams {
  final List<Map<String, String>> messages;
  final String? doctor;

  const ChatWithAiParams({required this.messages, this.doctor});
}

class ChatWithAiUsecase
    implements UsecaseWithParams<AiChatReplyEntity, ChatWithAiParams> {
  final IIntelligenceRepository _repository;

  const ChatWithAiUsecase({required IIntelligenceRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, AiChatReplyEntity>> call(ChatWithAiParams params) {
    return _repository.chat(messages: params.messages, doctor: params.doctor);
  }
}
