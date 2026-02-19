import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vaidya/core/widgets/app_main_bottom_nav.dart';
import 'package:vaidya/core/widgets/app_side_drawer.dart';
import 'package:vaidya/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vaidya/features/dashboard/presentation/pages/dashboard.dart';
import 'package:vaidya/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:vaidya/features/dashboard/presentation/view_model/dashboard_viewmodel.dart';
import 'package:vaidya/features/family_health/presentation/models/family_health_view_data.dart';
import 'package:vaidya/features/family_health/presentation/state/family_health_state.dart';
import 'package:vaidya/features/family_health/presentation/view_model/family_health_viewmodel.dart';
import 'package:vaidya/features/family_health/presentation/widgets/family_charts_section.dart';
import 'package:vaidya/features/family_health/presentation/widgets/family_insights_card.dart';
import 'package:vaidya/features/family_health/presentation/widgets/family_member_panel.dart';
import 'package:vaidya/features/family_health/presentation/widgets/family_members_strip.dart';
import 'package:vaidya/features/family_health/presentation/widgets/family_top_banner.dart';
import 'package:vaidya/features/records/domain/entities/medical_record_entity.dart';
import 'package:vaidya/features/records/presentation/state/records_state.dart';
import 'package:vaidya/features/records/presentation/view_model/records_viewmodel.dart';
import 'package:vaidya/themes/colors.dart';

class FamilyHealthScreen extends ConsumerStatefulWidget {
  final String? initialMemberId;
  final bool memberOnly;

  const FamilyHealthScreen({
    super.key,
    this.initialMemberId,
    this.memberOnly = false,
  });

  @override
  ConsumerState<FamilyHealthScreen> createState() => _FamilyHealthScreenState();
}

class _FamilyHealthScreenState extends ConsumerState<FamilyHealthScreen> {
  String? _memberId;
  int _tab = 0;
  String? _loadedRecordsMemberId;

  @override
  void initState() {
    super.initState();
    _memberId = widget.initialMemberId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(familyHealthViewModelProvider.notifier).load(forceLoading: true);
      if (ref.read(dashboardViewModelProvider).status ==
          DashboardStatus.initial) {
        ref.read(dashboardViewModelProvider.notifier).getDashboardSummary();
      }
      if (ref.read(recordsViewModelProvider).status == RecordsStatus.initial) {
        ref
            .read(recordsViewModelProvider.notifier)
            .loadRecords(forceLoading: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyHealthViewModelProvider);
    final dashboardState = ref.watch(dashboardViewModelProvider);
    final recordsState = ref.watch(recordsViewModelProvider);
    final summary = FamilySummaryViewData.fromMaps(
      summaryData: state.summary.data,
      groupData: state.group?.data,
    );
    final selectedMember = summary.resolveMember(_memberId);
    if (selectedMember != null &&
        _loadedRecordsMemberId != selectedMember.userId &&
        state.status == FamilyHealthStatus.loaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRecordsForMember(summary, selectedMember.userId);
      });
    }

    final selected = selectedMember;
    final memberRecords = _sortedRecords(recordsState.records);
    final selectedIsCurrentUser =
        selected != null && selected.userId == summary.currentUserId;
    final derivedMedications = _deriveMedicationsFromRecords(memberRecords);
    final derivedAllergies = _deriveAllergiesFromRecords(memberRecords);
    final medications = derivedMedications.isNotEmpty
        ? derivedMedications
        : (selectedIsCurrentUser
              ? dashboardState.summary.medications.take(3).toList()
              : const <DashboardMedicationItemEntity>[]);
    final allergies = derivedAllergies.isNotEmpty
        ? derivedAllergies
        : (selectedIsCurrentUser
              ? dashboardState.summary.allergies
                    .map((item) => item.trim())
                    .where((item) => item.isNotEmpty)
                    .take(3)
                    .toList()
              : const <String>[]);
    final loading =
        state.status == FamilyHealthStatus.loading &&
        summary.members.isEmpty &&
        !summary.hasGroup;

    ref.listen<FamilyHealthState>(familyHealthViewModelProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        _msg(next.errorMessage!, error: true);
      }
      if (next.actionMessage != null &&
          next.actionMessage != prev?.actionMessage) {
        _msg(next.actionMessage!);
        ref.read(familyHealthViewModelProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: widget.memberOnly
          ? null
          : const AppSideDrawer(
              currentDestination: AppDrawerDestination.familyHealth,
            ),
      bottomNavigationBar: widget.memberOnly
          ? null
          : AppMainBottomNav(activeItem: null, onTap: _openMainTab),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(familyHealthViewModelProvider.notifier)
                  .load(forceLoading: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.memberOnly)
                      _MemberTopBar(onBack: () => Navigator.of(context).pop())
                    else
                      FamilyTopBanner(
                        summary: summary,
                        hasCritical: summary.criticalCount > 0,
                        onAddMember: () => _addMember(summary.groupId),
                        onInviteMember: () => _invite(summary.groupId),
                        onCreateGroup: _createGroup,
                        onJoinGroup: _joinGroup,
                        onEmergencyAlert: () => _msg(
                          summary.criticalCount > 0
                              ? 'Critical members detected.'
                              : 'No critical alerts right now.',
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!summary.hasGroup && !widget.memberOnly) ...[
                            const SizedBox(height: 16),
                            _NoGroupCard(
                              onCreateGroup: _createGroup,
                              onJoinGroup: _joinGroup,
                            ),
                          ],
                          if (!widget.memberOnly &&
                              summary.members.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            FamilyMembersStrip(
                              summary: summary,
                              selectedMemberId: _memberId,
                              onSelectMember: (id) {
                                setState(() {
                                  _memberId = id;
                                  _tab = 0;
                                });
                                _loadRecordsForMember(summary, id);
                              },
                              onViewMember: (id) => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FamilyHealthScreen(
                                    initialMemberId: id,
                                    memberOnly: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (selected != null) ...[
                            const SizedBox(height: 16),
                            _buildMemberContent(
                              summary,
                              selected,
                              records: memberRecords,
                              medications: medications,
                              allergies: allergies,
                            ),
                          ] else if (summary.members.isEmpty) ...[
                            const SizedBox(height: 16),
                            _emptyCard('No family members found.'),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMemberContent(
    FamilySummaryViewData summary,
    FamilyMemberViewData selected, {
    required List<MedicalRecordEntity> records,
    required List<DashboardMedicationItemEntity> medications,
    required List<String> allergies,
  }) {
    final insights = widget.memberOnly
        ? const [
            FamilyInsightViewData(
              title: 'AI review focus',
              detail:
                  'Recent vitals suggest attention on stability and recovery cadence.',
            ),
            FamilyInsightViewData(
              title: 'Care coordination',
              detail:
                  'Next check-in recommended within 7 days based on activity levels.',
            ),
          ]
        : summary.insights;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 960;
        final panel = FamilyMemberPanel(
          summary: summary,
          member: selected,
          records: records,
          medications: medications,
          allergies: allergies,
          activeTab: _tab,
          onTabChanged: (t) => setState(() => _tab = t),
          onMemberChanged: (id) {
            setState(() {
              _memberId = id;
              _tab = 0;
            });
            _loadRecordsForMember(summary, id);
          },
          memberOnly: widget.memberOnly,
        );

        final sidebar = Column(
          children: [
            FamilyInsightsCard(
              title: widget.memberOnly ? 'Member AI insights' : 'AI insights',
              subtitle: widget.memberOnly
                  ? 'Personalized guidance based on recent data.'
                  : 'Real-time family signals and priorities.',
              insights: insights,
            ),
            if (widget.memberOnly) ...[
              const SizedBox(height: 12),
              FamilyCareChecklist(
                onStartConsult: () => _msg('AI consult flow is coming soon.'),
              ),
            ],
          ],
        );

        final charts = widget.memberOnly
            ? MemberVitalsCharts(summary: summary, member: selected)
            : FamilyChartsSection(summary: summary);

        if (wide) {
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: panel),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: sidebar),
                ],
              ),
              const SizedBox(height: 16),
              charts,
            ],
          );
        }

        return Column(
          children: [
            panel,
            const SizedBox(height: 16),
            sidebar,
            if (_tab == 0) ...[const SizedBox(height: 16), charts],
          ],
        );
      },
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  List<MedicalRecordEntity> _sortedRecords(List<MedicalRecordEntity> records) {
    final sorted = [...records]
      ..sort((a, b) {
        final aDate =
            DateTime.tryParse(a.effectiveDate)?.millisecondsSinceEpoch ?? 0;
        final bDate =
            DateTime.tryParse(b.effectiveDate)?.millisecondsSinceEpoch ?? 0;
        return bDate.compareTo(aDate);
      });
    return sorted;
  }

  Future<void> _loadRecordsForMember(
    FamilySummaryViewData summary,
    String memberUserId,
  ) async {
    if (!mounted) return;
    _loadedRecordsMemberId = memberUserId;
    final currentUserId = summary.currentUserId;
    final shouldLoadMemberScoped =
        summary.isAdmin &&
        currentUserId != null &&
        memberUserId.trim().isNotEmpty &&
        memberUserId != currentUserId;
    await ref
        .read(recordsViewModelProvider.notifier)
        .loadRecords(
          page: 1,
          forceLoading: true,
          userId: shouldLoadMemberScoped ? memberUserId : null,
        );
  }

  List<DashboardMedicationItemEntity> _deriveMedicationsFromRecords(
    List<MedicalRecordEntity> records,
  ) {
    String textOf(dynamic value) => value?.toString().trim() ?? '';
    bool looksMedicationRecord(MedicalRecordEntity record) {
      final joined = [
        record.recordType,
        record.category,
        record.title,
      ].whereType<String>().join(' ').toLowerCase();
      return joined.contains('medication') ||
          joined.contains('medicine') ||
          joined.contains('prescription');
    }

    final output = <DashboardMedicationItemEntity>[];
    final seen = <String>{};

    void addMedication({
      required String name,
      required String dose,
      required String meta,
    }) {
      final normalizedName = name.trim();
      if (normalizedName.isEmpty) return;
      final key = '${normalizedName.toLowerCase()}|${dose.toLowerCase()}';
      if (seen.contains(key)) return;
      seen.add(key);
      output.add(
        DashboardMedicationItemEntity(
          name: normalizedName,
          dose: dose.trim().isEmpty ? '--' : dose.trim(),
          adherence: 0,
          meta: meta.trim().isEmpty ? 'Medication on file' : meta.trim(),
        ),
      );
    }

    for (final record in records) {
      final data = record.structuredData;
      final meta = textOf(
        data?['purpose'] ??
            data?['diagnosis'] ??
            data?['disease'] ??
            record.provider ??
            'Medication on file',
      );

      final directName = textOf(
        data?['medicineName'] ??
            data?['medication'] ??
            data?['drugName'] ??
            data?['name'],
      );
      if (directName.isNotEmpty || looksMedicationRecord(record)) {
        addMedication(
          name: directName.isNotEmpty ? directName : record.title,
          dose: textOf(data?['dosage'] ?? data?['dose'] ?? data?['strength']),
          meta: meta,
        );
      }

      final list = data?['medications'];
      if (list is List) {
        for (final item in list) {
          if (item is! Map) continue;
          addMedication(
            name: textOf(
              item['medicineName'] ??
                  item['medication'] ??
                  item['drugName'] ??
                  item['name'],
            ),
            dose: textOf(item['dosage'] ?? item['dose'] ?? item['strength']),
            meta: textOf(
              item['purpose'] ?? item['diagnosis'] ?? item['disease'] ?? meta,
            ),
          );
          if (output.length >= 3) break;
        }
      }

      if (output.length >= 3) break;
    }
    return output;
  }

  List<String> _deriveAllergiesFromRecords(List<MedicalRecordEntity> records) {
    String textOf(dynamic value) => value?.toString().trim() ?? '';
    bool looksAllergyRecord(MedicalRecordEntity record) {
      final joined = [
        record.recordType,
        record.category,
        record.title,
      ].whereType<String>().join(' ').toLowerCase();
      return joined.contains('allerg');
    }

    final set = <String>{};
    for (final record in records) {
      final data = record.structuredData;
      final allergen = textOf(
        data?['allergen'] ?? data?['allergy'] ?? data?['allergyName'],
      );
      if (allergen.isNotEmpty) {
        set.add(allergen);
      } else if (looksAllergyRecord(record)) {
        final title = textOf(record.title);
        if (title.isNotEmpty) {
          set.add(title);
        }
      }

      final list = data?['allergies'];
      if (list is List) {
        for (final item in list) {
          if (item is Map) {
            final name = textOf(
              item['allergen'] ?? item['allergy'] ?? item['name'],
            );
            if (name.isNotEmpty) {
              set.add(name);
            }
          }
          if (set.length >= 3) break;
        }
      }

      if (set.length >= 3) break;
    }
    return set.toList(growable: false);
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  Future<void> _createGroup() async {
    final controller = TextEditingController(text: 'Family Health');
    bool busy = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Create family group',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(fontFamily: 'Urbanist'),
            decoration: InputDecoration(
              labelText: 'Group name',
              labelStyle: const TextStyle(fontFamily: 'Urbanist'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: busy
                  ? null
                  : () async {
                      final name = controller.text.trim();
                      if (name.isEmpty) return;
                      setS(() => busy = true);
                      final ok = await ref
                          .read(familyHealthViewModelProvider.notifier)
                          .createGroup({'name': name});
                      setS(() => busy = false);
                      if (!mounted || !ok) return;
                      Navigator.of(context).pop();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  Future<void> _joinGroup() async {
    final linkCtrl = TextEditingController();
    final relCtrl = TextEditingController();
    bool busy = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Join family group',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: linkCtrl,
                style: const TextStyle(fontFamily: 'Urbanist'),
                decoration: InputDecoration(
                  labelText: 'Invite link or token',
                  labelStyle: const TextStyle(fontFamily: 'Urbanist'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: relCtrl,
                style: const TextStyle(fontFamily: 'Urbanist'),
                decoration: InputDecoration(
                  labelText: 'Relation (optional)',
                  labelStyle: const TextStyle(fontFamily: 'Urbanist'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: busy
                  ? null
                  : () async {
                      final tk = _parseToken(linkCtrl.text);
                      if (tk.isEmpty) return;
                      setS(() => busy = true);
                      final payload = relCtrl.text.trim().isEmpty
                          ? const <String, dynamic>{}
                          : {'relation': relCtrl.text.trim()};
                      final ok = await ref
                          .read(familyHealthViewModelProvider.notifier)
                          .joinWithInvite(tk, payload: payload);
                      setS(() => busy = false);
                      if (!mounted || !ok) return;
                      Navigator.of(context).pop();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Join'),
            ),
          ],
        ),
      ),
    );
    linkCtrl.dispose();
    relCtrl.dispose();
  }

  Future<void> _addMember(String groupId) async {
    final userCtrl = TextEditingController();
    final relCtrl = TextEditingController();
    bool busy = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add member',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userCtrl,
                style: const TextStyle(fontFamily: 'Urbanist'),
                decoration: InputDecoration(
                  labelText: 'User ID',
                  labelStyle: const TextStyle(fontFamily: 'Urbanist'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: relCtrl,
                style: const TextStyle(fontFamily: 'Urbanist'),
                decoration: InputDecoration(
                  labelText: 'Relation (optional)',
                  labelStyle: const TextStyle(fontFamily: 'Urbanist'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: busy
                  ? null
                  : () async {
                      final uid = userCtrl.text.trim();
                      if (uid.isEmpty) return;
                      final p = <String, dynamic>{'userId': uid};
                      if (relCtrl.text.trim().isNotEmpty) {
                        p['relation'] = relCtrl.text.trim();
                      }
                      setS(() => busy = true);
                      final ok = await ref
                          .read(familyHealthViewModelProvider.notifier)
                          .addMember(groupId, p);
                      setS(() => busy = false);
                      if (!mounted || !ok) return;
                      Navigator.of(context).pop();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Add'),
            ),
          ],
        ),
      ),
    );
    userCtrl.dispose();
    relCtrl.dispose();
  }

  Future<void> _invite(String groupId) async {
    var link = '';
    var exp = '';
    bool busy = false;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Invite member',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : () async {
                        setS(() => busy = true);
                        final ok = await ref
                            .read(familyHealthViewModelProvider.notifier)
                            .createInvite(
                              groupId,
                              payload: const {'expiresInDays': 7},
                            );
                        setS(() => busy = false);
                        if (!ok) return;
                        final st = ref.read(familyHealthViewModelProvider);
                        link = (st.latestInvite?.data['inviteLink'] ?? '')
                            .toString();
                        final raw = st.latestInvite?.data['expiresAt'];
                        exp = raw == null
                            ? '--'
                            : _formatDate(DateTime.tryParse(raw.toString()));
                        setS(() {});
                      },
                icon: const Icon(LucideIcons.link, size: 14),
                label: Text(
                  busy ? 'Generating...' : 'Generate invite link',
                  style: const TextStyle(fontFamily: 'Urbanist'),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (link.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: SelectableText(
                    link,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exp == '--'
                      ? 'Invite link active for 7 days'
                      : 'Expires on $exp',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: link));
                    _msg('Invite link copied.');
                  },
                  icon: const Icon(LucideIcons.copy, size: 14),
                  label: const Text(
                    'Copy',
                    style: TextStyle(fontFamily: 'Urbanist'),
                  ),
                ),
              ] else
                const Text(
                  'Invite links expire in 7 days by default.',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _parseToken(String value) {
    final t = value.trim();
    if (t.isEmpty) return '';
    final uri = Uri.tryParse(t);
    final fromUri = uri?.queryParameters['token'];
    if (fromUri != null && fromUri.trim().isNotEmpty) return fromUri.trim();
    final m = RegExp(r'token=([a-z0-9]+)', caseSensitive: false).firstMatch(t);
    return m?.group(1)?.trim() ?? t;
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '--';
    const months = [
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
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }

  void _openMainTab(MainBottomNavItem item) {
    final targetIndex = switch (item) {
      MainBottomNavItem.home => 0,
      MainBottomNavItem.records => 1,
      MainBottomNavItem.intelligence => 2,
      MainBottomNavItem.analytics => 3,
      MainBottomNavItem.profile => 4,
    };

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => DashboardScreen(initialIndex: targetIndex),
      ),
      (_) => false,
    );
  }

  void _msg(String m, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(m, style: const TextStyle(fontFamily: 'Urbanist')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? const Color(0xFFDC2626) : null,
        ),
      );
  }
}

// -----------------------------------------------------------------------------
// Private widgets used only by the screen
// -----------------------------------------------------------------------------

class _MemberTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _MemberTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 18, 14),
          child: GestureDetector(
            onTap: onBack,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6),
                Text(
                  'Back to family overview',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoGroupCard extends StatelessWidget {
  final VoidCallback onCreateGroup;
  final VoidCallback onJoinGroup;

  const _NoGroupCard({required this.onCreateGroup, required this.onJoinGroup});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No family group found',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Create a new family group or join via invite link.',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton(
                onPressed: onCreateGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Create'),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onJoinGroup,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Join'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
