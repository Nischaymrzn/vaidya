import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String name;
  final String email;
  final String? number;
  final String? role;
  final bool? isPremium;
  final String? password;
  final String? profilePicture;

  const AuthEntity({
    this.userId,
    required this.name,
    required this.email,
    this.number,
    this.role,
    this.isPremium,
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
    isPremium,
    password,
    profilePicture,
  ];
}
