import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vaidya/features/vitals/presentation/models/vitals_view_data.dart';
import 'package:vaidya/themes/colors.dart';

class VitalsLogCard extends StatefulWidget {
  final List<VitalRecordViewData> records;
  final VoidCallback onAddEntry;
  final Future<void> Function(VitalRecordViewData record) onView;
  final Future<void> Function(VitalRecordViewData record) onEdit;
  final Future<void> Function(VitalRecordViewData record) onDelete;

  const VitalsLogCard({
    super.key,
    required this.records,
    required this.onAddEntry,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<VitalsLogCard> createState() => _VitalsLogCardState();
}

class _VitalsLogCardState extends State<VitalsLogCard> {
  static const _pageSize = 7;
  var _page = 1;

  @override
  void didUpdateWidget(covariant VitalsLogCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pages = _totalPages;
    if (_page > pages) {
      _page = pages;
    }
  }

  int get _totalPages {
    if (widget.records.isEmpty) return 1;
    return (widget.records.length / _pageSize).ceil();
  }

  List<VitalRecordViewData> get _visible {
    final start = (_page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, widget.records.length);
    if (start >= widget.records.length) return const [];
    return widget.records.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1F2937),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vitals Log',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 20,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Latest entries first. Edit or remove any row.',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: widget.onAddEntry,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  child: const Text('Add entry'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.records.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'No vitals recorded yet. Add your first reading to see trends.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final minTableWidth = constraints.maxWidth >= 760
                      ? constraints.maxWidth
                      : 372.0;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: minTableWidth,
                      child: _DesktopTable(
                        rows: visible,
                        onView: widget.onView,
                        onEdit: widget.onEdit,
                        onDelete: widget.onDelete,
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Page $_page of $_totalPages',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                _PagerButton(
                  label: 'Prev',
                  enabled: _page > 1,
                  onPressed: () =>
                      setState(() => _page = (_page - 1).clamp(1, _totalPages)),
                ),
                const SizedBox(width: 8),
                _PagerButton(
                  label: 'Next',
                  enabled: _page < _totalPages,
                  onPressed: () =>
                      setState(() => _page = (_page + 1).clamp(1, _totalPages)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopTable extends StatelessWidget {
  final List<VitalRecordViewData> rows;
  final Future<void> Function(VitalRecordViewData record) onView;
  final Future<void> Function(VitalRecordViewData record) onEdit;
  final Future<void> Function(VitalRecordViewData record) onDelete;

  const _DesktopTable({
    required this.rows,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: const _TableRow(
              header: true,
              date: 'DATE',
              heart: 'HEART',
              bp: 'BP',
              glucose: 'GLUCOSE',
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          ...List.generate(rows.length, (index) {
            final record = rows[index];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  child: _TableRow(
                    date: _displayDate(record.displayDate),
                    heart: displayNum(record.heartRate),
                    bp: record.bloodPressureValue,
                    glucose: displayNum(record.glucoseLevel),
                    action: _ActionMenu(
                      record: record,
                      onView: onView,
                      onEdit: onEdit,
                      onDelete: onDelete,
                    ),
                  ),
                ),
                if (index != rows.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final bool header;
  final String date;
  final String heart;
  final String bp;
  final String glucose;
  final Widget? action;

  const _TableRow({
    this.header = false,
    required this.date,
    required this.heart,
    required this.bp,
    required this.glucose,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final headerStyle = const TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 11.5,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.4,
      color: AppColors.textSecondary,
    );

    final valueStyle = const TextStyle(
      fontFamily: 'Urbanist',
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    );

    Widget textCell(
      String value, {
      required int flex,
      TextAlign align = TextAlign.left,
    }) {
      return Expanded(
        flex: flex,
        child: Text(
          value,
          textAlign: align,
          style: header ? headerStyle : valueStyle,
        ),
      );
    }

    return Row(
      children: [
        textCell(date, flex: 24),
        textCell(heart, flex: 15),
        textCell(bp, flex: 18),
        textCell(glucose, flex: 18),
        Expanded(
          flex: 8,
          child: header
              ? Text('ACTIONS', textAlign: TextAlign.right, style: headerStyle)
              : Align(
                  alignment: Alignment.centerRight,
                  child: action ?? const SizedBox.shrink(),
                ),
        ),
      ],
    );
  }
}

class _PagerButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  const _PagerButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        side: BorderSide(
          color: enabled
              ? AppColors.border
              : AppColors.border.withValues(alpha: 0.8),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        foregroundColor: enabled
            ? AppColors.textPrimary
            : AppColors.textSecondary,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final VitalRecordViewData record;
  final Future<void> Function(VitalRecordViewData record) onView;
  final Future<void> Function(VitalRecordViewData record) onEdit;
  final Future<void> Function(VitalRecordViewData record) onDelete;

  const _ActionMenu({
    required this.record,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ActionType>(
      onSelected: (action) async {
        switch (action) {
          case _ActionType.view:
            await onView(record);
            break;
          case _ActionType.edit:
            await onEdit(record);
            break;
          case _ActionType.delete:
            await onDelete(record);
            break;
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      icon: const Icon(
        Icons.more_horiz_rounded,
        color: AppColors.textSecondary,
      ),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _ActionType.view,
          child: Text(
            'View',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        PopupMenuItem(
          value: _ActionType.edit,
          child: Text(
            'Edit',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        PopupMenuItem(
          value: _ActionType.delete,
          child: Text(
            'Delete',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFFDC2626),
            ),
          ),
        ),
      ],
    );
  }
}

enum _ActionType { view, edit, delete }

String _displayDate(DateTime? date) {
  if (date == null) return '--';
  return DateFormat('MMM d').format(date);
}
