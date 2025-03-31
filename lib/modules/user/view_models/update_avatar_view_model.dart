
import 'package:cuidapet_api/application/helpers/request_mapping.dart';

class UpdateAvatarViewModel extends RequestMapping{


  int userId;
  late String urlAvatar;

  UpdateAvatarViewModel({required this.userId, required String dataRequest}): super(dataRequest);

  
  @override
  void map() {
    urlAvatar = data['url_avatar'];
  }
  
}