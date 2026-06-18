import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/view/dash_board/screens/home_screen.dart';
import 'package:smedge/view/dash_board/screens/profile_screen.dart';

import '../../../provider/provider.dart';
import '../../../refresh_service.dart';
import '../../products/products_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() =>
      _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends ConsumerState<DashboardScreen> {
  List<String> images = [
    "assets/svg/smedge_icon.svg",
    "assets/svg/search.svg",
    "assets/svg/product.svg",
    "assets/svg/person.svg",
  ];
  List<String> labels = ["SMEDGE", "Explore", "My Products", "Profile"];
  final List<Widget> screens = [
    HomeScreen(),
    Container(),
    MyProductsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardStateProvider).setContext(context);
      ref.read(authRefreshServiceProvider).start(ref);
    });
    Utils.getAllData();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    final dashboardProvider = ref.watch(dashboardStateProvider);

    return PopScope(
      canPop: dashboardProvider.selectedTabIndex == 0,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (dashboardProvider.selectedTabIndex != 0) {
          dashboardProvider.setTabIndex(0);
          return;
        }

        if (Platform.isAndroid) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Exit App"),
              content: const Text("Do you want to exit?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Yes"),
                ),
              ],
            ),
          );

          if (shouldExit == true) {
            Navigator.of(context).pop();
          }
        } else {

        }
      },
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          body: screens[dashboardProvider.selectedTabIndex],
          bottomNavigationBar: Container(
            padding: EdgeInsets.only(bottom: Numbers.DOUBLE_NUMBER_10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: Numbers.DOUBLE_NUMBER_10,
                  color: Colors.black12,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(images.length, (index) {
                final isSelected = dashboardProvider.selectedTabIndex == index;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    dashboardProvider.setTabIndex(index);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: Numbers.DOUBLE_NUMBER_4,
                        width: Numbers.DOUBLE_NUMBER_50,
                        margin: EdgeInsets.only(
                          bottom: Numbers.DOUBLE_NUMBER_6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            Numbers.DOUBLE_NUMBER_10,
                          ),
                        ),
                      ),
                      SvgPicture.asset(
                        images[index],
                        height: Numbers.DOUBLE_NUMBER_20,
                        width: Numbers.DOUBLE_NUMBER_20,
                      ),
                      SizedBox(height: Numbers.DOUBLE_NUMBER_4),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: Numbers.DOUBLE_NUMBER_14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
