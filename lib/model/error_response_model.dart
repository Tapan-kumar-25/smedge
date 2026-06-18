class ErrorResponseModel {

  String? errorCode;
  String? message;
  String? requestId;
  String? timestamp;

  ErrorResponseModel({
    this.errorCode,
    this.message,
    this.requestId,
    this.timestamp,
  });

  ErrorResponseModel.fromJson(
      Map<String, dynamic> json) {

    errorCode =
        json["error_code"] ?? "";

    message =
        json["message"] ?? "";

    requestId =
        json["request_id"] ?? "";

    timestamp =
        json["timestamp"] ?? "";
  }

  Map<String, dynamic> toJson() {

    final Map<String, dynamic> data = {};

    data["error_code"] =
        errorCode ?? "";

    data["message"] =
        message ?? "";

    data["request_id"] =
        requestId ?? "";

    data["timestamp"] =
        timestamp ?? "";

    return data;
  }
}