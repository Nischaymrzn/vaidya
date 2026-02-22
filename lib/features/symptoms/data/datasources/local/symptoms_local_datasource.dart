import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/symptoms/data/datasources/symptoms_datasource.dart';
import 'package:vaidya/features/symptoms/data/models/symptom_api_model.dart';
import 'package:vaidya/features/symptoms/data/models/symptom_hive_model.dart';

final symptomsLocalDataSourceProvider = Provider<ISymptomsLocalDataSource>((ref) {
  return SymptomsLocalDataSource(cacheService: ref.read(featureCacheServiceProvider));
});

class SymptomsLocalDataSource implements ISymptomsLocalDataSource {
  final FeatureCacheService _cacheService;

  const SymptomsLocalDataSource({required FeatureCacheService cacheService})
      : _cacheService = cacheService;

  static const String _itemsKey = 'symptoms_items';
  static const String _summaryKey = 'symptoms_summary';

  @override
  Future<void> cacheSymptoms(List<SymptomApiModel> items) {
    final encoded = items
        .map((item) => SymptomHiveModel.fromApiModel(item).toJson())
        .toList(growable: false);
    return _cacheService.writeList(_itemsKey, encoded);
  }

  @override
  Future<List<SymptomApiModel>> getCachedSymptoms() async {
    final cached = await _cacheService.readList(_itemsKey);
    return cached
        .map((item) => SymptomHiveModel.fromJson(item).toApiModel())
        .toList(growable: false);
  }

  @override
  Future<SymptomApiModel?> getCachedSymptomById(String id) async {
    final cached = await getCachedSymptoms();
    for (final item in cached) {
      if (_sameId(item.data, id)) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<SymptomApiModel> upsertSymptom(SymptomApiModel payload) async {
    final normalized = payload.data;
    final id = _idOf(normalized);
    if (id.isEmpty) {
      return payload;
    }

    final cached = await getCachedSymptoms();
    final updated = List<SymptomApiModel>.from(cached);
    final index = updated.indexWhere((item) => _sameId(item.data, id));

    if (index >= 0) {
      updated[index] = payload;
    } else {
      updated.insert(0, payload);
    }

    await cacheSymptoms(updated);
    return payload;
  }

  @override
  Future<bool> removeSymptomById(String id) async {
    final cached = await getCachedSymptoms();
    final updated = cached
        .where((item) => !_sameId(item.data, id))
        .toList(growable: false);
    if (updated.length == cached.length) {
      return false;
    }
    await cacheSymptoms(updated);
    return true;
  }

  @override
  Future<void> cacheSymptomsSummary(Map<String, dynamic> payload) {
    final model = SymptomsSummaryHiveModel.fromJson(payload);
    return _cacheService.writeMap(_summaryKey, model.toJson());
  }

  @override
  Future<Map<String, dynamic>?> getCachedSymptomsSummary() async {
    final cached = await _cacheService.readMap(_summaryKey);
    if (cached == null) return null;
    return SymptomsSummaryHiveModel.fromJson(cached).toJson();
  }

  String _idOf(Map<String, dynamic> item) {
    final value = item['_id'] ?? item['id'];
    return value?.toString().trim() ?? '';
  }

  bool _sameId(Map<String, dynamic> item, String id) {
    return _idOf(item) == id.trim();
  }
}
