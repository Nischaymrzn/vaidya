import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? username;
  final String? password;
  final String? profilePicture;

  const AuthEntity({
    this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.username,
    this.password,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [
    userId,
    fullName,
    email,
    phoneNumber,
    username,
    password,
    profilePicture,
  ];
}
