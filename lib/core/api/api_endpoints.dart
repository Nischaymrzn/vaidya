class ApiEndpoints {
  ApiEndpoints._();

  // Default is LAN IP for direct `flutter run` on physical device.
  // Override when needed:
  // --dart-define=API_BASE_URL=http://<host>:5000/v1/api
  // Android emulator example: http://10.0.2.2:5000/v1/api
  // static const String baseUrl = String.fromEnvironment(
  //   'API_BASE_URL',
  //   defaultValue: 'http://192.168.1.2:5000/v1/api',
  // );

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/v1/api',
  );

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth Endpoints ============
  static const String userLogin = '/auth/login';
  static const String userRegister = '/auth/register';
  static const String currentUser = '/auth/me';
  static const String requestPasswordReset = '/auth/request-password-reset';
  static const String googleLoginStatus = '/auth/google/status';
  static const String googleLogin = '/auth/google';
  static const String googleMobileLogin = '/auth/google/mobile';
  static const String googleServerClientId =
      '184087064596-oi175dsjljikig95f1cfgqq3hqpcl1vp.apps.googleusercontent.com';
  static const String googleMobileCallback = 'vaidya://auth/callback';
  static String get googleLoginUrl => '$baseUrl$googleLogin';
  static String get googleLoginMobileUrl =>
      '$googleLoginUrl?redirect_uri=${Uri.encodeComponent(googleMobileCallback)}';

  // ============ Dashboard Endpoints ============
  static const String dashboardSummary = '/dashboard/summary';

  // ============ Medical Records Endpoints ============
  static const String medicalRecords = '/medical-records';
  static String medicalRecordById(String id) => '$medicalRecords/$id';
  static const String medicalFiles = '/medical-files';
  static String medicalFileById(String id) => '$medicalFiles/$id';
  static const String aiScan = '/ai-scan';
  static const String files = '/files';

  // ============ Vitals Endpoints ============
  static const String vitals = '/vitals';
  static const String vitalsSummary = '/vitals/summary';
  static String vitalById(String id) => '$vitals/$id';

  // ============ Symptoms Endpoints ============
  static const String symptoms = '/symptoms';
  static const String symptomsSummary = '/symptoms';
  static String symptomById(String id) => '$symptoms/$id';

  // ============ Medications Endpoints ============
  static const String medications = '/medications';
  static const String medicationsSummary = '/medications';
  static String medicationById(String id) => '$medications/$id';

  // ============ Allergies Endpoints ============
  static const String allergies = '/allergies';
  static const String allergiesSummary = '/allergies';
  static String allergyById(String id) => '$allergies/$id';

  // ============ Immunizations Endpoints ============
  static const String immunizations = '/immunizations';
  static const String immunizationsSummary = '/immunizations';
  static String immunizationById(String id) => '$immunizations/$id';

  // ============ Notifications Endpoints ============
  static const String notifications = '/notifications';
  static String notificationMarkRead(String id) => '$notifications/$id/read';
  static const String notificationMarkAllRead = '/notifications/read-all';

  // ============ User Data Endpoints ============
  static const String userData = '/user-data';

  // ============ Analytics Endpoints ============
  static const String analyticsSummary = '/analytics/summary';

  // ============ Family Endpoints ============
  static const String familyGroups = '/family-groups';
  static const String familyMyGroup = '/family-groups/me';
  static const String familySummary = '/family-groups/me/summary';
  static String familyInvite(String groupId) =>
      '/family-groups/$groupId/invitations';
  static String familyAddMember(String groupId) =>
      '/family-groups/$groupId/members';
  static String familyUpdateMember(String groupId, String memberId) =>
      '/family-groups/$groupId/members/$memberId';
  static String familyJoin(String token) => '/family-groups/join/$token';

  // ============ Risk Assessment Endpoints ============
  static const String riskAssessments = '/risk-assessments';
  static const String riskGenerate = '/risk-assessments/generate';
  static String riskAssessmentById(String id) => '$riskAssessments/$id';

  // ============ Health Insights Endpoints ============
  static const String healthInsights = '/health-insights';
  static String healthInsightById(String id) => '$healthInsights/$id';

  // ============ AI/Intelligence Endpoints ============
  static const String aiInsights = '/ai-insights';
  static const String aiChat = '/ai-chat';

  // ============ Prediction Endpoints ============
  static const String predictSymptom = '/predict/symptom';
  static const String predictHeartDisease = '/predict/heart-disease';
  static const String predictDiabetes = '/predict/diabetes';
  static const String predictBrainTumor = '/predict/brain-tumor';
  static const String predictTuberculosis = '/predict/tuberculosis';

  // ============ User Endpoints ============
  static const String user = '/users';
  static String userById(String id) => '/users/$id';
  static String updateUser(String id) => '/users/$id';

  // ============ Payment / Premium Endpoints ============
  static const String paymentStatus = '/payments/status';
  static const String paymentCheckoutSession = '/payments/checkout-session';
}
