import 'package:equatable/equatable.dart';

class VitalEntity extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const VitalEntity({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class VitalsSummaryEntity extends Equatable {
  final Map<String, dynamic> data;

  const VitalsSummaryEntity({this.data = const {}});

  @override
  List<Object?> get props => [data];
}
