import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/constants/strings.dart';
import 'package:smedge/utils/shared_preference_utils.dart';

import '../../../utils/router/app_routes.dart';

class UserProfile {
  final String name;
  final bool isVerified;

  const UserProfile({required this.name, required this.isVerified});
}

class DedicatedSupporter {
  final String name;
  final String role;

  const DedicatedSupporter({required this.name, required this.role});
}

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

const userProfile = UserProfile(name: 'Edwin John Thomas', isVerified: true);
const dedicatedSupporter = DedicatedSupporter(
  name: 'Sarah Jenkins',
  role: 'Relationship Manager',
);
final List<ProfileMenuItem> menuItems = [
  const ProfileMenuItem(
    icon: Icons.person_outline_rounded,
    title: 'Personal Details',
    subtitle: 'View & Manage your personal information',
  ),
  const ProfileMenuItem(
    icon: Icons.business_center_outlined,
    title: 'Business Details',
    subtitle: 'Manage your company & business inform..',
  ),
];

bool alertsEnabled = true;
bool biometricsEnabled = true;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  static const double _avatarRadius = 46.0;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFEDF1F8),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: Numbers.DOUBLE_NUMBER_16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00418F), Color(0xFF76B4FF)],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 60),
                            child: Center(
                              child: Text(
                                'Profile',
                                style: theme.textTheme.titleLarge!.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -ProfileScreen._avatarRadius,
                        child: Container(
                          width: ProfileScreen._avatarRadius * 2,
                          height: ProfileScreen._avatarRadius * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: ClipOval(
                            child: Container(
                              color: const Color(0xFFE3EAF6),
                              child: const Icon(
                                Icons.person,
                                size: 54,
                                color: Color(0xFF1A3A6B),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: ProfileScreen._avatarRadius + 12),
                  Center(
                    child: Column(
                      children: [ 
                        Text(
                          userProfile.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (userProfile.isVerified)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 50,
                                height: 1.5,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.white,
                                      Color(0xFF34A853),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF34A853),
                                size: 15,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF34A853),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 50,
                                height: 1.5,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                    colors: [
                                      Colors.white,
                                      Color(0xFF34A853),
                                    ],
                                  ),
                                ),
                              )
                              ,
                            ],
                          ),
                        SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                        ElevatedButton.icon(
                          onPressed: () {_logoutDialog(context);},
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: Numbers.DOUBLE_NUMBER_8,
                              horizontal: Numbers.DOUBLE_NUMBER_16,
                            ),
                            elevation: 5,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Numbers.DOUBLE_NUMBER_30,
                              ),
                            ),
                          ),
                          icon: Icon(Icons.logout, color: Colors.red),
                          label: Text(
                            "Logout",
                            style: theme.textTheme.titleMedium!.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomContainer(
                      padding: 0,
                      child: Column(
                        children: List.generate(menuItems.length, (i) {
                          final item = menuItems[i];
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (i == 0) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.personalDetailsScreen,
                                    );
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.businessDetails,
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEAF1FB),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          item.icon,
                                          color: const Color(0xFF1A3A6B),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1A1A2E),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item.subtitle,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF8A8FAE),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Color(0xFF8A8FAE),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (i < menuItems.length - 1)
                                const Divider(
                                  height: 1,
                                  indent: 64,
                                  endIndent: 14,
                                  color: Color(0xFFEEEFF4),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),

                  SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dedicated Supporter',
                          style: theme.textTheme.titleMedium!.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomContainer(
                          padding: Numbers.DOUBLE_NUMBER_14,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFD8E4F5),
                                      border: Border.all(
                                        color: const Color(0xFFBFD3EF),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Color(0xFF1A3A6B),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dedicatedSupporter.name,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        dedicatedSupporter.role,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF8A8FAE),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _actionButton(
                                      context: context,
                                      icon: Icons.phone_outlined,
                                      label: 'Call',
                                      onTap: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _actionButton(
                                      context: context,
                                      icon: Icons.email_outlined,
                                      label: 'Email',
                                      onTap: () {},
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferences',
                          style: theme.textTheme.titleMedium!.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomContainer(
                          padding: Numbers.DOUBLE_NUMBER_14,
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {},
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Language",
                                        style: theme.textTheme.titleSmall!
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    Icon(Icons.chevron_right),
                                  ],
                                ),
                              ),
                              SizedBox(height: Numbers.DOUBLE_NUMBER_10),
                              Divider(height: 1, color: Colors.black12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Manage Alerts",
                                      style: theme.textTheme.titleSmall!
                                          .copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  Switch(
                                    activeTrackColor: Colors.green,
                                    activeThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.grey,
                                    inactiveThumbColor: Colors.black,
                                    value: alertsEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        alertsEnabled = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Divider(height: 1, color: Colors.black12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: Numbers.DOUBLE_NUMBER_5,
                                        ),
                                        Text(
                                          "Setup Biometrics",
                                          style: theme.textTheme.titleSmall!
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "Enable biometrics authentication for faster and secure login.",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    activeTrackColor: Colors.green,
                                    activeThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.grey,
                                    inactiveThumbColor: Colors.black,
                                    value: biometricsEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        biometricsEnabled = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Numbers.DOUBLE_NUMBER_16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Support',
                          style: theme.textTheme.titleMedium!.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomContainer(
                          padding: Numbers.DOUBLE_NUMBER_14,
                          child: Column(
                            children: [
                              _buildItem(
                                icon: Icons.headphones,
                                title: "Contact Us",
                                onTap: () {},
                              ),
                              Divider(height: 1, color: Colors.black12),
                              _buildItem(
                                icon: Icons.feedback,
                                title: "Provide Feedback",
                                onTap: () {},
                              ),
                              Divider(height: 1, color: Colors.black12),
                              _buildItem(
                                icon: Icons.support_agent,
                                title: "Reach Support",
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xffEFEFEF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.red, size: Numbers.DOUBLE_NUMBER_18),
            SizedBox(width: Numbers.DOUBLE_NUMBER_6),
            Text(
              label,
              style: theme.textTheme.titleMedium!.copyWith(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Numbers.DOUBLE_NUMBER_10),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(Numbers.DOUBLE_NUMBER_10),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(width: Numbers.DOUBLE_NUMBER_16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black),
          ],
        ),
      ),
    );
  }

   _logoutDialog(BuildContext context){
    return showDialog(context: context,
        builder: (context){
      final theme = Theme.of(context);
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Numbers.DOUBLE_NUMBER_16)),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
        insetPadding: EdgeInsets.symmetric(horizontal: Numbers.DOUBLE_NUMBER_16),
        content: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomContainer(
                  padding: Numbers.DOUBLE_NUMBER_10,
                  child: Icon(Icons.logout,color: Colors.red,size: Numbers.DOUBLE_NUMBER_30,)),
              SizedBox(height: Numbers.DOUBLE_NUMBER_12),
              Text("Logout Account?",style: theme.textTheme.titleLarge),
              SizedBox(height: Numbers.DOUBLE_NUMBER_12),
              Text("Are you sure you want to logout your account?",style: theme.textTheme.titleMedium!.copyWith(color: Colors.grey),),
              SizedBox(height: Numbers.DOUBLE_NUMBER_12),
              Row(
                children: [
                  Expanded(child: ElevatedButton(onPressed: (){Navigator.pop(context);},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Numbers.DOUBLE_NUMBER_16)),
                        padding: EdgeInsets.symmetric(vertical: Numbers.DOUBLE_NUMBER_10),
                      ),
                      child: Text("Cancel",style: theme.textTheme.titleMedium!.copyWith(color: Colors.white),))),
                SizedBox(width: Numbers.DOUBLE_NUMBER_16),
                  Expanded(child: ElevatedButton(onPressed: ()async{
                    await SharedPreferenceUtils.setBool(Strings.IS_LOGIN, false);
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.intro, (route) =>false);
                  },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Numbers.DOUBLE_NUMBER_16)),
                        padding: EdgeInsets.symmetric(vertical: Numbers.DOUBLE_NUMBER_10),
                      ),
                      child: Text("Logout",style: theme.textTheme.titleMedium!.copyWith(color: Colors.white),))),

                ],
              )
            ],
          ),
        ),
      );
        });
  }
}
