import 'package:hive/hive.dart';

part 'chat_hive_model.g.dart';

@HiveType(typeId: 3)
class ChatHive {
  @HiveField(0)
  String text;

  @HiveField(1)
  String sender; // 'user' or 'bot'

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3) // 🆕 Date for daily tracking
  String date; // Format: 'YYYY-MM-DD'

  @HiveField(4, defaultValue: 'default_session') // 🆕 Session ID to group chats in sidebar
  String sessionId;

  ChatHive({
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.date,
    required this.sessionId,
  });
}
