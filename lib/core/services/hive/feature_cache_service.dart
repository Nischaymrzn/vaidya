import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';

final featureCacheServiceProvider = Provider<FeatureCacheService>((ref) {
  return FeatureCacheService(userSessionService: ref.read(userSessionServiceProvider));
});

class FeatureCacheService {
  final UserSessionService _userSessionService;

  static const String _boxName = 'feature_cache';

  const FeatureCacheService({required UserSessionService userSessionService})
      : _userSessionService = userSessionService;

  Future<Box<String>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }
    return Hive.openBox<String>(_boxName);
  }

  String _scopedKey(String key) {
    final userId = _userSessionService.getCurrentUserId()?.trim();
    if (userId != null && userId.isNotEmpty) {
      return 'u:$userId:$key';
    }

    final email = _userSessionService.getCurrentUserEmail()?.trim().toLowerCase();
    if (email != null && email.isNotEmpty) {
      return 'e:$email:$key';
    }

    return 'guest:$key';
  }

  Future<void> writeMap(String key, Map<String, dynamic> value) async {
    final box = await _getBox();
    await box.put(_scopedKey(key), jsonEncode(value));
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) async {
    final box = await _getBox();
    await box.put(_scopedKey(key), jsonEncode(value));
  }

  Future<Map<String, dynamic>?> readMap(String key) async {
    final box = await _getBox();
    final raw = box.get(_scopedKey(key));
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  Future<List<Map<String, dynamic>>> readList(String key) async {
    final box = await _getBox();
    final raw = box.get(_scopedKey(key));
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
        .toList(growable: false);
  }

  Future<void> remove(String key) async {
    final box = await _getBox();
    await box.delete(_scopedKey(key));
  }
}
