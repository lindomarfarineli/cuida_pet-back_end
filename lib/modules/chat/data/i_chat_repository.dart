import 'package:cuidapet_api/entities/chat.dart';

abstract interface class IChatRepository {

  Future<int> startChat(scheduleId);

  Future<Chat?> findChatById (int chatId);

  Future<List<Chat>> getChatsByUser (int user);

  Future<List<Chat>> getChatsBySupplier (int supplier);

  Future<void> endChat (int chatId);

}