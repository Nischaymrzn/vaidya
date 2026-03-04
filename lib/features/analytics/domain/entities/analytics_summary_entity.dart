import 'package:equatable/equatable.dart';

class AnalyticsSummaryEntity extends Equatable {
  final Map<String, dynamic> data;

  const AnalyticsSummaryEntity({this.data = const {}});

  @override
  List<Object?> get props => [data];
}
