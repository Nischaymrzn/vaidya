import 'package:equatable/equatable.dart';

class AiInsightEntity extends Equatable {
  final String id;
  final Map<String, dynamic> data;

  const AiInsightEntity({required this.id, required this.data});

  @override
  List<Object?> get props => [id, data];
}

class AiChatReplyEntity extends Equatable {
  final String reply;
  final Map<String, dynamic> data;

  const AiChatReplyEntity({required this.reply, required this.data});

  @override
  List<Object?> get props => [reply, data];
}
