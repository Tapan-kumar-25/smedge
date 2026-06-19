import '../model/resume_sign_up_model.dart';
import '../model/uae_pass_model.dart';

abstract class AuthRepository {

  Future<dynamic> refreshToken(String refreshToken);
  Future<dynamic> checkEmail(String email);
  Future<dynamic> checkPhone(String phone);
  Future<dynamic> register(Map<String, dynamic> body);
  Future<dynamic> verifyEmail(Map<String, dynamic> body);
  Future<dynamic> verifyPhone(Map<String, dynamic> body);
  Future<dynamic> initiateKyc({required String signupSessionToken});
  Future<dynamic> kycComplete(Map<String, dynamic> body);
  Future<dynamic> skipKyc({required String signupSessionToken});
  Future<dynamic> saveCompany({required Map<String, dynamic> body});
  Future<ResumeSignupModel> resumeSignup({required String signupSessionToken});
  Future<dynamic> resendOtp({
    required String signupSessionToken,
    required String channel,
  });
  Future<dynamic> signIn({required Map<String, dynamic> body});
  Future<dynamic> signInOtpVerify({required Map<String, dynamic> body});
  Future<dynamic> signInOtpResend({required Map<String, dynamic> body});
  Future<dynamic> signupWithUaePass({required Map<String, dynamic> body});
  Future<dynamic> signupWithUaePassCompleted({required Map<String, dynamic> body});
  Future<dynamic> signInWithUaePass({required Map<String, dynamic> body});
  Future<dynamic> signInWithUaePassCompleted({required Map<String, dynamic> body});
}