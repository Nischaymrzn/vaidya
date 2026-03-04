import 'package:equatable/equatable.dart';

class RiskAssessmentEntity extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const RiskAssessmentEntity({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class RiskAssessmentGenerateEntity extends Equatable {
  final Map<String, dynamic> data;

  const RiskAssessmentGenerateEntity({this.data = const {}});

  @override
  List<Object?> get props => [data];
}
