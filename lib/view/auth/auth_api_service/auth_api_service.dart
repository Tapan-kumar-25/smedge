import 'package:dio/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:smedge/network/api_constants.dart';

import '../../dash_board/model/personal_details_screen.dart';
import '../model/resume_sign_up_model.dart';
import '../model/sign_up_email_model.dart';
import '../model/uae_pass_complete_model.dart';
import '../model/uae_pass_model.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  @POST(ApiConstants.refreshToken)
  Future<dynamic> refreshToken(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.checkEmail)
  Future<SignupEmailModel> checkEmail(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.checkPhone)
  Future<SignupEmailModel> checkPhone(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.register)
  Future<SignupEmailModel> register(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.emailVerify)
  Future<SignupEmailModel> emailVerify(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.numberVerify)
  Future<SignupEmailModel> phoneVerify(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.signUpUAEPassInitialize)
  Future<UaePassModel> initiateKyc(@Body() Map<String, dynamic> body,
  @Header("X-Device-Integrity") String integrity,
  @Header("X-Device-Fingerprint") String deviceFingerprint,
  @Header("X-Device-Platform") String devicePlatform,
      );

  @POST(ApiConstants.signUpUAEPassComplete)
  Future<UAEPassCompleteModel> kycComplete(@Body() Map<String, dynamic> body,
      @Header("X-Device-Integrity") String integrity,
      @Header("X-Device-Fingerprint") String deviceFingerprint,
      @Header("X-Device-Platform") String devicePlatform,
      );

  @POST(ApiConstants.kycSkip)
  Future<SignupEmailModel> kycSkip(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.signUpAddCompany)
  Future<dynamic> saveCompany(@Body() Map<String, dynamic> body);

  @GET(ApiConstants.resumeSignUp)
  Future<ResumeSignupModel> resumeSignup(
    @Query("signup_session_token") String signupSessionToken,
  );

  @POST(ApiConstants.resandOtp)
  Future<dynamic> resendOtp(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.signIn)
  Future<dynamic> signIn(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.signInOtpVerification)
  Future<dynamic> signInOtpVerify(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.signInOtpResend)
  Future<dynamic> signInOtpVResend(@Body() Map<String, dynamic> body);

  @POST(ApiConstants.signUpUAEPassInitiateAPI)
  Future<UaePassModel> signUpWithUAEPass(
      @Body() Map<String, dynamic> body,
      @Header("X-Device-Integrity") String integrity,
      @Header("X-Device-Fingerprint") String deviceFingerprint,
      @Header("X-Device-Platform") String devicePlatform,
      );

  @POST(ApiConstants.signUpUAEPassCompleteAPI)
  Future<UAEPassCompleteModel> signUpWithUAEPassCompleted(
      @Body() Map<String, dynamic> body,
      @Header("X-Device-Integrity") String integrity,
      @Header("X-Device-Fingerprint") String deviceFingerprint,
      @Header("X-Device-Platform") String devicePlatform,
      );

  @POST(ApiConstants.signInWithUAEPassInitiate)
  Future<UaePassModel> signInWithUAEPass(
      @Body() Map<String, dynamic> body,
      @Header("X-Device-Integrity") String integrity,
      @Header("X-Device-Fingerprint") String deviceFingerprint,
      @Header("X-Device-Platform") String devicePlatform,
      );

  @POST(ApiConstants.signInWithUAEPassCompleted)
  Future<UAEPassCompleteModel> signInWithUAEPassCompleted(
      @Body() Map<String, dynamic> body,
      @Header("X-Device-Integrity") String integrity,
      @Header("X-Device-Fingerprint") String deviceFingerprint,
      @Header("X-Device-Platform") String devicePlatform,
      );

  /// Personal Details///
 @GET(ApiConstants.personalDetails)
  Future<PersonalDetailsModel> fetchPersonalDetails();
 @PATCH(ApiConstants.editPersonalDetails)
  Future<dynamic> editPersonalDetails(@Body() Map<String, dynamic> body);
  @GET(ApiConstants.businessDetails)
  Future<dynamic> fetchBusinessDetails();
  @POST(ApiConstants.addCompany)
  Future<dynamic> addCompany(@Body() Map<String, dynamic> body);
}
