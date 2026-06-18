class UaePassModel {
  UAEPassData data;
  String requestId;
  String timestamp;

  UaePassModel({
    required this.data,
    required this.requestId,
    required this.timestamp,
  });

  factory UaePassModel.fromJson(Map<String, dynamic> json) {
    return UaePassModel(
      data: UAEPassData.fromJson(json['data'] ?? {}),
      requestId: json['request_id'] ?? "",
      timestamp: json['timestamp'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'request_id': requestId,
      'timestamp': timestamp,
    };
  }
}

class UAEPassData {
  String appUrl;
  String appScheme;
  String androidPackage;
  String iosStoreUrl;
  String playStoreUrl;
  String state;
  int expiresIn;

  UAEPassData({
    required this.appUrl,
    required this.appScheme,
    required this.androidPackage,
    required this.iosStoreUrl,
    required this.playStoreUrl,
    required this.state,
    required this.expiresIn,
  });

  factory UAEPassData.fromJson(Map<String, dynamic> json) {
    return UAEPassData(
      appUrl: json['app_url'] ?? "",
      appScheme: json['app_scheme'] ?? "",
      androidPackage: json['android_package'] ?? "",
      iosStoreUrl: json['ios_store_url'] ?? "",
      playStoreUrl: json['play_store_url'] ?? "",
      state: json['state'] ?? "",
      expiresIn: json['expires_in'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_url': appUrl,
      'app_scheme': appScheme,
      'android_package': androidPackage,
      'ios_store_url': iosStoreUrl,
      'play_store_url': playStoreUrl,
      'state': state,
      'expires_in': expiresIn,
    };
  }
}