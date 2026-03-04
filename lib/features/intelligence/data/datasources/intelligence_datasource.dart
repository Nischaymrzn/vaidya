import 'package:vaidya/features/intelligence/data/models/intelligence_api_model.dart';

abstract interface class IIntelligenceRemoteDataSource {
  Future<List<AiInsightApiModel>> generateInsights({
    required String input,
    required int maxItems,
    required bool force,
  });

  Future<AiChatReplyApiModel> chat({
    required List<Map<String, String>> messages,
    String? doctor,
  });
}

abstract interface class IIntelligenceLocalDataSource {
  Future<void> cacheInsights(List<Map<String, dynamic>> items);
  Future<List<Map<String, dynamic>>> getCachedInsights();
}
