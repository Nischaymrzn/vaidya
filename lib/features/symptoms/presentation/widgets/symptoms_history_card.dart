import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vaidya/features/symptoms/presentation/models/symptom_view_data.dart';
import 'package:vaidya/themes/colors.dart';

class SymptomsHistoryCard extends StatefulWidget {
  final List<SymptomViewData> items;
  final bool loading;
  final ValueChanged<SymptomViewData> onEdit;
  final Future<void> Function(SymptomViewData item) onDelete;

  const SymptomsHistoryCard({
    super.key,
    required this.items,
    required this.loading,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<SymptomsHistoryCard> createState() => _SymptomsHistoryCardState();
}

class _SymptomsHistoryCardState extends State<SymptomsHistoryCard> {
  static const _pageSize = 6;

  String _search = '';
  String _severity = 'All';
  int _page = 1;

  List<SymptomViewData> get _filtered {
    final query = _search.trim().toLowerCase();
    return widget.items
        .where((item) {
          final matchesSearch = query.isEmpty
              ? true
              : item.title.toLowerCase().contains(query) ||
                    (item.notes?.toLowerCase().contains(query) ?? false);
          final matchesSeverity = _severity == 'All'
              ? true
              : (item.severityLabel?.toLowerCase() == _severity.toLowerCase());
          return matchesSearch && matchesSeverity;
        })
        .toList(growable: false);
  }

  int get _totalPages {
    final pages = (_filtered.length / _pageSize).ceil();
    return pages < 1 ? 1 : pages;
  }

  List<SymptomViewData> get _paginated {
    final safePage = _page > _totalPages ? _totalPages : _page;
    final start = (safePage - 1) * _pageSize;
    return _filtered.skip(start).take(_pageSize).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final paginated = _paginated;
    final severityOptions = _severityOptions(widget.items);

    if (_page > _totalPages) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _page = _totalPages);
      });
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Symptom history',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${filtered.length} of ${widget.items.length} records',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          onChanged: (value) {
                            setState(() {
                              _search = value;
                              _page = 1;
                            });
                          },
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search...',
                            isDense: true,
                            hintStyle: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: Icon(
                              LucideIcons.search,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.funnel,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _severity,
                              items: severityOptions
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        item == 'All' ? 'All severity' : item,
                                        style: const TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(growable: false),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _severity = value;
                                  _page = 1;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          if (widget.loading && widget.items.isEmpty)
            const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (filtered.isEmpty)
            const SizedBox(
              height: 240,
              child: Center(
                child: Text(
                  'No symptoms logged yet',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final useTable = constraints.maxWidth >= 760;
                if (useTable) {
                  return _DesktopTable(items: paginated);
                }

                return _MobileList(
                  items: paginated,
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                );
              },
            ),
          if (filtered.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  Text(
                    'Page $_page of $_totalPages',
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: _page <= 1
                        ? null
                        : () => setState(() => _page = _page - 1),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Prev',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _page >= _totalPages
                        ? null
                        : () => setState(() => _page = _page + 1),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<String> _severityOptions(List<SymptomViewData> items) {
    final values =
        items
            .map((item) => item.severityLabel)
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList(growable: false)
          ..sort();
    return ['All', ...values];
  }
}

class _DesktopTable extends StatelessWidget {
  final List<SymptomViewData> items;

  const _DesktopTable({required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 860,
        child: Column(
          children: [
            Container(
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: const Row(
                children: [
                  _HeaderCell('SYMPTOMS', flex: 50, align: TextAlign.left),
                  _HeaderCell('SEVERITY', flex: 16),
                  _HeaderCell('STATUS', flex: 16),
                  _HeaderCell('LOGGED', flex: 18),
                ],
              ),
            ),
            ...items.map((item) => _DesktopRow(item: item)),
          ],
        ),
      ),
    );
  }
}

class _DesktopRow extends StatelessWidget {
  final SymptomViewData item;

  const _DesktopRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 50,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if ((item.notes ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.notes!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            flex: 16,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _SeverityBadge(text: item.severityLabel),
            ),
          ),
          Expanded(
            flex: 16,
            child: Text(
              item.statusLabel,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 18,
            child: Text(
              _relativeTime(item.relevantDate),
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 15,
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

class _MobileList extends StatelessWidget {
  final List<SymptomViewData> items;
  final ValueChanged<SymptomViewData> onEdit;
  final Future<void> Function(SymptomViewData item) onDelete;

  const _MobileList({
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      child: Column(
        children: items
            .map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: .8),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              _SeverityBadge(text: item.severityLabel),
                              Text(
                                item.statusLabel,
                                style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),

                              Text(
                                _relativeTime(item.relevantDate),
                                style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if ((item.notes ?? '').isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                item.notes!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    _ActionMenu(item: item, onEdit: onEdit, onDelete: onDelete),
                  ],
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final SymptomViewData item;
  final ValueChanged<SymptomViewData> onEdit;
  final Future<void> Function(SymptomViewData item) onDelete;

  const _ActionMenu({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        LucideIcons.ellipsis,
        size: 18,
        color: AppColors.textSecondary,
      ),
      onSelected: (value) async {
        if (value == 'edit') {
          onEdit(item);
          return;
        }
        if (value == 'delete') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text(
                'Delete this symptom?',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: const Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontFamily: 'Urbanist'),
                  ),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontFamily: 'Urbanist'),
                  ),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await onDelete(item);
          }
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<String>(
          value: 'edit',
          child: Text(
            'Edit',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Text(
            'Delete',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w500,
              color: Color(0xFFDC2626),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign align;

  const _HeaderCell(
    this.text, {
    required this.flex,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.only(
          left: align == TextAlign.left ? 10 : 0,
          right: align == TextAlign.right ? 10 : 0,
        ),
        child: Text(
          text,
          textAlign: align,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            letterSpacing: .7,
          ),
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String? text;

  const _SeverityBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.trim().isEmpty) {
      return const Text(
        '-',
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      );
    }

    final value = text!.trim().toLowerCase();
    Color background;
    Color foreground;
    if (value == 'severe') {
      background = const Color(0xFFFFE4E6);
      foreground = const Color(0xFFBE123C);
    } else if (value == 'moderate') {
      background = const Color(0xFFFEF3C7);
      foreground = const Color(0xFFD97706);
    } else {
      background = const Color(0xFFDCFCE7);
      foreground = const Color(0xFF15803D);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text!,
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }
}

String _relativeTime(DateTime? date) {
  if (date == null) {
    return '-';
  }
  final diff = DateTime.now().difference(date);
  if (diff.inDays >= 1) {
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
  if (diff.inHours >= 1) {
    return '${diff.inHours} hr ago';
  }
  if (diff.inMinutes >= 1) {
    return '${diff.inMinutes} min ago';
  }
  return 'Just now';
}
