import 'package:flutter/material.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/presentation/widgets/records_ui_helpers.dart';
import 'package:vaidya/themes/colors.dart';

class RecordDetailsDialog extends StatelessWidget {
  final MedicalRecordEntity record;
  final void Function(MedicalRecordAttachmentEntity attachment, {bool download})
  onOpenAttachment;

  const RecordDetailsDialog({
    super.key,
    required this.record,
    required this.onOpenAttachment,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      title: const Text(
        'Record details',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _item('Title', record.title),
              _item(
                'Category',
                normalizeCategoryLabel(record.category ?? record.recordType),
              ),
              _item(
                'Provider',
                (record.provider?.trim().isNotEmpty ?? false)
                    ? record.provider!.trim()
                    : 'Unspecified',
              ),
              _item('Date', formatDateLabel(record.effectiveDate)),
              _item('Status', record.effectiveStatus),
              if ((record.diagnosis ?? '').trim().isNotEmpty)
                _item('Diagnosis', record.diagnosis!.trim()),
              if ((record.notes ?? '').trim().isNotEmpty)
                _item('Notes', record.notes!.trim()),
              if ((record.content ?? '').trim().isNotEmpty)
                _item('Content', record.content!.trim()),
              const SizedBox(height: 8),
              const Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              if (record.attachments.isEmpty)
                const Text(
                  'No attachments',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                ...record.attachments.map(
                  (attachment) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          attachment.isPdf
                              ? Icons.picture_as_pdf_outlined
                              : Icons.image_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (attachment.name ?? '').trim().isNotEmpty
                                ? attachment.name!.trim()
                                : attachment.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Open',
                          onPressed: () => onOpenAttachment(attachment),
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        ),
                        IconButton(
                          tooltip: 'Download',
                          onPressed: () =>
                              onOpenAttachment(attachment, download: true),
                          icon: const Icon(Icons.download_rounded, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _item(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

