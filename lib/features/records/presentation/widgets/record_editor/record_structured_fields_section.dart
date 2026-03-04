import 'package:flutter/material.dart';
import 'package:vaidya/features/records/presentation/widgets/record_editor/record_form_config.dart';
import 'package:vaidya/themes/colors.dart';

class RecordStructuredFieldsSection extends StatelessWidget {
  final List<RecordFieldSpec> fields;
  final Map<String, String> values;
  final void Function(String key, String value) onChanged;

  const RecordStructuredFieldsSection({
    super.key,
    required this.fields,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Structured fields',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth >= 720
                  ? (constraints.maxWidth - 10) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: fields
                    .map(
                      (field) => SizedBox(
                        width: width,
                        child: _StructuredFieldInput(
                          field: field,
                          value: values[field.key] ?? '',
                          onChanged: (value) => onChanged(field.key, value),
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StructuredFieldInput extends StatelessWidget {
  final RecordFieldSpec field;
  final String value;
  final ValueChanged<String> onChanged;

  const _StructuredFieldInput({
    required this.field,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          field.label,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 13.5,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: field.placeholder,
            hintStyle: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}

