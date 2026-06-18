class SignupEmailModel {
  Data? data;
  String? requestId;
  String? timestamp;

  SignupEmailModel({this.data, this.requestId, this.timestamp});

  SignupEmailModel.fromJson(Map<String, dynamic> json) {
    data = json["data"] != null ? Data.fromJson(json["data"]) : null;

    requestId = json["request_id"] ?? "";

    timestamp = json["timestamp"] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (this.data != null) {
      data["data"] = this.data!.toJson();
    }

    data["request_id"] = requestId ?? "";

    data["timestamp"] = timestamp ?? "";

    return data;
  }
}

class Data {
  bool?available;
  String? reason;
  String? signupSessionToken;
  String? signInSessionToken;
  String? maskedEmail;
  int? otpExpiresIn;
  String? nextStep;
  String? maskedPhone;
  String? kycStatus;
  String? kycDeadline;
  String? accessToken;
  String? refreshToken;
  String? tokenType;
  int? expireIn;
  int? userId;
  int? businessId;

  Data({
    this.available,
    this.reason,
    this.signupSessionToken,
    this.signInSessionToken,
    this.maskedEmail,
    this.otpExpiresIn,
    this.nextStep,
    this.maskedPhone,
    this.kycStatus,
    this.kycDeadline,
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expireIn,
    this.userId,
    this.businessId,
  });

  Data.fromJson(Map<String, dynamic> json) {
    available = json['available']??false;
    reason = json["reason"] ?? "";
    signupSessionToken = json["signup_session_token"] ?? "";
    signInSessionToken = json["signin_session_token"] ?? "";

    maskedEmail = json["masked_email"] ?? "";

    otpExpiresIn = json["otp_expires_in"] ?? 0;
    nextStep = json["next_step"] ?? "";
    maskedPhone = json["masked_phone"] ?? "";
    kycStatus = json["kyc_status"] ?? "";
    kycDeadline = json["kyc_deadline"] ?? "";
    accessToken = json["access_token"] ?? "";
    refreshToken = json["refresh_token"] ?? "";
    tokenType = json["token_type"] ?? "";
    expireIn = json["expires_in"] ?? 0;
    userId = json["user_id"] ?? 0;
    businessId = json["business_id"] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['available'] = available??false;
    data["reason"] = reason ?? "";
    data["signup_session_token"] = signupSessionToken ?? "";
    data["signin_session_token"] = signInSessionToken ?? "";

    data["masked_email"] = maskedEmail ?? "";

    data["otp_expires_in"] = otpExpiresIn ?? 0;
    data["masked_phone"] = maskedPhone ?? "";
    data["kyc_status"] = kycStatus ?? "";
    data["kyc_deadline"] = kycDeadline ?? "";
    data["access_token"] = accessToken ?? "";
    data["refresh_token"] = refreshToken ?? "";
    data["token_type"] = tokenType ?? "";
    data["expires_in"] = expireIn ?? 0;
    data["user_id"] = userId ?? 0;
    data["business_id"] = businessId ?? 0;

    return data;
  }
}
