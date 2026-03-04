import 'package:flutter/material.dart';
import 'package:vaidya/features/records/presentation/widgets/record_editor/record_form_config.dart';
import 'package:vaidya/themes/colors.dart';

class RecordCustomFieldsSection extends StatelessWidget {
  final List<RecordCustomField> fields;
  final VoidCallback onAddField;
  final void Function(int index, String value) onKeyChanged;
  final void Function(int index, String value) onValueChanged;
  final void Function(int index) onRemoveField;

  const RecordCustomFieldsSection({
    super.key,
    required this.fields,
    required this.onAddField,
    required this.onKeyChanged,
    required this.onValueChanged,
    required this.onRemoveField,
  });

  @override
  Widget build(BuildContext context) {
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
                  'Custom fields',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: onAddField,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text('Add field'),
              ),
            ],
          ),
          if (fields.isEmpty) ...[
            const SizedBox(height: 6),
            const Text(
              'No custom fields added.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (fields.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...fields.asMap().entries.map((entry) {
              final index = entry.key;
              final field = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 620;
                    if (compact) {
                      return Column(
                        children: [
                          _Input(
                            value: field.key,
                            hintText: 'Key',
                            onChanged: (value) => onKeyChanged(index, value),
                          ),
                          const SizedBox(height: 8),
                          _Input(
                            value: field.value,
                            hintText: 'Value',
                            onChanged: (value) => onValueChanged(index, value),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () => onRemoveField(index),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _Input(
                            value: field.key,
                            hintText: 'Key',
                            onChanged: (value) => onKeyChanged(index, value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _Input(
                            value: field.value,
                            hintText: 'Value',
                            onChanged: (value) => onValueChanged(index, value),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () => onRemoveField(index),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    );
                  },
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final String value;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _Input({
    required this.value,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
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
    );
  }
}

