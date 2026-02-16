import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/error/failures.dart';
import 'package:vaidya/core/usecases/app_usecase.dart';
import 'package:vaidya/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:vaidya/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vaidya/features/dashboard/domain/repositories/dashboard_repository.dart';

final getDashboardSummaryUsecaseProvider = Provider<GetDashboardSummaryUsecase>(
  (ref) {
    final dashboardRepository = ref.read(dashboardRepositoryProvider);
    return GetDashboardSummaryUsecase(dashboardRepository: dashboardRepository);
  },
);

class GetDashboardSummaryUsecase
    implements UsecaseWithoutParams<DashboardSummaryEntity> {
  final IDashboardRepository _dashboardRepository;

  GetDashboardSummaryUsecase({
    required IDashboardRepository dashboardRepository,
  }) : _dashboardRepository = dashboardRepository;

  @override
  Future<Either<Failure, DashboardSummaryEntity>> call() {
    return _dashboardRepository.getDashboardSummary();
  }
}
