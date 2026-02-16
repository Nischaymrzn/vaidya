class RecordFieldSpec {
  final String key;
  final String label;
  final String? placeholder;

  const RecordFieldSpec({
    required this.key,
    required this.label,
    this.placeholder,
  });
}

class RecordCustomField {
  final String key;
  final String value;

  const RecordCustomField({this.key = '', this.value = ''});

  RecordCustomField copyWith({String? key, String? value}) {
    return RecordCustomField(key: key ?? this.key, value: value ?? this.value);
  }

  bool get isValid => key.trim().isNotEmpty && value.trim().isNotEmpty;
}

const List<String> kDefaultVisitTypes = [
  'Routine',
  'Follow-up',
  'Emergency',
  'Teleconsult',
  'Procedure',
];

const List<String> kRecordTypes = [
  'Visit',
  'Vitals',
  'Diagnosis',
  'Imaging',
  'Prescription',
  'Allergy',
  'Immunization',
];

const List<String> kExtraCategoryOptions = ['Insurance'];

const Map<String, String> _categoryAliases = {
  'visit notes': 'Visit',
  'visits': 'Visit',
  'prescriptions': 'Prescription',
  'allergies': 'Allergy',
  'immunizations': 'Immunization',
};

const Map<String, List<RecordFieldSpec>> kTypeFieldMap = {
  'Vitals': [
    RecordFieldSpec(
      key: 'systolicBp',
      label: 'BP systolic',
      placeholder: '120',
    ),
    RecordFieldSpec(
      key: 'diastolicBp',
      label: 'BP diastolic',
      placeholder: '80',
    ),
    RecordFieldSpec(key: 'heartRate', label: 'Heart rate', placeholder: '72'),
    RecordFieldSpec(
      key: 'glucoseLevel',
      label: 'Glucose level',
      placeholder: '110',
    ),
    RecordFieldSpec(key: 'weight', label: 'Weight (kg)', placeholder: '70'),
    RecordFieldSpec(key: 'height', label: 'Height (cm)', placeholder: '170'),
    RecordFieldSpec(key: 'bmi', label: 'BMI', placeholder: '23.5'),
  ],
  'Diagnosis': [
    RecordFieldSpec(
      key: 'symptomList',
      label: 'Symptoms',
      placeholder: 'fatigue, thirst',
    ),
    RecordFieldSpec(
      key: 'severity',
      label: 'Severity',
      placeholder: 'Mild/Moderate',
    ),
    RecordFieldSpec(
      key: 'status',
      label: 'Symptom status',
      placeholder: 'ongoing/resolved',
    ),
    RecordFieldSpec(
      key: 'durationDays',
      label: 'Duration (days)',
      placeholder: '30',
    ),
    RecordFieldSpec(
      key: 'medicineName',
      label: 'Medication',
      placeholder: 'Metformin',
    ),
    RecordFieldSpec(key: 'dosage', label: 'Dosage', placeholder: '500 mg'),
    RecordFieldSpec(
      key: 'frequency',
      label: 'Frequency',
      placeholder: 'Once daily',
    ),
  ],
  'Imaging': [
    RecordFieldSpec(key: 'modality', label: 'Modality', placeholder: 'X-Ray'),
    RecordFieldSpec(key: 'region', label: 'Body region', placeholder: 'Chest'),
    RecordFieldSpec(key: 'finding', label: 'Finding', placeholder: 'Normal'),
  ],
  'Prescription': [
    RecordFieldSpec(
      key: 'medicineName',
      label: 'Medication',
      placeholder: 'Metformin',
    ),
    RecordFieldSpec(key: 'dosage', label: 'Dosage', placeholder: '500 mg'),
    RecordFieldSpec(
      key: 'frequency',
      label: 'Frequency',
      placeholder: 'Once daily',
    ),
    RecordFieldSpec(
      key: 'durationDays',
      label: 'Duration (days)',
      placeholder: '90',
    ),
    RecordFieldSpec(
      key: 'startDate',
      label: 'Start date',
      placeholder: '2026-02-12',
    ),
    RecordFieldSpec(
      key: 'endDate',
      label: 'End date',
      placeholder: '2026-05-12',
    ),
    RecordFieldSpec(
      key: 'purpose',
      label: 'Purpose',
      placeholder: 'Glucose control',
    ),
    RecordFieldSpec(key: 'notes', label: 'Notes', placeholder: 'After meals'),
  ],
  'Allergy': [
    RecordFieldSpec(key: 'allergen', label: 'Allergen', placeholder: 'Peanuts'),
    RecordFieldSpec(
      key: 'type',
      label: 'Type',
      placeholder: 'food/drug/environmental/other',
    ),
    RecordFieldSpec(key: 'reaction', label: 'Reaction', placeholder: 'Hives'),
    RecordFieldSpec(
      key: 'severity',
      label: 'Severity',
      placeholder: 'mild/moderate/severe',
    ),
    RecordFieldSpec(
      key: 'status',
      label: 'Status',
      placeholder: 'active/resolved',
    ),
    RecordFieldSpec(
      key: 'onsetDate',
      label: 'Onset date',
      placeholder: '2026-02-12',
    ),
    RecordFieldSpec(
      key: 'recordedAt',
      label: 'Recorded at',
      placeholder: '2026-02-12',
    ),
    RecordFieldSpec(
      key: 'notes',
      label: 'Notes',
      placeholder: 'Additional context',
    ),
  ],
  'Immunization': [
    RecordFieldSpec(
      key: 'vaccineName',
      label: 'Vaccine name',
      placeholder: 'Hepatitis B',
    ),
    RecordFieldSpec(key: 'date', label: 'Date', placeholder: '2026-02-12'),
    RecordFieldSpec(key: 'doseNumber', label: 'Dose number', placeholder: '2'),
    RecordFieldSpec(key: 'series', label: 'Series', placeholder: 'Primary'),
    RecordFieldSpec(
      key: 'manufacturer',
      label: 'Manufacturer',
      placeholder: 'GSK',
    ),
    RecordFieldSpec(
      key: 'lotNumber',
      label: 'Lot number',
      placeholder: 'A1B2C3',
    ),
    RecordFieldSpec(key: 'site', label: 'Site', placeholder: 'Left arm'),
    RecordFieldSpec(key: 'route', label: 'Route', placeholder: 'IM'),
    RecordFieldSpec(
      key: 'provider',
      label: 'Provider',
      placeholder: 'City Lab',
    ),
    RecordFieldSpec(
      key: 'nextDue',
      label: 'Next due',
      placeholder: '2026-08-12',
    ),
    RecordFieldSpec(
      key: 'notes',
      label: 'Notes',
      placeholder: 'No adverse events',
    ),
  ],
  'Visit': [
    RecordFieldSpec(
      key: 'reasonForVisit',
      label: 'Reason for visit',
      placeholder: 'Follow-up',
    ),
    RecordFieldSpec(
      key: 'chiefComplaint',
      label: 'Chief complaint',
      placeholder: 'Headache',
    ),
    RecordFieldSpec(
      key: 'symptomList',
      label: 'Symptoms',
      placeholder: 'nausea, dizziness',
    ),
    RecordFieldSpec(
      key: 'severity',
      label: 'Severity',
      placeholder: 'Mild/Moderate',
    ),
    RecordFieldSpec(
      key: 'status',
      label: 'Symptom status',
      placeholder: 'ongoing/resolved',
    ),
    RecordFieldSpec(
      key: 'durationDays',
      label: 'Duration (days)',
      placeholder: '3',
    ),
    RecordFieldSpec(
      key: 'medicineName',
      label: 'Medication',
      placeholder: 'Ibuprofen',
    ),
    RecordFieldSpec(key: 'dosage', label: 'Dosage', placeholder: '200 mg'),
    RecordFieldSpec(
      key: 'frequency',
      label: 'Frequency',
      placeholder: 'Twice daily',
    ),
  ],
};

String normalizeRecordTypeForForm(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return 'Visit';
  for (final candidate in kRecordTypes) {
    if (candidate.toLowerCase() == trimmed.toLowerCase()) {
      return candidate;
    }
  }
  return 'Visit';
}

String normalizeCategoryForForm(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return '';
  final lowered = trimmed.toLowerCase();
  if (_categoryAliases.containsKey(lowered)) return _categoryAliases[lowered]!;
  for (final candidate in [...kRecordTypes, ...kExtraCategoryOptions]) {
    if (candidate.toLowerCase() == lowered) return candidate;
  }
  return trimmed;
}

String formatStructuredValueForForm(dynamic value) {
  if (value == null) return '';
  if (value is List) {
    return value.map((item) => item.toString().trim()).join(', ');
  }
  return value.toString();
}
