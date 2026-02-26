import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaidya/features/vitals/presentation/models/vitals_view_data.dart';
import 'package:vaidya/themes/colors.dart';

class VitalEntrySheet extends StatefulWidget {
  final String title;
  final VitalRecordViewData? initialRecord;
  final Future<bool> Function(Map<String, dynamic> payload) onSubmit;

  const VitalEntrySheet({
    super.key,
    required this.title,
    required this.onSubmit,
    this.initialRecord,
  });

  @override
  State<VitalEntrySheet> createState() => _VitalEntrySheetState();
}

class _VitalEntrySheetState extends State<VitalEntrySheet> {
  late final TextEditingController _heartRate;
  late final TextEditingController _systolic;
  late final TextEditingController _diastolic;
  late final TextEditingController _glucose;
  late final TextEditingController _weight;
  late final TextEditingController _height;
  late final TextEditingController _bmi;
  late final TextEditingController _notes;
  DateTime? _recordedAt;

  var _busy = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRecord;
    _heartRate = TextEditingController(text: _initialText(initial?.heartRate));
    _systolic = TextEditingController(text: _initialText(initial?.systolicBp));
    _diastolic = TextEditingController(
      text: _initialText(initial?.diastolicBp),
    );
    _glucose = TextEditingController(text: _initialText(initial?.glucoseLevel));
    _weight = TextEditingController(text: _initialText(initial?.weight));
    _height = TextEditingController(text: _initialText(initial?.height));
    _bmi = TextEditingController(
      text: _initialText(initial?.bmi, fractionDigits: 1),
    );
    _notes = TextEditingController(text: initial?.notes ?? '');
    _recordedAt = initial?.recordedAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _heartRate.dispose();
    _systolic.dispose();
    _diastolic.dispose();
    _glucose.dispose();
    _weight.dispose();
    _height.dispose();
    _bmi.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 720),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _busy ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 620;
                      final fields = <Widget>[
                        _NumberField(
                          label: 'Heart Rate (bpm)',
                          controller: _heartRate,
                        ),
                        _NumberField(
                          label: 'Glucose (mg/dL)',
                          controller: _glucose,
                        ),
                        _NumberField(
                          label: 'Systolic BP (mmHg)',
                          controller: _systolic,
                        ),
                        _NumberField(
                          label: 'Diastolic BP (mmHg)',
                          controller: _diastolic,
                        ),
                        _NumberField(label: 'Weight (kg)', controller: _weight),
                        _NumberField(label: 'Height (cm)', controller: _height),
                        _NumberField(
                          label: 'BMI',
                          controller: _bmi,
                          decimal: true,
                        ),
                        _DateField(
                          label: 'Recorded At',
                          value: _recordedAt,
                          onTap: _busy ? null : _pickDateTime,
                        ),
                      ];

                      return Column(
                        children: [
                          if (wide)
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: fields
                                  .map(
                                    (field) => SizedBox(
                                      width: (constraints.maxWidth - 10) / 2,
                                      child: field,
                                    ),
                                  )
                                  .toList(growable: false),
                            )
                          else
                            Column(
                              children: List.generate(fields.length, (index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == fields.length - 1 ? 0 : 10,
                                  ),
                                  child: fields[index],
                                );
                              }),
                            ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _notes,
                            enabled: !_busy,
                            minLines: 2,
                            maxLines: 4,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            decoration: _inputDecoration('Notes (optional)'),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save reading',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initial = _recordedAt ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 2),
    );

    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (!mounted) return;

    setState(() {
      _recordedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 0,
        time?.minute ?? 0,
      );
    });
  }

  Future<void> _submit() async {
    final payload = _buildPayload();

    if (payload.isEmpty) {
      _show('Enter at least one vital value.', error: true);
      return;
    }

    setState(() => _busy = true);
    final success = await widget.onSubmit(payload);

    if (!mounted) return;
    setState(() => _busy = false);

    if (success) {
      Navigator.of(context).pop();
    }
  }

  Map<String, dynamic> _buildPayload() {
    final payload = <String, dynamic>{};

    void addNum(String key, String raw, {bool decimal = false}) {
      final value = raw.trim();
      if (value.isEmpty || value == '--') return;
      final parsed = decimal ? double.tryParse(value) : int.tryParse(value);
      if (parsed != null) {
        payload[key] = parsed;
      }
    }

    addNum('heartRate', _heartRate.text);
    addNum('glucoseLevel', _glucose.text, decimal: true);
    addNum('systolicBp', _systolic.text);
    addNum('diastolicBp', _diastolic.text);
    addNum('weight', _weight.text, decimal: true);
    addNum('height', _height.text, decimal: true);
    addNum('bmi', _bmi.text, decimal: true);

    final note = _notes.text.trim();
    if (note.isNotEmpty) {
      payload['notes'] = note;
    }

    if (_recordedAt != null) {
      payload['recordedAt'] = _recordedAt!.toIso8601String();
    }

    return payload;
  }

  String _initialText(num? value, {int fractionDigits = 0}) {
    if (value == null) return '';
    if (fractionDigits <= 0 && value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(fractionDigits);
  }

  void _show(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Urbanist'),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? const Color(0xFFDC2626) : null,
        ),
      );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool decimal;

  const _NumberField({
    required this.label,
    required this.controller,
    this.decimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      style: const TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: _inputDecoration(label),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback? onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'Select date & time'
        : DateFormat('MMM d, yyyy hh:mm a').format(value!);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.calendar_month_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: const TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    floatingLabelStyle: const TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: Colors.white,
  );
}
