import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/constants/strings.dart';
import 'package:smedge/utils/shared_preference_utils.dart';
import 'package:smedge/view/auth/model/sign_up_email_model.dart';

import '../../common_files/utils.dart';
import '../../network/app_exception.dart';
import '../../provider/provider.dart';
import '../../utils/router/app_routes.dart';
import 'model/resume_sign_up_model.dart';
import 'model/uae_pass_complete_model.dart';
import 'model/uae_pass_model.dart';



final refreshTokenNotifier =
FutureProvider.autoDispose<dynamic>((ref) async {
  final authState = ref.watch(authProvider);
  final repository = ref.watch(authRepositoryProvider);

  try {
    await Utils.getRefreshToken();

    if (Utils.refreshToken.isEmpty) {
      throw AppException(
        message: "Refresh token not found",
        errorCode: "NO_REFRESH_TOKEN",
      );
    }

    print("Refresh Token: ${Utils.refreshToken}");
    print("Device Token: ${Utils.deviceId}");

    final response = await repository.refreshToken(Utils.refreshToken);

    print("Refresh API Response: $response");

   if(response != null){
     final data = SignupEmailModel.fromJson(response);
     if (data.data != null) {
       SharedPreferenceUtils.setString(
         Strings.ACCESS_TOKEN,
         data.data!.accessToken ?? "",
       );

       SharedPreferenceUtils.setString(
         Strings.REFRESH_TOKEN,
         data.data!.refreshToken ?? "",
       );
       print("Access Token Saved");
       print("Refresh Token Saved");
   }}
    await Utils.getAllData();
    return response;
  } on DioException catch (e, stackTrace) {
    print("========== REFRESH TOKEN ERROR ==========");
    print("Type: ${e.type}");
    print("Status Code: ${e.response?.statusCode}");
    print("Response Data: ${e.response?.data}");
    print("Error: $e");
    print(stackTrace);

    final responseData = e.response?.data;

    throw AppException(
      message: responseData?["message"] ?? "Server Error",
      errorCode: responseData?["error_code"] ?? "SERVER_ERROR",
    );
  } on AppException catch (e) {
    authState.setError(e.message);
    rethrow;
  } catch (e, stackTrace) {
    print("========== UNKNOWN ERROR ==========");
    print(e);
    print(stackTrace);

    throw AppException(
      message: e.toString(),
      errorCode: "UNKNOWN",
    );
  }
});
///refresh
final checkEmailNotifier =
FutureProvider.autoDispose.family<SignupEmailModel, String>(
      (ref, email) async {
    final authState = ref.watch(authProvider);
    final repository = ref.watch(authRepositoryProvider);

    try {
      final response = await repository.checkEmail(email);
      authState.setSignupEmailResponse(response);

      return response;
    } on AppException catch (e) {
      authState.setError(e.message);
      Utils.showErrorSnackBar(authState.context, e.message);
      rethrow;
    } catch (e) {
      Utils.showErrorSnackBar(authState.context, "Something went wrong");
      throw AppException(
        message: "Something went wrong",
        errorCode: "UNKNOWN",
      );
    }
  },
);
final checkPhoneNotifier =
FutureProvider.autoDispose.family<SignupEmailModel, String>(
      (ref, number) async {
    final authState = ref.watch(authProvider);
    final repository = ref.watch(authRepositoryProvider);

    try {
      final response = await repository.checkPhone(number);
      authState.setSignupEmailResponse(response);

      return response;
    } on AppException catch (e) {
      authState.setError(e.message);
      Utils.showErrorSnackBar(authState.context, e.message);
      rethrow;
    } catch (e) {
      Utils.showErrorSnackBar(authState.context, "Something went wrong");
      throw AppException(
        message: "Something went wrong",
        errorCode: "UNKNOWN",
      );
    }
  },
);

final emailSignUpNotifier =
FutureProvider.family<SignupEmailModel, Map<String, dynamic>>(
      (ref, body) async {
    final authState = ref.watch(authProvider);
    final repository = ref.watch(authRepositoryProvider);

    try {
      final data = await repository.register(body);
      authState.setSignupEmailResponse(data);
      final token = data.data?.signupSessionToken;
      if(token != null){
        await SharedPreferenceUtils.setString(Strings.SIGNUP_SESSION, token);
      await  SharedPreferenceUtils.setString("SIGNUP_SESSION_EXPIRY", DateTime.now().toString());
        Utils.showSnackBar(authState.context, "OTP Send to your email and mobile number", Colors.green);
        await Utils.getSignUpSession();
        Navigator.pushReplacementNamed(authState.context, AppRoutes.numberEmailVerify);
      }

      return data;
    } on AppException catch (e) {
      authState.setError(e.message);
      Utils.showErrorSnackBar(authState.context, e.message);
      rethrow;
    } catch (e) {
      Utils.showErrorSnackBar(authState.context, "Something went wrong");
      throw AppException(
        message: "Something went wrong",
        errorCode: "UNKNOWN",
      );
    }finally{
      authState.setLoading(false);
    }
  },
);

final verifyEmailNotifier = FutureProvider.autoDispose.
family<SignupEmailModel, Map<String, dynamic>>((ref, body)async{
  final authState = ref.watch(authProvider);
  final repository = ref.watch(authRepositoryProvider);

  try{
    final response = await repository.verifyEmail(body);
    final token = response.data?.signupSessionToken;
    if(token != null){
      await SharedPreferenceUtils.setString(Strings.SIGNUP_SESSION, token);
      Utils.showSnackBar(authState.context, "Email verification completed", Colors.green);
      authState.setEmailVerify(true);
    }
    return response;
  }on AppException catch(e){
    authState.setError(e.message);
    Utils.showErrorSnackBar(authState.context, e.message);
    rethrow;
  }catch (e) {
    Utils.showErrorSnackBar(authState.context, "Something went wrong");
    throw AppException(message: "Something went wrong", errorCode: "UNKNOWN",);
  }finally{
    authState.setOtpVerifyLoading(false);
  }
});
final verifyPhoneNotifier = FutureProvider.autoDispose.
family<SignupEmailModel, Map<String, dynamic>>((ref, body)async{
  final authState = ref.watch(authProvider);
  final repository = ref.watch(authRepositoryProvider);

  try{
    final response = await repository.verifyPhone(body);
    final token = response.data?.signupSessionToken;
    if(token != null){
      await SharedPreferenceUtils.setString(Strings.SIGNUP_SESSION, token);
      Utils.showSnackBar(authState.context, "Phone number verification completed", Colors.green);
      authState.setPhoneVerify(true);
    }
    return response;
  }on AppException catch(e){
    authState.setError(e.message);
    Utils.showErrorSnackBar(authState.context, e.message);
    rethrow;
  }catch (e) {
    Utils.showErrorSnackBar(authState.context, "Something went wrong");
    throw AppException(message: "Something went wrong", errorCode: "UNKNOWN",);
  }finally{
    authState.setOtpVerifyLoading(false);
  }
});


final uaePassVerification = FutureProvider.family.
autoDispose<UaePassModel, String>((ref, signUpToken) async {
  final authState = ref.watch(authProvider);
  final repository = ref.watch(authRepositoryProvider);
  try {
    var response = await repository.initiateKyc(signupSessionToken: signUpToken);
    return response;
  } on AppException catch (e) {
    Utils.showSnackBar(authState.context, e.message, Colors.red);

    rethrow;
  } catch (e) {
    Utils.showSnackBar(authState.context, "Something went wrong", Colors.red);

    throw AppException(message: "Something went wrong", errorCode: "UNKNOWN");
  }
});

final signUpUaePassCompleteProvider = FutureProvider.family.
autoDispose<UAEPassCompleteModel, Map<String,dynamic>>((ref, body)async{
  final authState = ref.watch(authProvider);
  final repository = ref.watch(authRepositoryProvider);
  try{
    var response =await repository.kycComplete(body);
    print("response ====== ]]] ==== ${response.data?.user}");
    authState.setUAEPassCompleteData(response);
    final token = response.data?.signupSessionToken;
    if(token != null){
      await SharedPreferenceUtils.setString(Strings.SIGNUP_SESSION, token);
      // await  SharedPreferenceUtils.setString("SIGNUP_SESSION_EXPIRY", DateTime.now().toString());
      Utils.showSnackBar(authState.context, "UAE pass Verification Completed", Colors.green);
      await Utils.getSignUpSession();
      authState.loadUAEPassCompleteData();
      Navigator.pushReplacementNamed(authState.context, AppRoutes.companyDetails);
    }
    return response;
  }on AppException catch(e){
    authState.setError(e.message);
    Utils.showErrorSnackBar(authState.context, e.message);
    rethrow;
  } catch (e) {
    Utils.showErrorSnackBar(authState.context,"Something went wrong");
    throw AppException(message: "Something went wrong", errorCode: "UNKNOWN");
  } finally {
    authState.setUaePassLoading(false);
  }
});

final skipKycNotifier = FutureProvider.family
    .autoDispose<SignupEmailModel, String>((ref, otp) async {
      final authState = ref.watch(authProvider);

      final repository = ref.watch(authRepositoryProvider);

      try {
        final response = await repository.skipKyc(
          signupSessionToken: Utils.signUpSession,
        );
        authState.setSignupEmailResponse(response);
        final token = response.data?.signupSessionToken;
        if (token != null) {
          await SharedPreferenceUtils.setString(Strings.SIGNUP_SESSION, token);
          Navigator.pushReplacementNamed(
            authState.context,
            AppRoutes.companyDetails,
          );
        }
        return response;
      } on AppException catch (e) {
        authState.setError(e.message);

        Utils.showSnackBar(authState.context, e.message, Colors.red);

        rethrow;
      } catch (e) {
        Utils.showSnackBar(
          authState.context,
          "Something went wrong",
          Colors.red,
        );

        throw AppException(
          message: "Something went wrong",
          errorCode: "UNKNOWN",
        );
      } finally {
        authState.setOtpVerifyLoading(false);
      }
    });

final resumeSignupNotifier = FutureProvider.
autoDispose<ResumeSignupModel>((ref) async {
  final authState = ref.watch(authProvider);

  final repository = ref.watch(authRepositoryProvider);

  try {
    final response = await repository.resumeSignup(
      signupSessionToken: Utils.signUpSession,
    );

    final currentStep = response.data?.currentStep ?? "";

    if (currentStep == "EMAIL_VERIFY") {
      Navigator.pushReplacementNamed(authState.context, AppRoutes.numberEmailVerify);
    // } else if (currentStep == "PHONE_VERIFY") {
    //   Navigator.pushReplacementNamed(authState.context, AppRoutes.identity);
    } else if (currentStep == "NATIONAL_ID" || currentStep =="KYC") {
      Navigator.pushReplacementNamed(
        authState.context,
        AppRoutes.idVerification,
      );
    } else if (currentStep == "COMPANY" || currentStep == "BUSINESS_INFO") {
      Navigator.pushReplacementNamed(
        authState.context,
        AppRoutes.companyDetails,
      );
    } else {
      Navigator.pushReplacementNamed(authState.context, AppRoutes.signUp);
    }

    return response;
  } on AppException catch (e) {
    Utils.showSnackBar(authState.context, e.message, Colors.red);
    Navigator.pushReplacementNamed(authState.context, AppRoutes.signUp);
    rethrow;
  } catch (e) {
    Utils.showSnackBar(authState.context, "Something went wrong", Colors.red);

    throw AppException(message: "Something went wrong", errorCode: "UNKNOWN");
  } finally {
    authState.setLoading(false);
  }
});

final resendOtpNotifier = FutureProvider.
family.autoDispose<dynamic, String>((ref, channel) async {
  final authState = ref.watch(authProvider);

  final repository = ref.watch(authRepositoryProvider);

  try {
    var data = await repository.resendOtp(
      signupSessionToken: Utils.signUpSession,
      channel: channel,
    );
    Utils.showSnackBar(
      authState.context,
      "OTP resent successfully",
      Colors.green,
    );
    return data;
  } on AppException catch (e) {
    String message = e.message;
    if (e.errorCode == "OTP_COOLDOWN") {
      message = "Wait a few seconds before requesting another OTP";
    } else if (e.errorCode == "OTP_MAX_RESENDS") {
      message = "You have reached maximum resend attempts";
    }
    Utils.showSnackBar(authState.context, message, Colors.red);

    rethrow;
  } catch (e) {
    Utils.showSnackBar(authState.context, "Something went wrong", Colors.red);

    throw AppException(message: "Something went wrong", errorCode: "UNKNOWN");
  } finally {
    authState.setResentOtpLoading(false);
  }
});

final saveCompanyDetails = FutureProvider.family.autoDispose
<SignupEmailModel, Map<String, dynamic>>((ref, body) async {
      final authState = ref.watch(authProvider);
      final repository = ref.watch(authRepositoryProvider);

      try {
        final response = await repository.saveCompany(body: body);
        if (response != null) {
          final data = SignupEmailModel.fromJson(response);
          if (data.data != null) {
            Utils.showSnackBar(
              authState.context,
              "Registration successful",
              Colors.green,
            );
            authState.setCurrentIndex(0);
            SharedPreferenceUtils.setString(
              Strings.ACCESS_TOKEN,
              data.data!.accessToken ?? "",
            );

            SharedPreferenceUtils.setString(
              Strings.REFRESH_TOKEN,
              data.data!.refreshToken ?? "",
            );

            SharedPreferenceUtils.setInt(
              Strings.USER_ID,
              data.data!.userId ?? 0,
            );

            SharedPreferenceUtils.setInt(
              Strings.BUSINESS_ID,
              data.data!.businessId ?? 0,
            );

            SharedPreferenceUtils.setBool(Strings.IS_LOGIN, true);

            Navigator.pushReplacementNamed(
              authState.context,
              AppRoutes.dashboard,
            );
          }

          return data;
        }

        throw AppException(
          message: "Empty response",
          errorCode: "EMPTY_RESPONSE",
        );
      } on AppException catch (e) {
        Utils.showErrorSnackBar(authState.context, e.message);
        rethrow;
      } catch (e) {
        Utils.showErrorSnackBar(authState.context, "Something went wrong");

        throw AppException(
          message: "Something went wrong",
          errorCode: "UNKNOWN",
        );
      } finally {
        authState.setLoading(false);
      }
    });


final signInNotifier = FutureProvider.family.autoDispose
<SignupEmailModel, Map<String, dynamic>>((ref, body) async {
  final authState = ref.watch(authProvider);
  final repository = ref.watch(authRepositoryProvider);

  try {
    final response = await repository.signIn(body: body);
    if (response != null) {
      final data = SignupEmailModel.fromJson(response);
      if (data.data != null) {
        Utils.showSnackBar(
          authState.context,
          "OTP sent to your register email address",
          Colors.green,
        );
      await  SharedPreferenceUtils.setString(
          Strings.SIGN_IN_SESSION,
          data.data!.signInSessionToken ?? "",
        );
        await Utils.getSignInToken();
        Navigator.pushNamedAndRemoveUntil(
          authState.context,
          AppRoutes.signInOTPVerification,
              (route) => false,
          arguments: body['email'],
        );
      }

      return data;
    }

    throw AppException(
      message: "Empty response",
      errorCode: "EMPTY_RESPONSE",
    );
  } on AppException catch (e) {
    Utils.showErrorSnackBar(authState.context, e.message);
    rethrow;
  } catch (e) {
    Utils.showErrorSnackBar(authState.context, "Something went wrong");

    throw AppException(
      message: "Something went wrong",
      errorCode: "UNKNOWN",
    );
  } finally {
    authState.setLoading(false);
  }
});

final signInOtpVerificationNotifier = FutureProvider.family.autoDispose
<SignupEmailModel, Map<String, dynamic>>((ref, body) async {
  final authState = ref.watch(authProvider);
  final repository = ref.watch(authRepositoryProvider);

  try {
    final response = await repository.signInOtpVerify(body: body);
    if (response != null) {
      final data = SignupEmailModel.fromJson(response);
      if (data.data != null) {
        Utils.showSnackBar(
          authState.context,
          "Login successful",
          Colors.green,
        );
        await  SharedPreferenceUtils.setString(
          Strings.SIGN_IN_SESSION,
          data.data!.signInSessionToken ?? "",
        );
        await  SharedPreferenceUtils.setBool(Strings.IS_LOGIN, true);
        await Utils.getSignInToken();
        Navigator.pushNamedAndRemoveUntil(
          authState.context,
          AppRoutes.dashboard,
              (route) => false,
        );
      }
      return data;
    }

    throw AppException(
      message: "Empty response",
      errorCode: "EMPTY_RESPONSE",
    );
  } on AppException catch (e) {
    Utils.showErrorSnackBar(authState.context, e.message);
    rethrow;
  } catch (e) {
    Utils.showErrorSnackBar(authState.context, "Something went wrong");

    throw AppException(
      message: "Something went wrong",
      errorCode: "UNKNOWN",
    );
  } finally {
    authState.setLoading(false);
  }
});

final signInResendOtpNotifier = FutureProvider.family.autoDispose
<dynamic, Map<String,dynamic>>((ref, body) async {
  final authState = ref.watch(authProvider);

  final repository = ref.watch(authRepositoryProvider);

  try {
    var data = await repository.signInOtpResend(body: body);
    Utils.showSnackBar(
      authState.context,
      "OTP resent successfully",
      Colors.green,
    );
    return data;
  } on AppException catch (e) {
    String message = e.message;
    if (e.errorCode == "OTP_COOLDOWN") {
      message = "Wait a few seconds before requesting another OTP";
    } else if (e.errorCode == "OTP_MAX_RESENDS") {
      message = "You have reached maximum resend attempts";
    }
    Utils.showSnackBar(authState.context, message, Colors.red);

    rethrow;
  } catch (e) {
    Utils.showSnackBar(authState.context, "Something went wrong", Colors.red);

    throw AppException(message: "Something went wrong", errorCode: "UNKNOWN");
  } finally {
    authState.setResentOtpLoading(false);
  }
});

final signUpWithUAEPassNotifier = FutureProvider.family.
autoDispose<UaePassModel, Map<String,dynamic>>((ref, body)async{
  final authState = ref.watch(authProvider);
  final repository = ref.watch(authRepositoryProvider);
  try{
    var response =await repository.signupWithUaePass(body: body);
    print("===== Response ===== $response } =======");
    return response;
  }on AppException catch(e){
    authState.setError(e.message);
    Utils.showErrorSnackBar(authState.context, e.message);
    rethrow;
  } catch (e) {
    Utils.showErrorSnackBar(authState.context,"Something went wrong");
    throw AppException(message: "Something went wrong", errorCode: "UNKNOWN");
  } finally {
    authState.setUaePassLoading(false);
  }
});

final uaePassCompleteProvider = FutureProvider.family.
autoDispose<UAEPassCompleteModel, Map<String,dynamic>>((ref, body)async{
  final authState = ref.watch(authProvider);
  final repository = ref.watch(authRepositoryProvider);
  try{
    var response =await repository.signupWithUaePassCompleted(body: body);
    print("response ====== ]]] ==== ${response.data?.user}");
      authState.setUAEPassCompleteData(response);
    final token = response.data?.signupSessionToken;
    if(token != null){
      await SharedPreferenceUtils.setString(Strings.SIGNUP_SESSION, token);
      await  SharedPreferenceUtils.setString("SIGNUP_SESSION_EXPIRY", DateTime.now().toString());
      Utils.showSnackBar(authState.context, "UAE pass Verification Completed", Colors.green);
      await Utils.getSignUpSession();
      authState.loadUAEPassCompleteData();
      Navigator.pushReplacementNamed(authState.context, AppRoutes.personalDetails);
    }
    return response;
  }on AppException catch(e){
    authState.setError(e.message);
    Utils.showErrorSnackBar(authState.context, e.message);
    rethrow;
  } catch (e) {
    Utils.showErrorSnackBar(authState.context,"Something went wrong");
    throw AppException(message: "Something went wrong", errorCode: "UNKNOWN");
  } finally {
    authState.setUaePassLoading(false);
  }
});


final signInWithUAEPassNotifier = FutureProvider.family.
autoDispose<UaePassModel, Map<String,dynamic>>((ref, body)async{
  final authState = ref.watch(authProvider);
  final repository = ref.watch(authRepositoryProvider);
  try{
    var response =await repository.signInWithUaePass(body: body);
    print("===== Response ===== $response } =======");
    return response;
  }on AppException catch(e){
    authState.setError(e.message);
    Utils.showErrorSnackBar(authState.context, e.message);
    rethrow;
  } catch (e) {
    Utils.showErrorSnackBar(authState.context,"Something went wrong");
    throw AppException(message: "Something went wrong", errorCode: "UNKNOWN");
  } finally {
    authState.setUaePassLoading(false);
  }
});

final signInUaePassCompleteProvider = FutureProvider.family.
autoDispose<UAEPassCompleteModel, Map<String,dynamic>>((ref, body)async{
  final authState = ref.watch(authProvider);
  final repository = ref.watch(authRepositoryProvider);
  try{
    var response =await repository.signInWithUaePassCompleted(body: body);
    print("response ====== ]]] ==== ${response.data?.user}");
    authState.setUAEPassCompleteData(response);
    final token = response.data?.signupSessionToken;
    if(token != null){
      Utils.showSnackBar(authState.context, "UAE pass Verification Completed", Colors.green);
      authState.loadUAEPassCompleteData();
      Navigator.pushReplacementNamed(authState.context, AppRoutes.dashboard);
    }
    return response;
  }on AppException catch(e){
    authState.setError(e.message);
    Utils.showErrorSnackBar(authState.context, e.message);
    rethrow;
  } catch (e) {
    Utils.showErrorSnackBar(authState.context,"Something went wrong");
    throw AppException(message: "Something went wrong", errorCode: "UNKNOWN");
  } finally {
    authState.setUaePassLoading(false);
  }
});