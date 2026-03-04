import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/presentation/widgets/record_editor/record_custom_fields_section.dart';
import 'package:vaidya/features/records/presentation/widgets/record_editor/record_form_config.dart';
import 'package:vaidya/features/records/presentation/widgets/record_editor/record_structured_fields_section.dart';
import 'package:vaidya/features/records/presentation/widgets/records_ui_helpers.dart';
import 'package:vaidya/themes/colors.dart';

enum RecordEditorMode { create, scan, edit }

class RecordEditorPage extends StatefulWidget {
  final RecordEditorMode mode;
  final MedicalRecordEntity? initialRecord;
  final AiScanResultEntity? scanResult;
  final String? scannedFilePath;

  const RecordEditorPage.create({super.key})
    : mode = RecordEditorMode.create,
      initialRecord = null,
      scanResult = null,
      scannedFilePath = null;

  const RecordEditorPage.scan({
    super.key,
    required this.scanResult,
    required this.scannedFilePath,
  }) : mode = RecordEditorMode.scan,
       initialRecord = null;

  const RecordEditorPage.edit({super.key, required this.initialRecord})
    : mode = RecordEditorMode.edit,
      scanResult = null,
      scannedFilePath = null;

  @override
  State<RecordEditorPage> createState() => _RecordEditorPageState();
}

class _RecordEditorPageState extends State<RecordEditorPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _dateController;
  late final TextEditingController _providerController;
  late final TextEditingController _diagnosisController;
  late final TextEditingController _contentController;
  late final TextEditingController _notesController;

  late String _recordType;
  late String _category;
  late String _visitType;

  final Map<String, String> _structuredValues = <String, String>{};
  final List<RecordCustomField> _customFields = <RecordCustomField>[];
  final List<String> _attachmentPaths = <String>[];

  @override
  void initState() {
    super.initState();

    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final initial = widget.initialRecord;
    final scan = widget.scanResult;

    _recordType = normalizeRecordTypeForForm(
      initial?.recordType ?? scan?.recordType,
    );
    _category = normalizeCategoryForForm(initial?.category ?? scan?.recordType);
    if (_category.isEmpty) {
      _category = _recordType;
    }
    _visitType = (initial?.visitType?.trim().isNotEmpty ?? false)
        ? initial!.visitType!.trim()
        : 'Routine';

    final seedTitle = () {
      final fromRecord = initial?.title.trim() ?? '';
      if (fromRecord.isNotEmpty) return fromRecord;
      final fromFilePath = widget.scannedFilePath?.trim() ?? '';
      if (fromFilePath.isNotEmpty) {
        final baseName = p.basenameWithoutExtension(fromFilePath).trim();
        if (baseName.isNotEmpty) return baseName;
      }
      final fromScan = scan?.summary?.trim() ?? '';
      if (fromScan.isNotEmpty) return fromScan;
      return '';
    }();

    _titleController = TextEditingController(text: seedTitle);
    _dateController = TextEditingController(
      text: _normalizeDate(initial?.recordDate ?? scan?.recordDate) ?? now,
    );
    _providerController = TextEditingController(
      text: initial?.provider ?? scan?.provider ?? '',
    );
    _diagnosisController = TextEditingController(
      text: initial?.diagnosis ?? '',
    );
    _contentController = TextEditingController(
      text: initial?.content ?? scan?.summary ?? scan?.text ?? '',
    );
    _notesController = TextEditingController(text: initial?.notes ?? '');

    _seedStructuredAndCustom(
      recordType: _recordType,
      data:
          initial?.structuredData ??
          (scan?.structured == null
              ? null
              : Map<String, dynamic>.from(scan!.structured!)),
    );

    final scannedPath = widget.scannedFilePath?.trim();
    if (scannedPath != null && scannedPath.isNotEmpty) {
      _attachmentPaths.add(scannedPath);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _providerController.dispose();
    _diagnosisController.dispose();
    _contentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final structuredSpecs =
        kTypeFieldMap[_recordType] ?? const <RecordFieldSpec>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_pageTitle),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_pageDescription.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _pageDescription,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (widget.mode == RecordEditorMode.scan &&
                    widget.scannedFilePath != null &&
                    widget.scannedFilePath!.trim().isNotEmpty) ...[
                  _ScanSourceCard(path: widget.scannedFilePath!.trim()),
                  const SizedBox(height: 10),
                ],
                _primaryFieldsCard(),
                const SizedBox(height: 10),
                RecordStructuredFieldsSection(
                  fields: structuredSpecs,
                  values: _structuredValues,
                  onChanged: (key, value) {
                    _structuredValues[key] = value;
                  },
                ),
                const SizedBox(height: 10),
                RecordCustomFieldsSection(
                  fields: _customFields,
                  onAddField: () {
                    setState(() {
                      _customFields.add(const RecordCustomField());
                    });
                  },
                  onKeyChanged: (index, value) {
                    setState(() {
                      _customFields[index] = _customFields[index].copyWith(
                        key: value,
                      );
                    });
                  },
                  onValueChanged: (index, value) {
                    setState(() {
                      _customFields[index] = _customFields[index].copyWith(
                        value: value,
                      );
                    });
                  },
                  onRemoveField: (index) {
                    setState(() {
                      _customFields.removeAt(index);
                    });
                  },
                ),
                const SizedBox(height: 10),
                _attachmentsCard(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(_saveLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryFieldsCard() {
    final categoryOptions = [
      ...kRecordTypes,
      ...kExtraCategoryOptions,
      if (_category.trim().isNotEmpty &&
          ![...kRecordTypes, ...kExtraCategoryOptions].contains(_category))
        _category,
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _textField(
            controller: _titleController,
            label: 'Title',
            hintText: 'Record title',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          _twoColumnRow(
            left: _dateField(),
            right: _dropdownField(
              label: 'Category',
              value: _category,
              options: categoryOptions,
              onChanged: (value) => setState(() => _category = value),
            ),
          ),
          const SizedBox(height: 10),
          _twoColumnRow(
            left: _dropdownField(
              label: 'Record type',
              value: _recordType,
              options: kRecordTypes,
              onChanged: (value) {
                setState(() {
                  final previous = _recordType;
                  _recordType = value;
                  if (_category == previous || _category.trim().isEmpty) {
                    _category = value;
                  }
                });
              },
            ),
            right: _textField(
              controller: _providerController,
              label: 'Provider',
              hintText: 'Clinic or doctor',
            ),
          ),
          const SizedBox(height: 10),
          _twoColumnRow(
            left: _dropdownField(
              label: 'Visit type',
              value: _visitType,
              options: kDefaultVisitTypes,
              onChanged: (value) => setState(() => _visitType = value),
            ),
            right: _textField(
              controller: _diagnosisController,
              label: 'Diagnosis',
              hintText: 'Optional',
            ),
          ),
          const SizedBox(height: 10),
          _textField(
            controller: _contentController,
            label: 'Record content',
            hintText: 'Notes, summary, or key findings',
            maxLines: 4,
          ),
          const SizedBox(height: 10),
          _textField(
            controller: _notesController,
            label: 'Notes',
            hintText: 'Additional context or next steps',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _attachmentsCard() {
    final initialAttachments = widget.initialRecord?.attachments ?? const [];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Attach files',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _pickAttachments,
                icon: const Icon(Icons.attach_file_rounded, size: 16),
                label: const Text('Choose files'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
          if (initialAttachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Existing attachments',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ...initialAttachments.map((attachment) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        (attachment.name ?? '').trim().isEmpty
                            ? attachment.url
                            : attachment.name!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Open',
                      onPressed: () =>
                          _openExistingAttachment(attachment, download: false),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Download',
                      onPressed: () =>
                          _openExistingAttachment(attachment, download: true),
                      icon: const Icon(Icons.download_rounded, size: 18),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (_attachmentPaths.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'New attachments',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ..._attachmentPaths.asMap().entries.map((entry) {
              final index = entry.key;
              final path = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p.basename(path),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      onPressed: () {
                        setState(() {
                          _attachmentPaths.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _twoColumnRow({required Widget left, required Widget right}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(children: [left, const SizedBox(height: 10), right]);
        }
        return Row(
          children: [
            Expanded(child: left),
            const SizedBox(width: 10),
            Expanded(child: right),
          ],
        );
      },
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    final normalized = options.contains(value) ? value : options.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: normalized,
          isDense: true,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          items: options
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(growable: false),
          onChanged: (next) {
            if (next != null) onChanged(next);
          },
        ),
      ],
    );
  }

  Widget _dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          onTap: _pickDate,
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = DateTime.tryParse(_dateController.text) ?? now;
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 30),
      lastDate: DateTime(now.year + 10),
    );
    if (selected != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(selected);
    }
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
      withReadStream: false,
    );
    if (result == null) return;

    setState(() {
      for (final file in result.files) {
        final path = file.path?.trim();
        if (path == null || path.isEmpty) continue;
        if (!_attachmentPaths.contains(path)) {
          _attachmentPaths.add(path);
        }
      }
    });
  }

  void _seedStructuredAndCustom({
    required String recordType,
    Map<String, dynamic>? data,
  }) {
    if (data == null || data.isEmpty) return;

    final knownKeys = Set<String>.from(
      (kTypeFieldMap[recordType] ?? const <RecordFieldSpec>[]).map(
        (item) => item.key,
      ),
    );

    for (final entry in data.entries) {
      final formatted = formatStructuredValueForForm(entry.value).trim();
      if (formatted.isEmpty) continue;
      if (knownKeys.contains(entry.key)) {
        _structuredValues[entry.key] = formatted;
      } else {
        _customFields.add(RecordCustomField(key: entry.key, value: formatted));
      }
    }
  }

  Future<void> _openExistingAttachment(
    MedicalRecordAttachmentEntity attachment, {
    required bool download,
  }) async {
    final targetUrl = download
        ? buildFileProxyUrl(
            fileUrl: attachment.url,
            download: true,
            name: attachment.name,
          )
        : attachment.isPdf
        ? buildFileProxyUrl(fileUrl: attachment.url, name: attachment.name)
        : attachment.url;
    final uri = Uri.tryParse(targetUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cleanedStructured = <String, String>{};
    for (final entry in _structuredValues.entries) {
      final value = entry.value.trim();
      if (value.isNotEmpty) {
        cleanedStructured[entry.key] = value;
      }
    }

    final mergedStructured = <String, String>{...cleanedStructured};
    for (final custom in _customFields) {
      if (custom.isValid) {
        mergedStructured[custom.key.trim()] = custom.value.trim();
      }
    }

    final payload = MedicalRecordUpsertEntity(
      title: _titleController.text.trim(),
      recordType: _recordType,
      category: _category.trim().isEmpty ? _recordType : _category.trim(),
      provider: _providerController.text.trim(),
      recordDate: _dateController.text.trim(),
      visitType: _visitType.trim(),
      diagnosis: _diagnosisController.text.trim(),
      content: _contentController.text.trim(),
      notes: _notesController.text.trim(),
      aiScanned: _aiScannedValue,
      structuredData: mergedStructured.isEmpty
          ? null
          : Map<String, dynamic>.from(mergedStructured),
      attachmentPaths: List<String>.from(_attachmentPaths),
    );

    Navigator.of(context).pop(payload);
  }

  String? _normalizeDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return null;
    return DateFormat('yyyy-MM-dd').format(parsed.toLocal());
  }

  bool? get _aiScannedValue {
    switch (widget.mode) {
      case RecordEditorMode.scan:
        return true;
      case RecordEditorMode.edit:
        return widget.initialRecord?.aiScanned;
      case RecordEditorMode.create:
        return false;
    }
  }

  String get _pageTitle {
    switch (widget.mode) {
      case RecordEditorMode.create:
        return 'Add manual record';
      case RecordEditorMode.scan:
        return 'AI scan results';
      case RecordEditorMode.edit:
        return 'Edit record';
    }
  }

  String get _pageDescription {
    switch (widget.mode) {
      case RecordEditorMode.create:
        return 'Create a record even if you do not have a file yet.';
      case RecordEditorMode.scan:
        return 'Review and update extracted fields before creating the record.';
      case RecordEditorMode.edit:
        return 'Update details and save your changes.';
    }
  }

  String get _saveLabel {
    switch (widget.mode) {
      case RecordEditorMode.edit:
        return 'Save changes';
      case RecordEditorMode.create:
      case RecordEditorMode.scan:
        return 'Save record';
    }
  }
}

class _ScanSourceCard extends StatelessWidget {
  final String path;

  const _ScanSourceCard({required this.path});

  @override
  Widget build(BuildContext context) {
    final fileName = p.basename(path);
    final isImage = _looksLikeImage(path);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
              color: Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            child: isImage
                ? Image.file(File(path), fit: BoxFit.cover)
                : const Icon(Icons.insert_drive_file_outlined, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _looksLikeImage(String value) {
    final lower = value.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp');
  }
}

