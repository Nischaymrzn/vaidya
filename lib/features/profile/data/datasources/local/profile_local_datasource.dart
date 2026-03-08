import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/features/profile/data/datasources/profile_datasource.dart';
import 'package:vaidya/features/profile/data/models/profile_payment_status_api_model.dart';
import 'package:vaidya/features/profile/data/models/profile_payment_status_hive_model.dart';
import 'package:vaidya/features/profile/data/models/profile_user_api_model.dart';
import 'package:vaidya/features/profile/data/models/profile_user_hive_model.dart';

final profileLocalDataSourceProvider = Provider<IProfileLocalDataSource>((ref) {
  return ProfileLocalDataSource(
    saveService: ref.read(featureCacheServiceProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class ProfileLocalDataSource implements IProfileLocalDataSource {
  final FeatureCacheService _cacheService;
  final UserSessionService _userSessionService;

  const ProfileLocalDataSource({
    required FeatureCacheService saveService,
    required UserSessionService userSessionService,
  }) : _cacheService = saveService,
       _userSessionService = userSessionService;

  static const String _userCachePrefix = 'profile_user';
  static const String _paymentCachePrefix = 'profile_payment_status';

  String _withUserSuffix(String prefix) {
    final userId = _userSessionService.getCurrentUserId()?.trim();
    if (userId == null || userId.isEmpty) return prefix;
    return '${prefix}_$userId';
  }

  @override
  Future<void> saveUser(ProfileUserApiModel user) {
    final model = ProfileUserHiveModel.fromApiModel(user);
    return _cacheService.writeMap(
      _withUserSuffix(_userCachePrefix),
      model.toJson(),
    );
  }

  @override
  Future<ProfileUserApiModel?> getUser() async {
    final cached = await _cacheService.readMap(
      _withUserSuffix(_userCachePrefix),
    );
    if (cached == null) return null;
    return ProfileUserHiveModel.fromJson(cached).toApiModel();
  }

  @override
  Future<void> savePaymentStatus(ProfilePaymentStatusApiModel status) {
    final model = ProfilePaymentStatusHiveModel.fromApiModel(status);
    return _cacheService.writeMap(
      _withUserSuffix(_paymentCachePrefix),
      model.toJson(),
    );
  }

  @override
  Future<ProfilePaymentStatusApiModel?> getPaymentStatus() async {
    final cached = await _cacheService.readMap(
      _withUserSuffix(_paymentCachePrefix),
    );
    if (cached == null) return null;
    return ProfilePaymentStatusHiveModel.fromJson(cached).toApiModel();
  }
}
