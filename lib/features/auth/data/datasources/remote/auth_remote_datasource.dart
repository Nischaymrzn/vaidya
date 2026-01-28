import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/core/services/storage/token_service.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/features/auth/data/datasources/auth_datasource.dart';
import 'package:vaidya/features/auth/data/models/auth_api_model.dart';

// dont use try catch here, if need to handle exceptions then do it in repository
final authRemoteDataSourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel?> getCurrentUser() async {
    try {
      if (!_userSessionService.isLoggedIn()) {
        return null;
      }

      final userId = _userSessionService.getCurrentUserId();
      if (userId == null) {
        return null;
      }

      final response = await _apiClient.get(ApiEndpoints.userById(userId));

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final currentUser = AuthApiModel.fromJson(data);
        await _userSessionService.saveUserSession(
          userId: currentUser.id!,
          email: currentUser.email,
          name: currentUser.name,
          role: currentUser.role,
        );

        return currentUser;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.userLogin,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;

      final userJson = data['user'] as Map<String, dynamic>;
      final user = AuthApiModel.fromJson(userJson);

      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        name: user.name,
        role: user.role,
        number: user.number,
      );
      // Save token to TokenService
      final token = response.data['data']['accessToken'];
      // Later store token in secure storage
      await _tokenService.saveToken(token);

      return user;
    }

    return null;
  }

  @override
  Future<bool> logout() async {
    try {
      await _userSessionService.clearSession();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async {
    final response = await _apiClient.post(
      ApiEndpoints.userRegister,
      data: user.toJson(),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }

    return user;
  }

  @override
  Future<AuthApiModel?> updateProfile(
    String userId, {
    File? image,
    String? name,
    String? email,
    int? number,
  }) async {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (image != null) {
      final filename = image.path.split(RegExp(r'[/\\]')).last;
      map['image'] = await MultipartFile.fromFile(
        image.path,
        filename: filename,
      );
    }
    final formData = FormData.fromMap(map);

    final response = await _apiClient.put(
      ApiEndpoints.updateUser(userId),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final updatedUser = AuthApiModel.fromJson(data);
      await _userSessionService.saveUserSession(
        userId: updatedUser.id!,
        email: updatedUser.email,
        name: updatedUser.name,
        role: updatedUser.role,
        number: updatedUser.number,
        profilePicture: updatedUser.profilePicture,
      );
      return updatedUser;
    }

    return null;
  }
}
