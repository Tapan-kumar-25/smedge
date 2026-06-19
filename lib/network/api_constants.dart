class ApiConstants {
  static const String baseTestUrl = "https://test-api.smedge.co/api";
  /// Sign Up///
  static const String refreshToken = "/api/auth/refresh";
  static const String checkEmail = "/auth/signup/check-email";
  static const String checkPhone = "/auth/signup/check-phone";
  static const String register = "/auth/signup/register";
  static const String emailVerify = "/auth/signup/email/verify";
  static const String numberVerify = "/auth/signup/phone/verify";
  static const String signUpUAEPassInitialize ="/auth/signup/kyc/uaepass/initiate";
  static const String signUpUAEPassComplete ="/auth/signup/kyc/uaepass/complete";
  static const String kycSkip = "/auth/signup/kyc/skip";
  static const String signUpAddCompany = "/auth/signup/company";
  static const String resumeSignUp = "/auth/signup/resume";
  static const String resandOtp = "/auth/otp/resend";
  ///Sign Up with UAE pass///
  static const String signUpUAEPassInitiateAPI = "/auth/signup/uaepass/initiate";
  static const String signUpUAEPassCompleteAPI = "/auth/signup/uaepass/complete";

  /// Sign In///
 static const String signIn = "/auth/signin/password";
 static const String signInOtpVerification = "/auth/signin/email/verify";
 static const String signInOtpResend = "/auth/signin/otp/resend";
 static const String signInWithUAEPassInitiate = "/auth/signin/uaepass/initiate";
 static const String signInWithUAEPassCompleted = "/auth/signin/uaepass/complete";


 ///personal details///
 static const String personalDetails = "/profile/personal";
 static const String editPersonalDetails = "/profile/personal";
 static const String businessDetails = "/profile/businesses";
 static const String addCompany = "/profile/businesses";
}
