class MedicalRecordDomainPayloadBuilder {
  const MedicalRecordDomainPayloadBuilder._();

  static Map<String, dynamic> build({
    required String recordType,
    required Map<String, String> structured,
    required String? recordDate,
  }) {
    final payload = <String, dynamic>{};
    final normalizedType = recordType.trim();
    final trimmedDate = recordDate?.trim();

    void setIf(Map<String, dynamic> target, String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      target[key] = value;
    }

    bool hasAny(Map<String, dynamic> target) => target.isNotEmpty;

    final vitals = <String, dynamic>{};
    setIf(vitals, 'systolicBp', _parseNumber(structured['systolicBp']));
    setIf(vitals, 'diastolicBp', _parseNumber(structured['diastolicBp']));
    setIf(vitals, 'heartRate', _parseNumber(structured['heartRate']));
    setIf(vitals, 'glucoseLevel', _parseNumber(structured['glucoseLevel']));
    setIf(vitals, 'weight', _parseNumber(structured['weight']));
    setIf(vitals, 'height', _parseNumber(structured['height']));
    setIf(vitals, 'bmi', _parseNumber(structured['bmi']));
    if (trimmedDate != null && trimmedDate.isNotEmpty && hasAny(vitals)) {
      setIf(vitals, 'recordedAt', trimmedDate);
    }

    final medications = <String, dynamic>{};
    setIf(medications, 'medicineName', structured['medicineName']?.trim());
    setIf(medications, 'dosage', structured['dosage']?.trim());
    setIf(medications, 'frequency', structured['frequency']?.trim());
    setIf(
      medications,
      'durationDays',
      _parseNumber(structured['durationDays']),
    );
    setIf(
      medications,
      'startDate',
      structured['startDate']?.trim() ??
          (normalizedType == 'Prescription' ? trimmedDate : null),
    );
    setIf(medications, 'endDate', structured['endDate']?.trim());
    setIf(medications, 'purpose', structured['purpose']?.trim());
    setIf(medications, 'notes', structured['notes']?.trim());
    setIf(medications, 'diagnosis', structured['diagnosis']?.trim());
    setIf(medications, 'disease', structured['disease']?.trim());

    final symptoms = <String, dynamic>{};
    setIf(
      symptoms,
      'symptomList',
      _parseSymptomList(structured['symptomList']),
    );
    setIf(symptoms, 'severity', structured['severity']?.trim());
    setIf(symptoms, 'durationDays', _parseNumber(structured['durationDays']));
    setIf(symptoms, 'notes', structured['notes']?.trim());
    setIf(symptoms, 'diagnosis', structured['diagnosis']?.trim());
    setIf(symptoms, 'disease', structured['disease']?.trim());
    if (trimmedDate != null && trimmedDate.isNotEmpty && hasAny(symptoms)) {
      setIf(symptoms, 'loggedAt', trimmedDate);
    }

    final allergies = <String, dynamic>{};
    setIf(allergies, 'allergen', structured['allergen']?.trim());
    setIf(allergies, 'type', structured['type']?.trim());
    setIf(allergies, 'reaction', structured['reaction']?.trim());
    setIf(allergies, 'severity', structured['severity']?.trim());
    setIf(allergies, 'status', structured['status']?.trim());
    setIf(
      allergies,
      'onsetDate',
      structured['onsetDate']?.trim() ?? trimmedDate,
    );
    setIf(
      allergies,
      'recordedAt',
      structured['recordedAt']?.trim() ?? trimmedDate,
    );
    setIf(allergies, 'notes', structured['notes']?.trim());

    final immunizations = <String, dynamic>{};
    setIf(immunizations, 'vaccineName', structured['vaccineName']?.trim());
    setIf(immunizations, 'date', structured['date']?.trim() ?? trimmedDate);
    setIf(immunizations, 'doseNumber', _parseNumber(structured['doseNumber']));
    setIf(immunizations, 'series', structured['series']?.trim());
    setIf(immunizations, 'manufacturer', structured['manufacturer']?.trim());
    setIf(immunizations, 'lotNumber', structured['lotNumber']?.trim());
    setIf(immunizations, 'site', structured['site']?.trim());
    setIf(immunizations, 'route', structured['route']?.trim());
    setIf(immunizations, 'provider', structured['provider']?.trim());
    setIf(immunizations, 'nextDue', structured['nextDue']?.trim());
    setIf(immunizations, 'notes', structured['notes']?.trim());

    if (normalizedType == 'Vitals' && hasAny(vitals)) {
      payload['vitals'] = vitals;
    }
    if (normalizedType == 'Prescription' && hasAny(medications)) {
      payload['medications'] = medications;
    }
    if ((normalizedType == 'Diagnosis' || normalizedType == 'Visit') &&
        hasAny(symptoms)) {
      payload['symptoms'] = symptoms;
    }
    if (normalizedType == 'Allergy' && hasAny(allergies)) {
      payload['allergies'] = allergies;
    }
    if (normalizedType == 'Immunization' && hasAny(immunizations)) {
      payload['immunizations'] = immunizations;
    }

    return payload;
  }

  static num? _parseNumber(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    return num.tryParse(raw);
  }

  static List<String>? _parseSymptomList(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    final result = raw
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    return result.isEmpty ? null : result;
  }
}
