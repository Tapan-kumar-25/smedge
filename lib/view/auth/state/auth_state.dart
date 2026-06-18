import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smedge/constants/strings.dart';
import 'package:smedge/view/auth/model/uae_pass_complete_model.dart';
import 'package:smedge/view/auth/model/uae_pass_model.dart';

import '../../../common_files/utils.dart';
import '../../../utils/shared_preference_utils.dart';
import '../model/sign_up_email_model.dart';

class AuthState extends ChangeNotifier {
  BuildContext? _context;
  int _currentIndex = 0;
  int _selectedIndex = 1;
  String _mobileNumber = "";
  String _countryCode = "+971";
  String _nationality = "AE";
  bool _isChecked = false;
  SignupEmailModel? _signupEmailModel;
  bool _isLoading = false;
  bool _isOtpVerifyLoading = false;
  bool _isResentOtpLoading = false;
  String _errorMessage = "";
  Map<String, dynamic> _signUpData = {};
  bool _isEmailVerified = false;
  bool _isMobileVerified = false;
  UAEPassData? _uaePassData;
  bool _isUaePassLoading = false;
  UAEPassCompleteModel? _uaePassCompleteModel;

  BuildContext get context => _context!;

  int get currentIndex => _currentIndex;

  int get selectedIndex => _selectedIndex;

  String get mobileNumber => _mobileNumber;

  String get countryCode => _countryCode;
  String get nationality => _nationality;

  bool get isChecked => _isChecked;

  bool get isLoading => _isLoading;

  bool get isOtpVerifyLoading => _isOtpVerifyLoading;

  bool get isResentOtpLoading => _isResentOtpLoading;

  String get errorMessage => _errorMessage;

  SignupEmailModel? get signupEmailResponse => _signupEmailModel;
  UAEPassCompleteModel? get uaePassCompleteModel => _uaePassCompleteModel;


  Map<String, dynamic> get signUpData => _signUpData;
  bool get isEmailVerified => _isEmailVerified;
  bool get isMobileVerified => _isMobileVerified;
  UAEPassData? get uaePassData => _uaePassData;
  bool get isUaePassLoading => _isUaePassLoading;

  void setContext(BuildContext context) {
    _context = context;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setMobleNumber(String number) {
    _mobileNumber = number;
    notifyListeners();
  }

  void setCountryCode(String code) {
    _countryCode = code;
    notifyListeners();
  }
  void setNationality(String code) {
    _nationality = code;
    notifyListeners();
  }

  void setTermAndCondition(bool isCheck) {
    _isChecked = isCheck;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setOtpVerifyLoading(bool value) {
    _isOtpVerifyLoading = value;
    notifyListeners();
  }

  void setResentOtpLoading(bool value) {
    _isResentOtpLoading = value;
    notifyListeners();
  }

  void setError(String value) {
    _errorMessage = value;
    notifyListeners();
  }

  void setSignupEmailResponse(SignupEmailModel response) {
    _signupEmailModel = response;
    print("_signupEmailModel    ======= {${_signupEmailModel!.data!.signupSessionToken}}");
    notifyListeners();
  }

  void clearError() {
    _errorMessage = "";
    notifyListeners();
  }
  void setSignUpData(Map<String, dynamic> data){
    _signUpData = data;
    notifyListeners();
  }

  bool validateSignUp({
    required String name,
    required String email,
    required String number,
    required String password,
    required String confirmPassword,
  }) {
    if (name.trim().isEmpty) {
      Utils.showErrorSnackBar(context, "Name cannot be empty");
      return false;
    }
    if (email.trim().isEmpty) {
      Utils.showErrorSnackBar(context, "Email cannot be empty",);
      return false;
    }
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email.trim())) {
      Utils.showErrorSnackBar(context, "Enter a valid email",);
      return false;
    }
    if (number.trim().isEmpty) {
      Utils.showErrorSnackBar(context, "Mobile number cannot be empty",);
      return false;
    }
    if (number.trim().length < 9 || number.trim().length > 10) {
      Utils.showErrorSnackBar(
        context,
        "Mobile number must be 9 or 10 digits",
      );
      return false;
    }
    if (password.isEmpty) {
      Utils.showErrorSnackBar(context, "Password cannot be empty",);
      return false;
    }
    if (password.length < 8) {
      Utils.showErrorSnackBar(
          context, "Password must be at least 8 characters");
      return false;
    }
    if (confirmPassword.isEmpty) {
      Utils.showErrorSnackBar(
        context,
        "Confirm password cannot be empty");
      return false;
    }
    if (password != confirmPassword) {
      Utils.showErrorSnackBar(context, "Passwords do not match");
      return false;
    }
    return true;
  }

  bool validateSignIn({required String email, required String password,}){
    if (email.trim().isEmpty) {
      Utils.showErrorSnackBar(context, "Email cannot be empty",);
      return false;
    }
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email.trim())) {
      Utils.showErrorSnackBar(context, "Enter a valid email",);
      return false;
    }
    if (password.isEmpty) {
      Utils.showErrorSnackBar(context, "Password cannot be empty",);
      return false;
    }
    if (password.length < 8) {
      Utils.showErrorSnackBar(
          context, "Password must be at least 8 characters");
      return false;
    }
    return true;
  }

  void setEmailVerify(bool isVerify){
    _isEmailVerified = isVerify;
    notifyListeners();
  }
  void setPhoneVerify(bool isVerify){
    _isMobileVerified = isVerify;
    notifyListeners();
  }

  void setUAEPassData(UAEPassData data){
    _uaePassData = data;
    notifyListeners();
  }
  void setUaePassLoading(bool loading){
    _isUaePassLoading = loading;
    notifyListeners();
  }
  void setUAEPassCompleteData(UAEPassCompleteModel data){
    _uaePassCompleteModel =data;
    SharedPreferenceUtils.setJson(
      Strings.uaePassCompleteData,
      data.toJson(),
    );
    notifyListeners();
  }
  void loadUAEPassCompleteData() {
    final json =
    SharedPreferenceUtils.getJson(Strings.uaePassCompleteData);
    if (json != null) {
      _uaePassCompleteModel = UAEPassCompleteModel.fromJson(json);
      notifyListeners();
    }
  }
}
