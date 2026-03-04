import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaidya/features/symptoms/presentation/models/symptom_view_data.dart';
import 'package:vaidya/themes/colors.dart';

class SymptomFormSheet extends StatefulWidget {
  final String title;
  final String submitLabel;
  final SymptomViewData? initialValue;
  final Future<bool> Function(Map<String, dynamic> payload) onSubmit;

  const SymptomFormSheet({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    this.initialValue,
  });

  @override
  State<SymptomFormSheet> createState() => _SymptomFormSheetState();
}

class _SymptomFormSheetState extends State<SymptomFormSheet> {
  static const _severityOptions = ['Mild', 'Moderate', 'Severe'];
  static const _statusOptions = ['ongoing', 'resolved', 'unknown'];

  late final TextEditingController _symptomsController;
  late final TextEditingController _durationController;
  late final TextEditingController _diagnosisController;
  late final TextEditingController _diseaseController;
  late final TextEditingController _notesController;

  String? _severity;
  String _status = 'ongoing';
  DateTime? _loggedAt;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    _symptomsController = TextEditingController(
      text: (initial?.symptomList ?? const <String>[]).join(', '),
    );
    _durationController = TextEditingController(
      text: initial?.durationDays?.toString() ?? '',
    );
    _diagnosisController = TextEditingController(
      text: initial?.diagnosis ?? '',
    );
    _diseaseController = TextEditingController(text: initial?.disease ?? '');
    _notesController = TextEditingController(text: initial?.notes ?? '');

    final initialSeverity = initial?.severityLabel;
    _severity = _severityOptions.contains(initialSeverity)
        ? initialSeverity
        : null;
    _status = _statusOptions.contains(initial?.status)
        ? initial!.status
        : 'ongoing';
    _loggedAt = initial?.loggedAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _durationController.dispose();
    _diagnosisController.dispose();
    _diseaseController.dispose();
    _notesController.dispose();
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
          constraints: const BoxConstraints(maxHeight: 760),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: _symptomsController,
                        enabled: !_submitting,
                        style: _fieldTextStyle,
                        decoration: _inputDecoration(
                          'Symptoms (comma-separated)',
                          hint: 'Fever, Headache',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _SelectField(
                              label: 'Severity',
                              value: _severity,
                              hint: 'Select severity',
                              items: _severityOptions,
                              onChanged: _submitting
                                  ? null
                                  : (value) =>
                                        setState(() => _severity = value),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SelectField(
                              label: 'Status',
                              value: _status,
                              items: _statusOptions,
                              itemLabelBuilder: (value) =>
                                  '${value[0].toUpperCase()}${value.substring(1)}',
                              onChanged: _submitting
                                  ? null
                                  : (value) => setState(
                                      () => _status = value ?? 'ongoing',
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _durationController,
                              enabled: !_submitting,
                              keyboardType: TextInputType.number,
                              style: _fieldTextStyle,
                              decoration: _inputDecoration(
                                'Duration (days)',
                                hint: '2',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DateField(
                              label: 'Logged at',
                              value: _loggedAt,
                              onTap: _submitting ? null : _pickDateTime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _diagnosisController,
                        enabled: !_submitting,
                        style: _fieldTextStyle,
                        decoration: _inputDecoration(
                          'Diagnosis (optional)',
                          hint: 'Viral infection',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _diseaseController,
                        enabled: !_submitting,
                        style: _fieldTextStyle,
                        decoration: _inputDecoration(
                          'Disease (optional)',
                          hint: 'Common cold',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notesController,
                        enabled: !_submitting,
                        minLines: 3,
                        maxLines: 5,
                        style: _fieldTextStyle,
                        decoration: _inputDecoration(
                          'Notes (optional)',
                          hint:
                              'Symptoms started after exposure to cold weather.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.border),
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
                      onPressed: _submitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.submitLabel,
                              style: const TextStyle(
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

  Future<void> _submit() async {
    final payload = _buildPayload();
    final symptoms =
        payload['symptomList'] as List<String>? ?? const <String>[];
    if (symptoms.isEmpty) {
      _show('Please add at least one symptom.', error: true);
      return;
    }

    setState(() => _submitting = true);
    final success = await widget.onSubmit(payload);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      Navigator.of(context).pop();
    }
  }

  Map<String, dynamic> _buildPayload() {
    final symptomList = _symptomsController.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    final payload = <String, dynamic>{
      'symptomList': symptomList,
      'status': _status,
    };

    final severity = _severity?.trim();
    if (severity != null && severity.isNotEmpty) {
      payload['severity'] = severity;
    }

    final duration = int.tryParse(_durationController.text.trim());
    if (duration != null && duration > 0) {
      payload['durationDays'] = duration;
    }

    void writeIfNotEmpty(String key, String value) {
      final text = value.trim();
      if (text.isNotEmpty) {
        payload[key] = text;
      }
    }

    writeIfNotEmpty('diagnosis', _diagnosisController.text);
    writeIfNotEmpty('disease', _diseaseController.text);
    writeIfNotEmpty('notes', _notesController.text);

    if (_loggedAt != null) {
      payload['loggedAt'] = _loggedAt!.toIso8601String();
    }

    return payload;
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initial = _loggedAt ?? now;
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
      _loggedAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 0,
        time?.minute ?? 0,
      );
    });
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
        ? 'Select date'
        : DateFormat('MMM d, yyyy hh:mm a').format(value!);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  final String label;
  final String? value;
  final String? hint;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final String Function(String value)? itemLabelBuilder;

  const _SelectField({
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.itemLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: _inputDecoration(label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: hint == null
              ? null
              : Text(
                  hint!,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    itemLabelBuilder?.call(item) ?? item,
                    style: _fieldTextStyle,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    floatingLabelStyle: TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
    hintStyle: TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    filled: true,
    fillColor: AppColors.surfaceSoft,
  );
}

final _fieldTextStyle = TextStyle(
  fontFamily: 'Urbanist',
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: AppColors.textPrimary,
);
