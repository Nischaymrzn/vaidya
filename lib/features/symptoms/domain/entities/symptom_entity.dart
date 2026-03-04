import 'package:equatable/equatable.dart';

class SymptomEntity extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const SymptomEntity({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class SymptomsSummaryEntity extends Equatable {
  final Map<String, dynamic> data;

  const SymptomsSummaryEntity({this.data = const {}});

  @override
  List<Object?> get props => [data];
}
