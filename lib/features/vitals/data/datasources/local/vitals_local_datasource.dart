import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/hive/feature_cache_service.dart';
import 'package:vaidya/features/vitals/data/datasources/vitals_datasource.dart';
import 'package:vaidya/features/vitals/data/models/vital_api_model.dart';
import 'package:vaidya/features/vitals/data/models/vital_hive_model.dart';

final vitalsLocalDataSourceProvider = Provider<IVitalsLocalDataSource>((ref) {
  return VitalsLocalDataSource(
    saveService: ref.read(featureCacheServiceProvider),
  );
});

class VitalsLocalDataSource implements IVitalsLocalDataSource {
  final FeatureCacheService _cacheService;

  const VitalsLocalDataSource({required FeatureCacheService saveService})
    : _cacheService = saveService;

  static const String _itemsKey = 'vitals_items';
  static const String _summaryKey = 'vitals_summary';

  @override
  Future<void> saveVitals(List<VitalApiModel> items) {
    final encoded = items
        .map((item) => VitalHiveModel.fromApiModel(item).toJson())
        .toList(growable: false);
    return _cacheService.writeList(_itemsKey, encoded);
  }

  @override
  Future<List<VitalApiModel>> getVitals() async {
    final cached = await _cacheService.readList(_itemsKey);
    return cached
        .map((item) => VitalHiveModel.fromJson(item).toApiModel())
        .toList(growable: false);
  }

  @override
  Future<VitalApiModel?> getVitalById(String id) async {
    final cached = await getVitals();
    for (final item in cached) {
      if (_sameId(item.data, id)) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<VitalApiModel> upsertVital(VitalApiModel payload) async {
    final normalized = payload.data;
    final id = _idOf(normalized);
    if (id.isEmpty) {
      return payload;
    }

    final cached = await getVitals();
    final updated = List<VitalApiModel>.from(cached);
    final index = updated.indexWhere((item) => _sameId(item.data, id));

    if (index >= 0) {
      updated[index] = payload;
    } else {
      updated.insert(0, payload);
    }

    await saveVitals(updated);
    return payload;
  }

  @override
  Future<bool> removeVitalById(String id) async {
    final cached = await getVitals();
    final updated = cached
        .where((item) => !_sameId(item.data, id))
        .toList(growable: false);
    if (updated.length == cached.length) {
      return false;
    }
    await saveVitals(updated);
    return true;
  }

  @override
  Future<void> saveVitalsSummary(Map<String, dynamic> data) {
    final model = VitalsSummaryHiveModel.fromJson(data);
    return _cacheService.writeMap(_summaryKey, model.toJson());
  }

  @override
  Future<Map<String, dynamic>?> getVitalsSummary() async {
    final cached = await _cacheService.readMap(_summaryKey);
    if (cached == null) return null;
    return VitalsSummaryHiveModel.fromJson(cached).toJson();
  }

  String _idOf(Map<String, dynamic> item) {
    final value = item['_id'] ?? item['id'];
    return value?.toString().trim() ?? '';
  }

  bool _sameId(Map<String, dynamic> item, String id) {
    return _idOf(item) == id.trim();
  }
}
