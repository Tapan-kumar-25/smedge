import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/provider/provider.dart';

import '../../../common_files/network_checker.dart';
import '../../../constants/strings.dart';
import '../../../local_auth_services.dart';
import '../dashboard_view_model.dart';

class PersonalDetailsScreenDashboard extends ConsumerStatefulWidget {
  const PersonalDetailsScreenDashboard({super.key});

  @override
  ConsumerState<PersonalDetailsScreenDashboard> createState() =>
      _PersonalDetailsScreenDashboardState();
}

class _PersonalDetailsScreenDashboardState
    extends ConsumerState<PersonalDetailsScreenDashboard> {
  final LocalAuthServices _authServices = LocalAuthServices();

  bool _emiratesIdRevealed = false;
  bool _emailRevealed = false;
  bool _phoneRevealed = false;
  String _countryCode = '';
  DateTime? _selectedDob;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emiratesIdController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _currentAddressController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardStateProvider).setContext(context);
    });
    _fetchData();
  }

  void _fetchData() {
    final dashboardState = ref.read(dashboardStateProvider);
    if (dashboardState.personalDetailsModel != null) {
      _emiratesIdController.text =
          dashboardState.personalDetailsModel!.identity.emiratesId.masked;
      _emailController.text =
          dashboardState.personalDetailsModel!.contact.email.masked;
      // _phoneController.text = dashboardState.personalDetailsModel!.contact.phone.masked;
      _splitPhone(dashboardState.personalDetailsModel!.contact.phone.masked);
      _nationalityController.text =
          dashboardState.personalDetailsModel!.identity.nationality;
      _dobController.text =
          dashboardState.personalDetailsModel!.identity.dateOfBirth;
      _fullNameController.text =
          dashboardState.personalDetailsModel!.identity.fullName;
      _addressController.text = "";
      _currentAddressController.text = "";
    }
  }

  void _splitPhone(String phone) {
    if (phone.startsWith('+')) {
      final match = RegExp(r'^(\+\d{1,4})').firstMatch(phone);

      if (match != null) {
        _countryCode = match.group(1)!;
        _phoneController.text = phone.substring(_countryCode.length);
      }
    } else {
      _countryCode = '';
      _phoneController.text = phone;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emiratesIdController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _currentAddressController.dispose();
    super.dispose();
  }

  Future<void> _authenticateAndReveal(String field) async {
    final dashboardState = ref.read(dashboardStateProvider);
    HapticFeedback.lightImpact();

    bool success = await _authServices.authenticate();

    if (!success) {
      Utils.showErrorSnackBar(context, "Authentication failed");
      return;
    }

    switch (field) {
      case "emirates":
        setState(() {
          _emiratesIdRevealed = true;
          _emiratesIdController.text =
              dashboardState.personalDetailsModel!.identity.emiratesId.full;
        });
        Future.delayed(const Duration(seconds: 20), () {
          if (!mounted) return;
          setState(() {
            _emiratesIdRevealed = false;
            _emiratesIdController.text =
                dashboardState.personalDetailsModel!.identity.emiratesId.masked;
          });
        });
        break;

      case "email":
        setState(() {
          _emailRevealed = true;
          _emailController.text =
              dashboardState.personalDetailsModel!.contact.email.full;
        });
        Future.delayed(const Duration(seconds: 20), () {
          if (!mounted) return;

          setState(() {
            _emailRevealed = false;
            _emailController.text =
                dashboardState.personalDetailsModel!.contact.email.masked;
          });
        });
        break;

      case "phone":
        setState(() {
          _phoneRevealed = true;
          // _phoneController.text = dashboardState.personalDetailsModel!.contact.phone.full;
          _splitPhone(dashboardState.personalDetailsModel!.contact.phone.full);
        });
        Future.delayed(const Duration(seconds: 20), () {
          if (!mounted) return;

          setState(() {
            _phoneRevealed = false;
            // _phoneController.text = dashboardState.personalDetailsModel!.contact.phone.masked;
            _splitPhone(
              dashboardState.personalDetailsModel!.contact.phone.masked,
            );
          });
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStateProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Text(
          'Personal Details',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontSize: 17, letterSpacing: -0.3),
        ),
      ),
      body: dashboardState.personalDetailsModel == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Personal details is not available",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  dashboardState.isLoading
                      ? CircularProgressIndicator()
                      : CustomElevatedButton(
                          title: "Retry",
                          onPressed: () {
                            _networkCall();
                          },
                        ),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: Numbers.DOUBLE_NUMBER_4),
                          _buildSubtitle(),
                          SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                          _buildIdentityCard(),
                          SizedBox(height: Numbers.DOUBLE_NUMBER_12),
                          _buildContactCard(),
                          SizedBox(height: Numbers.DOUBLE_NUMBER_12),
                          _buildAddressCard(),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
                    child: SizedBox(
                      width: double.infinity,
                      child: CustomElevatedButton(
                        title: "Save",
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        'Manage & Verify your personal information securely.',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  Widget _buildIdentityCard() {
    final dashboardState = ref.read(dashboardStateProvider);
    final theme = Theme.of(context);
    return CustomContainer(
      padding: Numbers.DOUBLE_NUMBER_12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Identity Information',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              (dashboardState.personalDetailsModel != null &&
                      dashboardState.personalDetailsModel!.identity.verified)
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF2ECC71)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF2ECC71),
                            size: 13,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Color(0xFF2ECC71),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Numbers.DOUBLE_NUMBER_10,
                        vertical: Numbers.DOUBLE_NUMBER_4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.error),
                        borderRadius: BorderRadius.circular(
                          Numbers.DOUBLE_NUMBER_20,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: theme.colorScheme.error,
                            size: Numbers.DOUBLE_NUMBER_14,
                          ),
                          SizedBox(width: Numbers.DOUBLE_NUMBER_4),
                          Text(
                            'Not Verified',
                            style: theme.textTheme.bodySmall!.copyWith(
                              fontSize: Numbers.DOUBLE_NUMBER_12,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),

          const SizedBox(height: 14),

          _buildFieldLabel('Full Name'),
          const SizedBox(height: 6),

          _buildTextField(
            controller: _fullNameController,
            hint: 'Enter full name',
          ),

          SizedBox(height: Numbers.DOUBLE_NUMBER_12),
          if (dashboardState.personalDetailsModel != null &&
              dashboardState.personalDetailsModel!.identity.verified) ...[
            _buildFieldLabel('Emirates ID'),
            const SizedBox(height: 6),

            _buildTextField(
              readOnly: true,
              controller: _emiratesIdController,
              hint: 'Emirates ID',
              suffixIcon: const Icon(Icons.fingerprint, color: Colors.green),
              onSuffixTap: _emiratesIdRevealed
                  ? null
                  : () {
                      _authenticateAndReveal("emirates");
                    },
            ),

            if (!_emiratesIdRevealed) _buildRevealHint(),
          ],
          if (dashboardState.personalDetailsModel != null &&
              !dashboardState.personalDetailsModel!.identity.verified) ...[
            InkWell(
              onTap: () async {
                // await _startUaePassFlow();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      offset: Offset(2, 2),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fingerprint, size: 20, color: Colors.white),
                    SizedBox(width: Numbers.DOUBLE_NUMBER_10),
                    Text(
                      "Get Emirates ID from UAE PASS",
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: Numbers.DOUBLE_NUMBER_12),

          _buildFieldLabel('DOB'),
          const SizedBox(height: 6),

          _buildTextField(
            controller: _dobController,
            hint: "Select date of birth",
            readOnly: true,
            suffixIcon: const Icon(Icons.calendar_month, color: Colors.red),
            onTap: () async {
              //TODO
              // _selectedDob = await showDatePicker(
              //   context: context,
              //   useRootNavigator: false,
              //   firstDate: DateTime(1900),
              //   initialDate: _selectedDob ?? DateTime.now(),
              //   lastDate: DateTime.now(),
              // );
              //
              // if (_selectedDob != null) {
              //   _dobController.text = DateFormat(
              //     'dd / MM / yyyy',
              //   ).format(_selectedDob!);
              // }
            },
          ),

          SizedBox(height: Numbers.DOUBLE_NUMBER_12),

          _buildFieldLabel('Nationality'),
          const SizedBox(height: 6),

          _buildTextField(
            controller: _nationalityController,
            hint: "Nationality",
            readOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return CustomContainer(
      padding: Numbers.DOUBLE_NUMBER_16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 14),

          _buildFieldLabel('Email Address'),
          const SizedBox(height: 6),

          _buildTextField(
            controller: _emailController,
            readOnly: true,
            hint: "Email address",
            suffixIcon: const Icon(Icons.fingerprint, color: Colors.green),
            onSuffixTap: _emailRevealed
                ? null
                : () {
                    _authenticateAndReveal("email");
                  },
          ),

          if (!_emailRevealed) _buildRevealHint(),

          SizedBox(height: Numbers.DOUBLE_NUMBER_12),

          _buildFieldLabel('Contact Number'),
          const SizedBox(height: 6),

          _buildPhoneBox(),

          if (!_phoneRevealed) _buildRevealHint(),
        ],
      ),
    );
  }

  Widget _buildPhoneBox() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(8),
      ),

      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Numbers.DOUBLE_NUMBER_12,
              vertical: Numbers.DOUBLE_NUMBER_10,
            ),
            child: Text(
              _countryCode,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          Container(width: 1, height: 40, color: const Color(0xFFDDDDDD)),

          Expanded(
            child: TextField(
              readOnly: true,
              controller: _phoneController,
              keyboardType: TextInputType.phone,

              decoration: InputDecoration(
                hintText: 'Enter phone number',

                border: InputBorder.none,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),

                suffixIcon: InkWell(
                  onTap: _phoneRevealed
                      ? null
                      : () {
                          _authenticateAndReveal("phone");
                        },

                  child: const Icon(Icons.fingerprint, color: Colors.green),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    final dashboardState = ref.read(dashboardStateProvider);
    return CustomContainer(
      padding: Numbers.DOUBLE_NUMBER_16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Address', style: Theme.of(context).textTheme.titleMedium),

              SizedBox(width: Numbers.DOUBLE_NUMBER_8),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Numbers.DOUBLE_NUMBER_8,
                  vertical: Numbers.DOUBLE_NUMBER_2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Optional',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF888888),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: Numbers.DOUBLE_NUMBER_14),

          _buildFieldLabel('Permanent Address'),

          SizedBox(height: Numbers.DOUBLE_NUMBER_6),

          _buildTextField(
            controller: _addressController,
            hint: 'Enter Permanent Address',
            maxLines: 2,
            readOnly:
                dashboardState.personalDetailsModel!.identity.fullNameEditable,
          ),

          SizedBox(height: Numbers.DOUBLE_NUMBER_10),

          _buildFieldLabel('Current Address'),

          SizedBox(height: Numbers.DOUBLE_NUMBER_6),

          _buildTextField(
            controller: _currentAddressController,
            hint: 'Enter Current Address',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(label, style: Theme.of(context).textTheme.bodySmall);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    VoidCallback? onSuffixTap,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: theme.textTheme.bodyMedium,

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: const Color(0xFFBBBBBB),
        ),

        suffixIcon: suffixIcon != null
            ? GestureDetector(onTap: onSuffixTap, child: suffixIcon)
            : null,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: theme.primaryColor),
        ),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildRevealHint() {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 2),
      child: Text(
        'Tap to reveal details using Face ID/Thumbprint',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11,
          color: const Color(0xFFAAAAAA),
        ),
      ),
    );
  }

  Future<void> _networkCall() async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();

      if (!hasInternet) {
        Utils.showErrorSnackBar(context, Strings.NO_INTERNET);
        return;
      }
      ref.read(dashboardStateProvider).setLoading(hasInternet);
      ref.read(personalDetailsNotifier(""));
      _fetchData();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      ref.read(dashboardStateProvider).setLoading(false);
    }
  }
}
