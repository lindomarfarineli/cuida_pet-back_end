import 'dart:convert';

import 'package:cuidapet_api/application/helpers/jwt_helper.dart';
import 'package:cuidapet_api/application/logs/i_log.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;

@lazySingleton
class PushNotificationFacade {
  ILog log;

  PushNotificationFacade({
    required this.log,
  });

  Future<void> sendMessage(
      {required List<String?> devices,
      required String title,
      required String body,
      required Map<String, dynamic> payload}) async {
    try {
      final request = {
        'notification': {'body': body, 'title': title},
        'priority': 'high',
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
          'payload': payload
        }
      };

      final firebaseKey = env['FIREBASE_PUSH_KEY'] ?? env['firebasePushKey'];

      if (firebaseKey == null) {
        return;
      }

      for (var device in devices) {
        if (device != null) {
          request['to'] = device;
          log.info('enviando mensagem para device $device');
          final result = await http.post(
              Uri.parse('https://fcm.googleapis.com/fcm/send'),
              body: jsonEncode(request),
              headers: {
                'authorization': 'key=$firebaseKey',
                'Content/Type': 'application/json'
              });

          final responseData = jsonDecode(result.body);

          if (responseData['failure'] == 1) {
            log.error(
                'erro ao enviar notification $device erro: ${responseData['results']?[0]}');
          } else {
            log.info('notificação enviada com sucesso $device');
          }
        }
      }
    } catch (e, s) {
      log.error('erro ao enviar notificacao', e, s);
    }
  }
}
