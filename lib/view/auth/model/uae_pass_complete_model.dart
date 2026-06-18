class UAEPassCompleteModel {
  final UAEPassCompleteData? data;
  final String requestId;
  final String timestamp;

  UAEPassCompleteModel({
    this.data,
    required this.requestId,
    required this.timestamp,
  });

  factory UAEPassCompleteModel.fromJson(Map<String, dynamic> json) {
    return UAEPassCompleteModel(
      data: json['data'] != null
          ? UAEPassCompleteData.fromJson(json['data'])
          : null,
      requestId: json['request_id'] ?? "",
      timestamp: json['timestamp'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "data": data?.toJson(),
      "request_id": requestId,
      "timestamp": timestamp,
    };
  }
}

class UAEPassCompleteData {
  final String signupSessionToken;
  final String deviceToken;
  final String nextStep;
  final UAEPassUser? user;

  UAEPassCompleteData({
    required this.signupSessionToken,
    required this.deviceToken,
    required this.nextStep,
    this.user,
  });

  factory UAEPassCompleteData.fromJson(Map<String, dynamic> json) {
    return UAEPassCompleteData(
      signupSessionToken: json['signup_session_token'] ?? "",
      deviceToken: json['device_token'] ?? "",
      nextStep: json['next_step'] ?? "",
      user: json['user'] != null
          ? UAEPassUser.fromJson(json['user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "signup_session_token": signupSessionToken,
      "device_token": deviceToken,
      "next_step": nextStep,
      "user": user?.toJson(),
    };
  }
}

class UAEPassUser {
  final String customerId;
  final String fullName;
  final String email;
  final String phone;

  UAEPassUser({
    required this.customerId,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  factory UAEPassUser.fromJson(Map<String, dynamic> json) {
    return UAEPassUser(
      customerId: json['customer_id'] ?? "",
      fullName: json['full_name'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "customer_id": customerId,
      "full_name": fullName,
      "email": email,
      "phone": phone,
    };
  }
}