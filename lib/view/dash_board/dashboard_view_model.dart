import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/network/app_exception.dart';
import 'package:smedge/provider/provider.dart';

import '../../common_files/utils.dart';
import 'model/personal_details_screen.dart';

final personalDetailsNotifier = FutureProvider.family<PersonalDetailsModel, dynamic>((ref, data)async{
  final dashboardState = ref.watch(dashboardStateProvider);
  final dashboardApi = ref.watch(dashboardRepositoryProvider);
  try{
    final response = await dashboardApi.fetchPersonalDetails();
    if(response != null){
      dashboardState.setPersonalDetails(response);
    }
    return response;
  }on AppException catch(e){
    Utils.showErrorSnackBar(dashboardState.context, e.message);
    rethrow;
  }catch(e){
    Utils.showErrorSnackBar(dashboardState.context, "Something went wrong");
    throw AppException(message: "Something went wrong", errorCode: "UNKNOWN");
  }finally{
    dashboardState.setLoading(false);
  }

});