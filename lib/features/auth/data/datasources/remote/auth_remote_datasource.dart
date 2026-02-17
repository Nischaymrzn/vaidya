import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _userSessionService = userSessionService,
       _tokenService = tokenService;

  @override
  Future<AuthApiModel?> getCurrentUser() async {
    final token = await _tokenService.getToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await _apiClient.get(ApiEndpoints.currentUser);

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final currentUser = AuthApiModel.fromJson(data);
      await _userSessionService.saveUserSession(
        userId: currentUser.id!,
        email: currentUser.email,
        name: currentUser.name,
        role: currentUser.role,
        number: currentUser.number,
        profilePicture: currentUser.profilePicture,
        isPremium: currentUser.isPremium,
      );

      return currentUser;
    }

    return null;
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
      final token = data['accessToken'] as String?;
      if (token == null || token.isEmpty) {
        return null;
      }

      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        name: user.name,
        role: user.role,
        number: user.number,
        isPremium: user.isPremium,
      );
      await _tokenService.saveToken(token);

      return user;
    }

    return null;
  }

  @override
  Future<String?> getGoogleAccessToken() async {
    if (!_googleInitialized) {
      await _googleSignIn.initialize(
        serverClientId: ApiEndpoints.googleServerClientId,
      );
      _googleInitialized = true;
    }

    late final GoogleSignInAccount account;
    try {
      account = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      throw Exception(e.description ?? 'Google sign in failed');
    }

    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google sign in did not return id token');
    }

    final response = await _apiClient.post(
      ApiEndpoints.googleMobileLogin,
      data: {'idToken': idToken},
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final token = data['accessToken'] as String?;
      if (token == null || token.isEmpty) {
        return null;
      }

      final userJson = data['user'] as Map<String, dynamic>?;
      if (userJson != null) {
        final user = AuthApiModel.fromJson(userJson);
        await _userSessionService.saveUserSession(
          userId: user.id!,
          email: user.email,
          name: user.name,
          role: user.role,
          number: user.number,
          profilePicture: user.profilePicture,
          isPremium: user.isPremium,
        );
      }

      return token;
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
  Future<bool> requestPasswordReset(String email) async {
    final response = await _apiClient.post(
      ApiEndpoints.requestPasswordReset,
      data: {'email': email},
    );
    return response.data['success'] == true;
  }

  @override
  Future<bool> isGoogleLoginConfigured() async {
    final response = await _apiClient.get(ApiEndpoints.googleLoginStatus);
    if (response.data['success'] == true) {
      return response.data['configured'] == true;
    }
    return false;
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
        isPremium: updatedUser.isPremium,
      );
      return updatedUser;
    }

    return null;
  }
}
