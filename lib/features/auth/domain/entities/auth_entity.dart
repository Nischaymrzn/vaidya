import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String name;
  final String email;
  final int? number;
  final String? role;
  final String? password;
  final String? profilePicture;

  const AuthEntity({
    this.userId,
    required this.name,
    required this.email,
    this.number,
    this.role,
    this.password,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    userId,
    name,
    email,
    number,
    role,
    password,
    profilePicture,
  ];
}
