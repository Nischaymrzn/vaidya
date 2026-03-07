import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaidya/features/analytics/presentation/models/analytics_view_data.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_allergy_card.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_conditions_procedures_cards.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_encounters_card.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_header_section.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_medication_immunization_cards.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_network_card.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_section_card.dart';
import 'package:vaidya/features/analytics/presentation/widgets/analytics_summary_grid.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(12), child: child),
      ),
    );
  }

  Future<void> pumpWidgetUnderTest(WidgetTester tester, Widget child) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(wrap(child));
    await tester.pumpAndSettle();
  }

  const summaryItems = <AnalyticsSummaryCardViewData>[
    AnalyticsSummaryCardViewData(
      label: 'CARD A',
      value: 777,
      detail: 'Detail A',
    ),
    AnalyticsSummaryCardViewData(
      label: 'CARD B',
      value: 22,
      detail: 'Detail B',
    ),
    AnalyticsSummaryCardViewData(
      label: 'CARD C',
      value: 33,
      detail: 'Detail C',
    ),
    AnalyticsSummaryCardViewData(
      label: 'CARD D',
      value: 44,
      detail: 'Detail D',
    ),
    AnalyticsSummaryCardViewData(
      label: 'CARD E SHOULD NOT SHOW',
      value: 55,
      detail: 'Detail E',
    ),
  ];

  const encounterHistory = <AnalyticsEncounterPointViewData>[
    AnalyticsEncounterPointViewData(
      month: 'Jan',
      outpatient: 3,
      telehealth: 1,
      inpatient: 0,
    ),
    AnalyticsEncounterPointViewData(
      month: 'Feb',
      outpatient: 2,
      telehealth: 2,
      inpatient: 1,
    ),
    AnalyticsEncounterPointViewData(
      month: 'Mar',
      outpatient: 4,
      telehealth: 1,
      inpatient: 1,
    ),
  ];

  const encounterTotals = AnalyticsEncounterTotalsViewData(
    outpatient: 9,
    telehealth: 4,
    inpatient: 2,
  );

  const allergyData = <AnalyticsSeverityPointViewData>[
    AnalyticsSeverityPointViewData(name: 'Mild', value: 4),
    AnalyticsSeverityPointViewData(name: 'Moderate', value: 2),
    AnalyticsSeverityPointViewData(name: 'Severe', value: 1),
  ];

  const conditionsData = <AnalyticsCategoryCountViewData>[
    AnalyticsCategoryCountViewData(name: 'Hypertension', count: 8),
    AnalyticsCategoryCountViewData(name: 'Diabetes', count: 6),
    AnalyticsCategoryCountViewData(name: 'Asthma', count: 4),
    AnalyticsCategoryCountViewData(name: 'Migraine', count: 3),
    AnalyticsCategoryCountViewData(name: 'Anxiety', count: 2),
    AnalyticsCategoryCountViewData(name: 'Arthritis', count: 1),
  ];

  const proceduresData = <AnalyticsCategoryCountViewData>[
    AnalyticsCategoryCountViewData(name: 'Lab', count: 6),
    AnalyticsCategoryCountViewData(name: 'Imaging', count: 4),
    AnalyticsCategoryCountViewData(name: 'Surgery', count: 2),
    AnalyticsCategoryCountViewData(name: 'Therapy', count: 1),
  ];

  const medicationData = <AnalyticsMedicationHistoryPointViewData>[
    AnalyticsMedicationHistoryPointViewData(
      month: 'Jan',
      active: 4,
      newCount: 1,
      stopped: 0,
    ),
    AnalyticsMedicationHistoryPointViewData(
      month: 'Feb',
      active: 5,
      newCount: 2,
      stopped: 1,
    ),
  ];

  const networkData = AnalyticsProviderNetworkViewData(
    activeProviders: 5,
    referralsYtd: 3,
    careTouchpoints: 12,
    topProviders: [
      AnalyticsTopProviderViewData(name: 'Dr. Rai', count: 6),
      AnalyticsTopProviderViewData(name: 'Dr. Sharma', count: 4),
      AnalyticsTopProviderViewData(name: 'City Hospital', count: 3),
    ],
  );

  group('Analytics widget tests', () {
    testWidgets('1) header shows Clinical overview title', (tester) async {
      await pumpWidgetUnderTest(tester, const AnalyticsHeaderSection());
      expect(find.text('Clinical overview'), findsOneWidget);
    });

    testWidgets('2) header shows descriptive subtitle', (tester) async {
      await pumpWidgetUnderTest(tester, const AnalyticsHeaderSection());
      expect(
        find.textContaining('Track encounters, conditions'),
        findsOneWidget,
      );
    });

    testWidgets('3) section card renders title, subtitle and child', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsSectionCard(
          title: 'Section Title',
          subtitle: 'Section Subtitle',
          child: Text('Section Child'),
        ),
      );
      expect(find.text('Section Title'), findsOneWidget);
      expect(find.text('Section Subtitle'), findsOneWidget);
      expect(find.text('Section Child'), findsOneWidget);
    });

    testWidgets('4) empty state renders provided label', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsEmptyState(label: 'No analytics data.'),
      );
      expect(find.text('No analytics data.'), findsOneWidget);
    });

    testWidgets('5) summary grid falls back to default cards when empty', (
      tester,
    ) async {
      await pumpWidgetUnderTest(tester, const AnalyticsSummaryGrid(items: []));
      expect(find.text('ACTIVE CONDITIONS'), findsOneWidget);
      expect(find.text('IMMUNIZATIONS'), findsOneWidget);
    });

    testWidgets('6) summary grid renders custom first card value', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsSummaryGrid(items: summaryItems),
      );
      expect(find.text('CARD A'), findsOneWidget);
      expect(find.text('777'), findsOneWidget);
    });

    testWidgets('7) summary grid uses only first four cards', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsSummaryGrid(items: summaryItems),
      );
      expect(find.text('CARD D'), findsOneWidget);
      expect(find.text('CARD E SHOULD NOT SHOW'), findsNothing);
    });

    testWidgets('8) summary grid renders exactly four tile cards', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsSummaryGrid(items: summaryItems),
      );
      expect(find.byType(Card), findsNWidgets(4));
    });

    testWidgets('9) encounters card renders section title and chips', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsEncountersCard(
          history: encounterHistory,
          totals: encounterTotals,
          hasData: true,
        ),
      );
      expect(find.text('Encounter volume by month'), findsOneWidget);
      expect(find.text('Outpatient 9'), findsOneWidget);
      expect(find.text('Telehealth 4'), findsOneWidget);
      expect(find.text('Inpatient 2'), findsOneWidget);
    });

    testWidgets('10) encounters card shows empty state when no data', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsEncountersCard(
          history: encounterHistory,
          totals: encounterTotals,
          hasData: false,
        ),
      );
      expect(
        find.text('Log medical records to see encounter trends.'),
        findsOneWidget,
      );
    });

    testWidgets('11) encounters card shows legend when data exists', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsEncountersCard(
          history: encounterHistory,
          totals: encounterTotals,
          hasData: true,
        ),
      );
      expect(find.text('Outpatient'), findsAtLeastNWidgets(1));
      expect(find.text('Telehealth'), findsAtLeastNWidgets(1));
      expect(find.text('Inpatient'), findsAtLeastNWidgets(1));
    });

    testWidgets('12) allergy card shows empty state when no data', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsAllergyCard(data: allergyData, hasData: false),
      );
      expect(find.text('No allergy details logged yet.'), findsOneWidget);
    });

    testWidgets('13) allergy card shows legend labels for data points', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsAllergyCard(data: allergyData, hasData: true),
      );
      expect(find.text('Mild'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
      expect(find.text('Severe'), findsOneWidget);
    });

    testWidgets('14) conditions card shows empty state when no data', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsConditionsCard(data: conditionsData, hasData: false),
      );
      expect(
        find.text('Record diagnoses to see condition trends.'),
        findsOneWidget,
      );
    });

    testWidgets('15) conditions card shows top five and hides sixth', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsConditionsCard(data: conditionsData, hasData: true),
      );
      expect(find.text('Hypertension'), findsOneWidget);
      expect(find.text('Anxiety'), findsOneWidget);
      expect(find.text('Arthritis'), findsNothing);
    });

    testWidgets('16) procedures card shows empty state when no data', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsProceduresCard(data: proceduresData, hasData: false),
      );
      expect(
        find.text('Upload lab results and records to see procedures.'),
        findsOneWidget,
      );
    });

    testWidgets('17) procedures card renders category labels', (tester) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsProceduresCard(data: proceduresData, hasData: true),
      );
      expect(find.text('Lab'), findsOneWidget);
      expect(find.text('Imaging'), findsOneWidget);
      expect(find.text('Surgery'), findsOneWidget);
      expect(find.text('Therapy'), findsOneWidget);
    });

    testWidgets('18) medication history card shows empty state when no data', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsMedicationHistoryCard(
          data: medicationData,
          hasData: false,
        ),
      );
      expect(find.text('Add medications to track activity.'), findsOneWidget);
    });

    testWidgets('19) medication history card shows legend labels', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsMedicationHistoryCard(
          data: medicationData,
          hasData: true,
        ),
      );
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('New'), findsOneWidget);
      expect(find.text('Stopped'), findsOneWidget);
    });

    testWidgets('20) network card renders stats and top providers', (
      tester,
    ) async {
      await pumpWidgetUnderTest(
        tester,
        const AnalyticsNetworkCard(network: networkData, hasData: true),
      );
      expect(find.text('Care network'), findsOneWidget);
      expect(find.text('ACTIVE PROVIDERS'), findsOneWidget);
      expect(find.text('REFERRALS YTD'), findsOneWidget);
      expect(find.text('CARE TOUCHPOINTS'), findsOneWidget);
      expect(find.text('Dr. Rai'), findsAtLeastNWidgets(1));
      expect(find.text('Dr. Sharma'), findsAtLeastNWidgets(1));
    });
  });
}
