import 'package:dartz/dartz.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/features/intelligence/domain/entities/intelligence_entity.dart';

abstract interface class IIntelligenceRepository {
  Future<Either<Failure, List<AiInsightEntity>>> generateInsights({
    required String input,
    required int maxItems,
    required bool force,
  });

  Future<Either<Failure, AiChatReplyEntity>> chat({
    required List<Map<String, String>> messages,
    String? doctor,
  });
}
