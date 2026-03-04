import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/analytics/data/repositories/analytics_repository.dart';
import 'package:vaidya/features/analytics/domain/entities/analytics_summary_entity.dart';
import 'package:vaidya/features/analytics/domain/repositories/analytics_repository.dart';

final getAnalyticsSummaryUsecaseProvider = Provider<GetAnalyticsSummaryUsecase>(
  (ref) => GetAnalyticsSummaryUsecase(
    repository: ref.read(analyticsRepositoryProvider),
  ),
);

class GetAnalyticsSummaryParams extends Equatable {
  final int? months;

  const GetAnalyticsSummaryParams({this.months});

  @override
  List<Object?> get props => [months];
}

class GetAnalyticsSummaryUsecase
    implements
        UsecaseWithParams<AnalyticsSummaryEntity, GetAnalyticsSummaryParams> {
  final IAnalyticsRepository _repository;

  const GetAnalyticsSummaryUsecase({required IAnalyticsRepository repository})
    : _repository = repository;

  @override
  Future<Either<Failure, AnalyticsSummaryEntity>> call(
    GetAnalyticsSummaryParams params,
  ) {
    return _repository.getSummary(months: params.months);
  }
}
