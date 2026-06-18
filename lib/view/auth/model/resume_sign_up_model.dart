class ResumeSignupModel {
  ResumeData? data;
  String? requestId;
  String? timestamp;

  ResumeSignupModel({
    this.data,
    this.requestId,
    this.timestamp,
  });

  ResumeSignupModel.fromJson(Map<String, dynamic> json) {
    data = json["data"] != null
        ? ResumeData.fromJson(json["data"])
        : null;

    requestId = json["request_id"] ?? "";
    timestamp = json["timestamp"] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      "data": data?.toJson(),
      "request_id": requestId ?? "",
      "timestamp": timestamp ?? "",
    };
  }
}

class ResumeData {
  String? currentStep;
  List<String>? completedSteps;
  String? expiresAt;

  ResumeData({
    this.currentStep,
    this.completedSteps,
    this.expiresAt,
  });

  ResumeData.fromJson(Map<String, dynamic> json) {
    currentStep = json["current_step"] ?? "";

    completedSteps = json["completed_steps"] != null
        ? List<String>.from(json["completed_steps"])
        : [];

    expiresAt = json["expires_at"] ?? "";
  }

  Map<String, dynamic> toJson() {
    return {
      "current_step": currentStep ?? "",
      "completed_steps": completedSteps ?? [],
      "expires_at": expiresAt ?? "",
    };
  }
}