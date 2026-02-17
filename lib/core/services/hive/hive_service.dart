import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:vaidya/core/constants/hive_table_constant.dart';
import 'package:vaidya/features/auth/data/models/auth_hive_model.dart';
import 'package:vaidya/features/family_health/data/models/family_group_hive_model.dart';
import 'package:vaidya/features/records/data/models/medical_record_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);

    _registerAdapters();
    await _openBoxes();
  }

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.recordAttachmentTypeId)) {
      Hive.registerAdapter(MedicalRecordAttachmentHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.recordsTypeId)) {
      Hive.registerAdapter(MedicalRecordHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.recordsPaginationTypeId)) {
      Hive.registerAdapter(MedicalRecordsPaginationHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.recordsResultTypeId)) {
      Hive.registerAdapter(MedicalRecordsResultHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.aiScanResultTypeId)) {
      Hive.registerAdapter(AiScanResultHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.familyGroupTypeId)) {
      Hive.registerAdapter(FamilyGroupHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.familyGroupSummaryTypeId)) {
      Hive.registerAdapter(FamilyGroupSummaryHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTableConstant.familyInviteTypeId)) {
      Hive.registerAdapter(FamilyInviteHiveModelAdapter());
    }
  }

  Future<void> _openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
    await Hive.openBox<String>('feature_cache');
  }

  Future<void> close() async {
    await Hive.close();
  }

  // ====================Authentication Queries=====================
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  Future<AuthHiveModel> register(AuthHiveModel user) async {
    await _authBox.put(user.userId, user);
    return user;
  }

  AuthHiveModel? login(String email, String password) {
    try {
      return _authBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {}

  AuthHiveModel? getCurrentUser() {
    return null;
  }

  AuthHiveModel? getUserById(String userId) {
    return _authBox.get(userId);
  }

  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.userId)) {
      await _authBox.put(user.userId, user);
      return true;
    }
    return false;
  }

  Future<void> deleteUser(String userId) async {
    await _authBox.delete(userId);
  }

  bool doesEmailExist(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    bool emailExists = users.isNotEmpty;
    return emailExists;
  }
}
