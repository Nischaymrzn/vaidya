import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaidya/core/widgets/app_side_drawer.dart';
import 'package:vaidya/core/widgets/notifications_panel.dart';
import 'package:vaidya/features/dashboard/domain/entities/notification_entity.dart';
import 'package:vaidya/features/dashboard/presentation/state/notifications_state.dart';
import 'package:vaidya/features/dashboard/presentation/view_model/notifications_viewmodel.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/presentation/pages/record_editor_page.dart';
import 'package:vaidya/features/records/presentation/state/records_state.dart';
import 'package:vaidya/features/records/presentation/view_model/records_viewmodel.dart';
import 'package:vaidya/features/records/presentation/widgets/record_details_dialog.dart';
import 'package:vaidya/features/records/presentation/widgets/record_menu_action.dart';
import 'package:vaidya/features/records/presentation/widgets/records_action_buttons.dart';
import 'package:vaidya/features/records/presentation/widgets/records_documents_tab.dart';
import 'package:vaidya/features/records/presentation/widgets/records_overview_tab.dart';
import 'package:vaidya/features/records/presentation/widgets/records_top_banner.dart';
import 'package:vaidya/features/records/presentation/widgets/records_ui_helpers.dart';
import 'package:vaidya/themes/colors.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(recordsViewModelProvider.notifier)
          .loadRecords(forceLoading: true);
      ref
          .read(recordsViewModelProvider.notifier)
          .loadSupportData(forceLoading: true);
      ref
          .read(notificationsViewModelProvider.notifier)
          .load(forceLoading: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recordsViewModelProvider);
    final notificationsState = ref.watch(notificationsViewModelProvider);
    final unreadCount = notificationsState.items
        .where((item) => !item.isRead)
        .length;

    ref.listen<RecordsState>(recordsViewModelProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        _showMessage(next.errorMessage!, isError: true);
      }

      if (next.actionMessage != null &&
          next.actionMessage != previous?.actionMessage) {
        _showMessage(next.actionMessage!);
        ref.read(recordsViewModelProvider.notifier).clearMessages();
      }
    });

    ref.listen<NotificationsState>(notificationsViewModelProvider, (
      previous,
      next,
    ) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        _showMessage(next.errorMessage!, isError: true);
      }
    });

    final filteredRecords = _applyFilters(state.records, state);
    final aiProcessedCount = state.records
        .where((record) => record.aiScanned)
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppSideDrawer(
        currentDestination: AppDrawerDestination.records,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(recordsViewModelProvider.notifier)
            .loadRecords(forceLoading: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecordsTopBanner(
                unreadCount: unreadCount,
                onNotificationTap: () async {
                  await ref
                      .read(notificationsViewModelProvider.notifier)
                      .load(forceLoading: true);
                  if (!mounted) return;
                  final refreshed = ref.read(notificationsViewModelProvider);
                  final refreshedItems = _buildNotificationItems(
                    refreshed.items,
                  );
                  showNotificationsPanel(
                    this.context,
                    items: refreshedItems,
                    isLoading: refreshed.status == NotificationsStatus.loading,
                    onMarkRead: (id) async {
                      return ref
                          .read(notificationsViewModelProvider.notifier)
                          .markRead(id);
                    },
                    onMarkAllRead: () async {
                      return ref
                          .read(notificationsViewModelProvider.notifier)
                          .markAllRead();
                    },
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 8,
                  bottom: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tabBar(state),
                    const SizedBox(height: 12),
                    RecordsActionButtons(
                      onAiScan: _handleScanWithAi,
                      onScanDocument: _handleScanWithAi,
                      onAddManual: _handleAddManual,
                      isScanning: state.isScanning,
                      isSubmitting: state.isSubmitting,
                    ),
                    const SizedBox(height: 12),
                    if (state.status == RecordsStatus.loading &&
                        state.records.isEmpty)
                      const SizedBox(
                        height: 260,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (state.status == RecordsStatus.error &&
                        state.records.isEmpty)
                      _errorState()
                    else if (state.activeTab == RecordsTab.documents)
                      RecordsDocumentsTab(
                        records: filteredRecords,
                        searchTerm: state.searchTerm,
                        onSearchChanged: (value) {
                          ref
                              .read(recordsViewModelProvider.notifier)
                              .setSearchTerm(value);
                        },
                        currentPage: state.documentsPage,
                        pageSize: state.documentsPageSize,
                        onPageChanged: (page) {
                          ref
                              .read(recordsViewModelProvider.notifier)
                              .setDocumentsPage(page);
                        },
                        onAddMore: _handleAddManual,
                        onRecordAction: _handleRecordAction,
                      )
                    else
                      RecordsOverviewTab(
                        allRecords: state.records,
                        aiProcessedCount: aiProcessedCount,
                        onScanTap: _handleScanWithAi,
                        onRecordAction: _handleRecordAction,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBar(RecordsState state) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Overview',
            active: state.activeTab == RecordsTab.overview,
            onTap: () {
              ref
                  .read(recordsViewModelProvider.notifier)
                  .setActiveTab(RecordsTab.overview);
            },
          ),
          _TabItem(
            label: 'Documents',
            active: state.activeTab == RecordsTab.documents,
            onTap: () {
              ref
                  .read(recordsViewModelProvider.notifier)
                  .setActiveTab(RecordsTab.documents);
            },
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return SizedBox(
      height: 260,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Unable to load records.',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(recordsViewModelProvider.notifier)
                    .loadRecords(forceLoading: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddManual() async {
    final payload = await Navigator.of(context).push<MedicalRecordUpsertEntity>(
      MaterialPageRoute(builder: (_) => const RecordEditorPage.create()),
    );
    if (payload == null) return;
    await ref.read(recordsViewModelProvider.notifier).createRecord(payload);
  }

  Future<void> _handleScanWithAi() async {
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
      withData: false,
      withReadStream: false,
    );
    final pickedPath = picked?.files.single.path?.trim();
    if (pickedPath == null || pickedPath.isEmpty) return;

    final scanResult = await ref
        .read(recordsViewModelProvider.notifier)
        .scanImage(pickedPath);
    if (scanResult == null || !mounted) return;

    final payload = await Navigator.of(context).push<MedicalRecordUpsertEntity>(
      MaterialPageRoute(
        builder: (_) {
          return RecordEditorPage.scan(
            scanResult: scanResult,
            scannedFilePath: pickedPath,
          );
        },
      ),
    );

    if (payload == null) return;

    await ref.read(recordsViewModelProvider.notifier).createRecord(payload);
  }

  Future<void> _handleRecordAction(
    MedicalRecordEntity record,
    RecordMenuAction action,
  ) async {
    switch (action) {
      case RecordMenuAction.viewRecord:
        await _openRecordDetails(record);
        break;
      case RecordMenuAction.viewPdf:
        await _openByAttachmentType(record, wantPdf: true);
        break;
      case RecordMenuAction.viewImage:
        await _openByAttachmentType(record, wantPdf: false);
        break;
      case RecordMenuAction.download:
        await _downloadRecordAttachment(record);
        break;
      case RecordMenuAction.edit:
        await _openEditRecord(record);
        break;
      case RecordMenuAction.delete:
        await _confirmDelete(record);
        break;
    }
  }

  Future<void> _openRecordDetails(MedicalRecordEntity record) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return RecordDetailsDialog(
          record: record,
          onOpenAttachment: (attachment, {download = false}) async {
            final url = buildFileProxyUrl(
              fileUrl: attachment.url,
              download: download,
              name: attachment.name,
            );
            await _launchExternal(url);
          },
        );
      },
    );
  }

  Future<void> _openByAttachmentType(
    MedicalRecordEntity record, {
    required bool wantPdf,
  }) async {
    MedicalRecordAttachmentEntity? target;
    for (final attachment in record.attachments) {
      if (wantPdf && attachment.isPdf) {
        target = attachment;
        break;
      }
      if (!wantPdf && attachment.isImage) {
        target = attachment;
        break;
      }
    }

    if (target == null) {
      _showMessage(
        wantPdf ? 'No PDF attachment found.' : 'No image attachment found.',
        isError: true,
      );
      return;
    }

    final openUrl = wantPdf
        ? buildFileProxyUrl(fileUrl: target.url, name: target.name)
        : target.url;
    await _launchExternal(openUrl);
  }

  Future<void> _downloadRecordAttachment(MedicalRecordEntity record) async {
    if (record.attachments.isEmpty) {
      _showMessage('No attachment available for download.', isError: true);
      return;
    }

    final first = record.attachments.first;
    final downloadUrl = buildFileProxyUrl(
      fileUrl: first.url,
      download: true,
      name: first.name,
    );

    await _launchExternal(downloadUrl);
  }

  Future<void> _openEditRecord(MedicalRecordEntity record) async {
    final payload = await Navigator.of(context).push<MedicalRecordUpsertEntity>(
      MaterialPageRoute(
        builder: (_) => RecordEditorPage.edit(initialRecord: record),
      ),
    );

    if (payload == null) return;

    await ref
        .read(recordsViewModelProvider.notifier)
        .updateRecord(record.id, payload);
  }

  Future<void> _confirmDelete(MedicalRecordEntity record) async {
    final delete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete record?'),
          content: Text(
            'Delete "${record.title}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (delete != true) return;

    await ref.read(recordsViewModelProvider.notifier).deleteRecord(record.id);
  }

  Future<void> _launchExternal(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      _showMessage('Invalid URL.', isError: true);
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _showMessage('Unable to open link.', isError: true);
    }
  }

  List<MedicalRecordEntity> _applyFilters(
    List<MedicalRecordEntity> records,
    RecordsState state,
  ) {
    final now = DateTime.now();
    final normalizedSearch = state.searchTerm.trim().toLowerCase();

    final filtered = records
        .where((record) {
          final category = normalizeCategoryLabel(
            record.category ?? record.recordType,
          );
          final provider = (record.provider ?? '').trim().isEmpty
              ? 'Unspecified'
              : record.provider!.trim();
          final status = record.effectiveStatus;

          final matchesSearch =
              normalizedSearch.isEmpty ||
              record.title.toLowerCase().contains(normalizedSearch) ||
              category.toLowerCase().contains(normalizedSearch) ||
              provider.toLowerCase().contains(normalizedSearch);

          final matchesCategory =
              state.categoryFilter == 'All' || category == state.categoryFilter;
          final matchesStatus =
              state.statusFilter == 'All' || status == state.statusFilter;
          final matchesProvider =
              state.providerFilter == 'All' || provider == state.providerFilter;

          final date = tryParseDate(record.effectiveDate);
          final matchesDate = () {
            if (state.dateFilter == 'Any time') return true;
            if (date == null) return false;

            if (state.dateFilter == 'Last 30 days') {
              return date.isAfter(now.subtract(const Duration(days: 30)));
            }
            if (state.dateFilter == 'Last 90 days') {
              return date.isAfter(now.subtract(const Duration(days: 90)));
            }

            final year = int.tryParse(state.dateFilter);
            if (year != null) {
              return date.year == year;
            }

            return true;
          }();

          return matchesSearch &&
              matchesCategory &&
              matchesStatus &&
              matchesProvider &&
              matchesDate;
        })
        .toList(growable: false);

    final sorted = [...filtered];
    if (state.sortBy == 'Name A-Z') {
      sorted.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    } else if (state.sortBy == 'Name Z-A') {
      sorted.sort(
        (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
      );
    } else {
      sorted.sort((a, b) {
        final aDate =
            tryParseDate(a.effectiveDate)?.millisecondsSinceEpoch ?? 0;
        final bDate =
            tryParseDate(b.effectiveDate)?.millisecondsSinceEpoch ?? 0;
        return bDate.compareTo(aDate);
      });
    }

    return sorted;
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade600 : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  List<AppNotificationItem> _buildNotificationItems(
    List<NotificationEntity> notifications,
  ) {
    if (notifications.isEmpty) {
      return const <AppNotificationItem>[];
    }

    return notifications
        .map((item) {
          return AppNotificationItem(
            id: item.id,
            title: item.title.isEmpty ? 'Notification' : item.title,
            subtitle: item.message.isEmpty
                ? 'You have a new health update.'
                : item.message,
            dateLabel: _formatNotificationDate(item.createdAt),
            read: item.isRead,
          );
        })
        .toList(growable: false);
  }

  String _formatNotificationDate(DateTime? date) {
    if (date == null) return 'Today';
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final local = date.toLocal();
    final month = months[local.month - 1];
    final day = local.day.toString().padLeft(2, '0');
    return '$month $day';
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.textPrimary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16,
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
