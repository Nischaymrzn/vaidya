import 'package:vaidya/features/dashboard/data/models/dashboard_summary_api_model.dart';

abstract interface class IDashboardRemoteDataSource {
  Future<DashboardSummaryApiModel> getDashboardSummary();
}

abstract interface class IDashboardLocalDataSource {
  Future<void> saveDashboardSummary(DashboardSummaryApiModel data);
  Future<DashboardSummaryApiModel?> getDashboardSummary();
}
