import 'package:intl/intl.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';

final DateFormat _longDateFormat = DateFormat('MMM dd, yyyy');

DateTime? tryParseDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value.trim());
}

String formatDateLabel(String? value) {
  final parsed = tryParseDate(value);
  if (parsed == null) return 'N/A';
  return _longDateFormat.format(parsed.toLocal());
}

String normalizeCategoryLabel(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return 'Other';
  final lowered = trimmed.toLowerCase();
  const aliasMap = <String, String>{
    'visit notes': 'Visit',
    'visits': 'Visit',
    'prescriptions': 'Prescription',
    'allergies': 'Allergy',
    'immunizations': 'Immunization',
  };
  if (aliasMap.containsKey(lowered)) return aliasMap[lowered]!;
  return trimmed;
}

String buildFileProxyUrl({
  required String fileUrl,
  bool download = false,
  String? name,
}) {
  final query = <String, String>{
    'url': fileUrl,
    if (download) 'download': '1',
    if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
  };

  final base = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.files}');
  return base.replace(queryParameters: query).toString();
}

int recordYear(MedicalRecordEntity record) {
  final date = tryParseDate(record.effectiveDate);
  return date?.toLocal().year ?? DateTime.now().year;
}

