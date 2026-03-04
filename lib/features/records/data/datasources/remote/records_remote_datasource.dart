import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/api/api_client.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/records/data/datasources/records_datasource.dart';
import 'package:vaidya/features/records/data/models/medical_record_api_model.dart';
import 'package:vaidya/features/records/data/models/medical_record_upsert_api_model.dart';

final recordsRemoteDataSourceProvider = Provider<IRecordsRemoteDataSource>((
  ref,
) {
  return RecordsRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

class RecordsRemoteDataSource implements IRecordsRemoteDataSource {
  final ApiClient _apiClient;

  RecordsRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<MedicalRecordsResultApiModel> getMedicalRecords({
    required int page,
    required int limit,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.medicalRecords,
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.data['success'] == true) {
      final payload = response.data as Map<String, dynamic>;
      return MedicalRecordsResultApiModel.fromResponse(payload);
    }

    throw Exception(
      response.data['message'] ?? 'Failed to fetch medical records',
    );
  }

  @override
  Future<MedicalRecordApiModel> getMedicalRecordById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.medicalRecordById(id));

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return MedicalRecordApiModel.fromJson(data);
    }

    throw Exception(
      response.data['message'] ?? 'Failed to fetch medical record',
    );
  }

  @override
  Future<MedicalRecordApiModel> createMedicalRecord(
    MedicalRecordUpsertApiModel payload,
  ) async {
    final formData = await payload.toFormData();
    final response = await _apiClient.post(
      ApiEndpoints.medicalRecords,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return MedicalRecordApiModel.fromJson(data);
    }

    throw Exception(response.data['message'] ?? 'Failed to create record');
  }

  @override
  Future<MedicalRecordApiModel> updateMedicalRecord(
    String id,
    MedicalRecordUpsertApiModel payload,
  ) async {
    final formData = await payload.toFormData();
    final response = await _apiClient.patch(
      ApiEndpoints.medicalRecordById(id),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      return MedicalRecordApiModel.fromJson(data);
    }

    throw Exception(response.data['message'] ?? 'Failed to update record');
  }

  @override
  Future<void> deleteMedicalRecord(String id) async {
    final response = await _apiClient.delete(
      ApiEndpoints.medicalRecordById(id),
    );
    if (response.data['success'] == true) {
      return;
    }
    throw Exception(response.data['message'] ?? 'Failed to delete record');
  }

  @override
  Future<AiScanResultApiModel> scanMedicalImage(String imagePath) async {
    final filename = imagePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath, filename: filename),
    });

    final response = await _apiClient.post(
      ApiEndpoints.aiScan,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.data['success'] == true) {
      final data =
          (response.data['data'] as Map<String, dynamic>? ??
          <String, dynamic>{});
      return AiScanResultApiModel.fromJson(data);
    }

    throw Exception(response.data['message'] ?? 'Failed to scan image');
  }
}

