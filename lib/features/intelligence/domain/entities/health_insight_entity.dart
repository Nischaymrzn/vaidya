import 'package:equatable/equatable.dart';

class HealthInsightEntity extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const HealthInsightEntity({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}
