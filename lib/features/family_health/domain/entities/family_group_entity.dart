import 'package:equatable/equatable.dart';

class FamilyGroupEntity extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const FamilyGroupEntity({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class FamilyGroupSummaryEntity extends Equatable {
  final Map<String, dynamic> data;

  const FamilyGroupSummaryEntity({this.data = const {}});

  @override
  List<Object?> get props => [data];
}

class FamilyInviteEntity extends Equatable {
  final String token;
  final Map<String, dynamic> data;

  const FamilyInviteEntity({required this.token, required this.data});

  @override
  List<Object?> get props => [token, data];
}
