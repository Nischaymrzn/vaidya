import 'package:vaidya/features/intelligence/domain/entities/intelligence_entity.dart';

class AiInsightApiModel {
  final String id;
  final Map<String, dynamic> data;

  const AiInsightApiModel({required this.id, required this.data});

  factory AiInsightApiModel.fromJson(Map<String, dynamic> json, {String fallbackId = ''}) {
    final mapped = Map<String, dynamic>.from(json);
    return AiInsightApiModel(
      id: (mapped['_id'] ?? mapped['id'] ?? fallbackId).toString(),
      data: mapped,
    );
  }

  AiInsightEntity toEntity() => AiInsightEntity(id: id, data: data);

  static List<AiInsightApiModel> fromJsonList(dynamic raw) {
    if (raw is! List) return const [];

    final items = <AiInsightApiModel>[];
    for (int i = 0; i < raw.length; i++) {
      final item = raw[i];
      if (item is Map) {
        items.add(
          AiInsightApiModel.fromJson(
            item.map((k, v) => MapEntry(k.toString(), v)),
            fallbackId: 'insight_$i',
          ),
        );
      }
    }
    return items;
  }
}

class AiChatReplyApiModel {
  final String reply;
  final Map<String, dynamic> data;

  const AiChatReplyApiModel({required this.reply, required this.data});

  factory AiChatReplyApiModel.fromJson(Map<String, dynamic> json) {
    final mapped = Map<String, dynamic>.from(json);
    return AiChatReplyApiModel(
      reply: (mapped['reply'] ?? '').toString(),
      data: mapped,
    );
  }

  AiChatReplyEntity toEntity() => AiChatReplyEntity(reply: reply, data: data);
}
