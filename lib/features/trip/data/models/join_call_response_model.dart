class JoinCallResponseModel {
  bool? success;
  JoinCallData? data;

  JoinCallResponseModel({this.success, this.data});

  JoinCallResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? JoinCallData.fromJson(json['data']) : null;
  }
}

class JoinCallData {
  String? appId;
  String? channelName;
  int? uid;
  String? token;
  int? maxDurationSeconds;
  String? callId;
  dynamic tripId; // Can be String or Object
  String? role;

  JoinCallData({
    this.appId,
    this.channelName,
    this.uid,
    this.token,
    this.maxDurationSeconds,
    this.callId,
    this.tripId,
    this.role,
  });

  JoinCallData.fromJson(Map<String, dynamic> json) {
    appId = json['appId'];
    channelName = json['channelName'];
    uid = json['uid'];
    token = json['token'];
    maxDurationSeconds = json['maxDurationSeconds'];
    callId = json['callId'];
    tripId = json['tripId']; // Can be string or object
    role = json['role'];
  }
}

