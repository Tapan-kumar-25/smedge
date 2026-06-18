import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/utils/router/app_routes.dart';
import 'package:smedge/provider/provider.dart';

import '../../../common_files/custom_container.dart';
import '../../../common_files/custom_elevated_button.dart';
import '../../../constants/numbers.dart';

class PersonalDetailsScreen extends ConsumerStatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  ConsumerState<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final dobController = TextEditingController();
  final pasIdController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      ref.read(authProvider).setContext(context);
      ref.read(authProvider).loadUAEPassCompleteData();
    });
    fetchData();
    super.initState();
  }
 void fetchData()async{
    final authState = ref.read(authProvider);

    if(authState.uaePassCompleteModel != null &&authState.uaePassCompleteModel!.data != null ){
      nameController.text = authState.uaePassCompleteModel!.data!.user!.fullName;
      numberController.text = authState.uaePassCompleteModel!.data!.user!.phone;
      pasIdController.text = authState.uaePassCompleteModel!.data!.user!.customerId;
    }

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.02),
                      Image.asset("assets/images/sign_up.png", height: 60),

                      SizedBox(height: Numbers.DOUBLE_NUMBER_16),

                      Row(
                        children: [
                          Expanded(child: Divider(color: theme.primaryColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "Your Personal Details",
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: theme.primaryColor)),
                        ],
                      ),

                      SizedBox(height: Numbers.DOUBLE_NUMBER_8),

                      Text(
                        "These details were securely fetched from UAE Pass.\nPlease review them before continuing.",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall,
                      ),

                      SizedBox(height: Numbers.DOUBLE_NUMBER_20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Full Name", style: theme.textTheme.bodyMedium),
                      ),
                      SizedBox(height: Numbers.DOUBLE_NUMBER_6),
                      CustomContainer(
                        padding: 2,
                        child: TextFormField(
                          controller: nameController,
                          inputFormatters: [LengthLimitingTextInputFormatter(50)],
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: Numbers.DOUBLE_NUMBER_6),
                            hintText: "Full name",
                            border: InputBorder.none,
                            // suffixIcon: nameController.text.isNotEmpty
                            //     ? IconButton(
                            //   icon: const Icon(Icons.close, size: 18),
                            //   onPressed: () {
                            //     setState(() {
                            //       nameController.clear();
                            //     });
                            //   },
                            // )
                            //     : null,
                          ),
                        ),
                      ),

                      SizedBox(height: Numbers.DOUBLE_NUMBER_16),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Mobile Number", style: theme.textTheme.bodyMedium),
                      ),
                      SizedBox(height: Numbers.DOUBLE_NUMBER_6),

                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: CustomContainer(
                              padding: 2,
                              child: CountryCodePicker(
                                initialSelection: authState.countryCode,
                                onChanged: (value) {
                                  authState.setCountryCode(value.dialCode ?? "+971");
                                },
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 6,
                            child: CustomContainer(
                              padding: 2,
                              child: TextFormField(
                                controller: numberController,
                                keyboardType: TextInputType.number,

                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: Numbers.DOUBLE_NUMBER_6),
                                  hintText: "Mobile number",
                                  border: InputBorder.none,
                                ),

                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: Numbers.DOUBLE_NUMBER_16),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Date of Birth", style: theme.textTheme.bodyMedium),
                      ),
                      SizedBox(height: Numbers.DOUBLE_NUMBER_6),

                      CustomContainer(
                        padding: 2,
                        child: TextFormField(
                          controller: dobController,
                          readOnly: true,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: Numbers.DOUBLE_NUMBER_6),
                            hintText: "DD - MM - YYYY",
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.calendar_month, color: Colors.red),
                          ),
                          onTap: () async {
                            final dt = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (dt != null) {
                              dobController.text =
                              "${dt.day.toString().padLeft(2, '0')} - ${dt.month.toString().padLeft(2, '0')} - ${dt.year}";
                            }
                          },
                        ),
                      ),

                      SizedBox(height: Numbers.DOUBLE_NUMBER_16),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Emirates ID", style: theme.textTheme.bodyMedium),
                      ),
                      SizedBox(height: Numbers.DOUBLE_NUMBER_6),

                      CustomContainer(
                        padding: 2,
                        child:  TextField(
                          readOnly: true,
                          controller: pasIdController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: Numbers.DOUBLE_NUMBER_6),
                            hintText: "784-XXXX-XXXXXXX-X",
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      SizedBox(height: Numbers.DOUBLE_NUMBER_6),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Masked for security",
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding:  EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    title: "Confirm",
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.companyDetails);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
