import 'package:equatable/equatable.dart';

class PredictionEntity extends Equatable {
  final String type;
  final Map<String, dynamic> data;

  const PredictionEntity({required this.type, required this.data});

  @override
  List<Object?> get props => [type, data];
}
