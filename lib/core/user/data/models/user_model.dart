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
  List<String>? fcmTokens; // Add FCM tokens field

  UserModel(
      {this.sId,
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
      this.fcmTokens // Add to constructor
      });

  UserModel.fromJson(Map<String, dynamic> json) {
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
    // Parse fcmTokens array
    if (json['fcmTokens'] != null) {
      fcmTokens = List<String>.from(json['fcmTokens']);
    }
  }
}
