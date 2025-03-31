
class User {
  final int? id;
  final String? email;
  final String? password;
  final String? registerType;
  final String? iosToken;
  final String? androidToken;
  final String? refreshToken;
  final String? socialKey;
  final String? imageAvatar;
  final int? suplierId;
  
    User({
    this.id,
    this.email,
    this.password,
    this.registerType,
    this.iosToken,
    this.androidToken,
    this.refreshToken,
    this.socialKey,
    this.imageAvatar,
    this.suplierId
  });


  User copyWith({
    int? id,
    String? email,
    String? password,
    String? registerType,
    String? iosToke,
    String? androidToken,
    String? refreshToken,
    String? socialKey,
    String? imageAvatar,
    int? suplierId    
  }) {
    return User(

      id: id,
      email: email,
      password: password,
      registerType: registerType,
      iosToken: iosToke,
      androidToken: androidToken,
      refreshToken: refreshToken,
      socialKey: socialKey,
      imageAvatar: imageAvatar,
      suplierId: suplierId
    );
  }
}
