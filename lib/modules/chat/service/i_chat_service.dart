import 'package:cuidapet_api/entities/chat.dart';
import 'package:cuidapet_api/modules/chat/view_models/chat_notify_view_model.dart';

abstract interface class IChatService {

  Future<int> startChat(int scheduId) ; 

  Future<void> notifyChat(ChatNotifyViewModel model);
  Future<List<Chat>> getChatsByUser(int user);
   Future<List<Chat>> getChatsBySupplier(int supplier);

}