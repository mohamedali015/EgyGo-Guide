class GuideModel {
  String? sId;
  PhotoModel? photo;
  LocationModel? location;
  UserBasicInfo? user;
  List<String>? provinces; // Province IDs
  List<ProvinceDetail>?
      provinceDetails; // Full province objects from GET response
  String? name;
  bool? isVerified;
  bool? isActive;
  bool? canEnterArchaeologicalSites;
  bool? isLicensed;
  List<String>? languages;
  String? bio;
  List<DocumentModel>? documents;
  double? rating;
  int? ratingCount;
  int? totalTrips;
  List<dynamic>? gallery;
  List<dynamic>? availability;
  String? createdAt;
  String? updatedAt;
  int? iV;
  dynamic province; // Can be string ID or object
  String? slug;
  double? pricePerHour;

  GuideModel({
    this.sId,
    this.photo,
    this.location,
    this.user,
    this.provinces,
    this.provinceDetails,
    this.name,
    this.isVerified,
    this.isActive,
    this.canEnterArchaeologicalSites,
    this.isLicensed,
    this.languages,
    this.bio,
    this.documents,
    this.rating,
    this.ratingCount,
    this.totalTrips,
    this.gallery,
    this.availability,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.province,
    this.slug,
    this.pricePerHour,
  });

  GuideModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    photo = json['photo'] != null ? PhotoModel.fromJson(json['photo']) : null;
    location = json['location'] != null
        ? LocationModel.fromJson(json['location'])
        : null;
    user = json['user'] != null ? UserBasicInfo.fromJson(json['user']) : null;

    // Handle provinces - can be array of strings or array of objects
    if (json['provinces'] != null) {
      if (json['provinces'] is List && json['provinces'].isNotEmpty) {
        if (json['provinces'][0] is String) {
          // Array of IDs
          provinces = List<String>.from(json['provinces']);
        } else {
          // Array of objects
          provinceDetails = <ProvinceDetail>[];
          provinces = <String>[];
          json['provinces'].forEach((v) {
            var provinceDetail = ProvinceDetail.fromJson(v);
            provinceDetails!.add(provinceDetail);
            provinces!.add(provinceDetail.sId ?? '');
          });
        }
      }
    }

    name = json['name'];
    isVerified = json['isVerified'];
    isActive = json['isActive'];
    canEnterArchaeologicalSites = json['canEnterArchaeologicalSites'];
    isLicensed = json['isLicensed'];
    languages =
        json['languages'] != null ? List<String>.from(json['languages']) : null;
    bio = json['bio'];
    if (json['documents'] != null) {
      documents = <DocumentModel>[];
      json['documents'].forEach((v) {
        documents!.add(DocumentModel.fromJson(v));
      });
    }
    rating = json['rating']?.toDouble();
    ratingCount = json['ratingCount'];
    totalTrips = json['totalTrips'];
    gallery = json['gallery'];
    availability = json['availability'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    province = json['province'];
    slug = json['slug'];
    pricePerHour = json['pricePerHour']?.toDouble();
  }
}

class PhotoModel {
  String? url;
  String? publicId;

  PhotoModel({this.url, this.publicId});

  PhotoModel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    publicId = json['publicId'];
  }
}

class LocationModel {
  String? type;
  List<double>? coordinates;

  LocationModel({this.type, this.coordinates});

  LocationModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'] != null
        ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
        : null;
  }
}

class UserBasicInfo {
  String? sId;
  String? email;
  String? name;
  String? phone;
  String? role;
  bool? isEmailVerified;
  bool? isActive;
  List<String>? fcmTokens;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? lastLogin;

  UserBasicInfo({
    this.sId,
    this.email,
    this.name,
    this.phone,
    this.role,
    this.isEmailVerified,
    this.isActive,
    this.fcmTokens,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.lastLogin,
  });

  UserBasicInfo.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    name = json['name'];
    phone = json['phone'];
    role = json['role'];
    isEmailVerified = json['isEmailVerified'];
    isActive = json['isActive'];
    fcmTokens =
        json['fcmTokens'] != null ? List<String>.from(json['fcmTokens']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    lastLogin = json['lastLogin'];
  }
}

class ProvinceDetail {
  String? sId;
  String? slug;
  String? name;
  String? id;

  ProvinceDetail({this.sId, this.slug, this.name, this.id});

  ProvinceDetail.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    slug = json['slug'];
    name = json['name'];
    id = json['id'];
  }
}

class DocumentModel {
  String? url;
  String? publicId;
  String? type;
  String? status;
  String? sId;
  String? uploadedAt;

  DocumentModel({
    this.url,
    this.publicId,
    this.type,
    this.status,
    this.sId,
    this.uploadedAt,
  });

  DocumentModel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    publicId = json['publicId'];
    type = json['type'];
    status = json['status'];
    sId = json['_id'];
    uploadedAt = json['uploadedAt'];
  }
}
