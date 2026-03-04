import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final featureCacheServiceProvider = Provider<FeatureCacheService>((ref) {
  return FeatureCacheService();
});

class FeatureCacheService {
  static const String _boxName = 'feature_cache';

  Future<Box<String>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }
    return Hive.openBox<String>(_boxName);
  }

  Future<void> writeMap(String key, Map<String, dynamic> value) async {
    final box = await _getBox();
    await box.put(key, jsonEncode(value));
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) async {
    final box = await _getBox();
    await box.put(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> readMap(String key) async {
    final box = await _getBox();
    final raw = box.get(key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  Future<List<Map<String, dynamic>>> readList(String key) async {
    final box = await _getBox();
    final raw = box.get(key);
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
    await box.delete(key);
  }
}
