import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/intelligence/data/repositories/intelligence_repository.dart';
import 'package:vaidya/features/intelligence/domain/entities/intelligence_entity.dart';
import 'package:vaidya/features/intelligence/domain/repositories/intelligence_repository.dart';

final generateAiInsightsUsecaseProvider = Provider<GenerateAiInsightsUsecase>((ref) {
  return GenerateAiInsightsUsecase(repository: ref.read(intelligenceRepositoryProvider));
});

class GenerateAiInsightsParams {
  final String input;
  final int maxItems;
  final bool force;

  const GenerateAiInsightsParams({
    required this.input,
    this.maxItems = 3,
    this.force = false,
  });
}

class GenerateAiInsightsUsecase
    implements UsecaseWithParams<List<AiInsightEntity>, GenerateAiInsightsParams> {
  final IIntelligenceRepository _repository;

  const GenerateAiInsightsUsecase({required IIntelligenceRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, List<AiInsightEntity>>> call(GenerateAiInsightsParams params) {
    return _repository.generateInsights(
      input: params.input,
      maxItems: params.maxItems,
      force: params.force,
    );
  }
}
