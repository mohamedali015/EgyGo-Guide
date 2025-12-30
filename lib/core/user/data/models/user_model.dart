import 'guide_model.dart';

class UserModel {
  String? sId;
  String? email;
  String? name;
  String? phone;
  String? role;
  bool? isEmailVerified;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? lastLogin;
  List<String>? fcmTokens;
  GuideModel? guide; // Add guide field

  UserModel({
    this.sId,
    this.email,
    this.name,
    this.phone,
    this.role,
    this.isEmailVerified,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.lastLogin,
    this.fcmTokens,
    this.guide,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    // Check if this is guide/profile response format (has user nested inside)
    if (json['user'] != null) {
      // This is the guide profile response - extract user data from nested object
      var userData = json['user'];
      sId = userData['_id'];
      email = userData['email'];
      name = userData['name'];
      phone = userData['phone'];
      role = userData['role'];
      isEmailVerified = userData['isEmailVerified'];
      isActive = userData['isActive'];
      createdAt = userData['createdAt'];
      updatedAt = userData['updatedAt'];
      iV = userData['__v'];
      lastLogin = userData['lastLogin'];
      if (userData['fcmTokens'] != null) {
        fcmTokens = List<String>.from(userData['fcmTokens']);
      }

      // Parse the guide object (the entire response is the guide data)
      guide = GuideModel.fromJson(json);
    } else {
      // This is the standard auth/me response format
      sId = json['_id'];
      email = json['email'];
      name = json['name'];
      phone = json['phone'];
      role = json['role'];
      isEmailVerified = json['isEmailVerified'];
      isActive = json['isActive'];
      createdAt = json['createdAt'];
      updatedAt = json['updatedAt'];
      iV = json['__v'];
      lastLogin = json['lastLogin'];
      if (json['fcmTokens'] != null) {
        fcmTokens = List<String>.from(json['fcmTokens']);
      }

      // Parse guide object if exists
      if (json['guide'] != null) {
        guide = GuideModel.fromJson(json['guide']);
      }
    }
  }
}
