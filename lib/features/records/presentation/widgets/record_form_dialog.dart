import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/themes/colors.dart';

class RecordFormDialog extends StatefulWidget {
  final MedicalRecordEntity? initialRecord;
  final AiScanResultEntity? scanResult;
  final String? scannedImagePath;
  final bool isSubmitting;

  const RecordFormDialog({
    super.key,
    this.initialRecord,
    this.scanResult,
    this.scannedImagePath,
    required this.isSubmitting,
  });

  @override
  State<RecordFormDialog> createState() => _RecordFormDialogState();
}

class _RecordFormDialogState extends State<RecordFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _providerController;
  late final TextEditingController _dateController;
  late final TextEditingController _diagnosisController;
  late final TextEditingController _notesController;
  late final TextEditingController _contentController;
  late final TextEditingController _visitTypeController;
  String _recordType = 'Visit';
  String _category = 'Visit';

  static const List<String> _recordTypes = [
    'Visit',
    'Vitals',
    'Diagnosis',
    'Imaging',
    'Prescription',
    'Allergy',
    'Immunization',
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialRecord;
    final scan = widget.scanResult;
    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

    _recordType = _normalizeChoice(
      candidate: initial?.recordType ?? scan?.recordType,
      fallback: 'Visit',
    );
    _category = _normalizeChoice(
      candidate: initial?.category ?? scan?.recordType,
      fallback: _recordType,
    );

    _titleController = TextEditingController(
      text: initial?.title ?? scan?.summary ?? '',
    );
    _providerController = TextEditingController(
      text: initial?.provider ?? scan?.provider ?? '',
    );
    _dateController = TextEditingController(
      text: _normalizeDate(initial?.recordDate ?? scan?.recordDate) ?? now,
    );
    _diagnosisController = TextEditingController(
      text: initial?.diagnosis ?? '',
    );
    _notesController = TextEditingController(
      text: initial?.notes ?? scan?.text ?? '',
    );
    _contentController = TextEditingController(text: initial?.content ?? '');
    _visitTypeController = TextEditingController(
      text: initial?.visitType ?? 'Routine',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _providerController.dispose();
    _dateController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    _contentController.dispose();
    _visitTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialRecord != null;

    return AlertDialog(
      backgroundColor: AppColors.card,
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      title: Text(
        isEdit ? 'Edit record' : 'Add manual record',
        style: TextStyle(
          fontSize: 20,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textField(
                  controller: _titleController,
                  label: 'Title',
                  hint: 'Record title',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _dropDownField(
                        label: 'Record type',
                        value: _recordType,
                        items: _recordTypes,
                        onChanged: (next) {
                          setState(() => _recordType = next);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _dropDownField(
                        label: 'Category',
                        value: _category,
                        items: _recordTypes,
                        onChanged: (next) {
                          setState(() => _category = next);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        controller: _providerController,
                        label: 'Provider',
                        hint: 'Clinic or hospital',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _dateField()),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        controller: _visitTypeController,
                        label: 'Visit type',
                        hint: 'Routine',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _textField(
                        controller: _diagnosisController,
                        label: 'Diagnosis',
                        hint: 'Optional',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _textField(
                  controller: _contentController,
                  label: 'Record content',
                  hint: 'Summary or extracted content',
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                _textField(
                  controller: _notesController,
                  label: 'Notes',
                  hint: 'Additional note',
                  maxLines: 3,
                ),
                if (widget.scannedImagePath != null &&
                    widget.scannedImagePath!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Scanned image will be attached',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.isSubmitting
              ? null
              : () => Navigator.of(context).pop<MedicalRecordUpsertEntity?>(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: widget.isSubmitting ? null : _onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: widget.isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(isEdit ? 'Save changes' : 'Save record'),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: 13.5,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _dropDownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : items.first,
      isDense: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(growable: false),
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
    );
  }

  Widget _dateField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Date',
        suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      onTap: () async {
        final now = DateTime.now();
        final initial = DateTime.tryParse(_dateController.text) ?? now;
        final selected = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(now.year - 20),
          lastDate: DateTime(now.year + 5),
        );
        if (selected != null) {
          _dateController.text = DateFormat('yyyy-MM-dd').format(selected);
        }
      },
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final payload = MedicalRecordUpsertEntity(
      title: _titleController.text.trim(),
      recordType: _recordType,
      category: _category,
      provider: _providerController.text.trim(),
      recordDate: _dateController.text.trim(),
      visitType: _visitTypeController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      content: _contentController.text.trim(),
      notes: _notesController.text.trim(),
      aiScanned: widget.scanResult != null,
      structuredData: widget.scanResult?.structured,
      attachmentPaths: widget.scannedImagePath == null
          ? const []
          : [widget.scannedImagePath!],
    );

    Navigator.of(context).pop<MedicalRecordUpsertEntity>(payload);
  }

  String _normalizeChoice({
    required String? candidate,
    required String fallback,
  }) {
    final trimmed = candidate?.trim();
    if (trimmed == null || trimmed.isEmpty) return fallback;
    final match = _recordTypes.where(
      (item) => item.toLowerCase() == trimmed.toLowerCase(),
    );
    return match.isNotEmpty ? match.first : fallback;
  }

  String? _normalizeDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return null;
    return DateFormat('yyyy-MM-dd').format(parsed.toLocal());
  }
}

