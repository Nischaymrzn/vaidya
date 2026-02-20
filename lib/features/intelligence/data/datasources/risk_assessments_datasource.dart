import 'package:vaidya/features/intelligence/data/models/risk_assessment_api_model.dart';

abstract interface class IRiskAssessmentsRemoteDataSource {
  Future<List<RiskAssessmentApiModel>> getAssessments();
  Future<RiskAssessmentApiModel> getAssessmentById(String id);
  Future<RiskAssessmentGenerateApiModel> generateAssessment(Map<String, dynamic> payload);
}

abstract interface class IRiskAssessmentsLocalDataSource {
  Future<void> cacheAssessments(List<RiskAssessmentApiModel> items);
  Future<List<RiskAssessmentApiModel>> getCachedAssessments();
}
