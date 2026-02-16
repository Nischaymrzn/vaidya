import 'package:equatable/equatable.dart';

class UserDataEntity extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const UserDataEntity({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}
