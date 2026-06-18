import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smedge/view/auth/state/auth_state.dart';
import 'package:smedge/view/dash_board/dashboard_services/dashboard_repository.dart';
import 'package:smedge/view/dash_board/dashboard_services/dashboard_repository_impl.dart';

import '../network/dio_client.dart';
import '../view/auth/auth_api_service/auth_api_service.dart';
import '../view/auth/auth_services/auth_repository.dart';
import '../view/auth/auth_services/auth_repository_impl.dart';
import '../view/dash_board/dashboard_state.dart';

final dioProvider = Provider.autoDispose<Dio>((ref) {
  return DioClient().dio;
});

final authApiProvider = Provider.autoDispose<AuthApiService>((ref) {
  return AuthApiService(ref.read(dioProvider));
});

final authRepositoryProvider = Provider.autoDispose<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authApiProvider));
});
final authProvider = ChangeNotifierProvider.autoDispose<AuthState>((ref) => AuthState());

/// Dashboard ///

final dashboardRepositoryProvider = Provider.autoDispose<DashboardRepository>((ref){
  return DashboardRepositoryImpl(ref.read(authApiProvider));
});

final dashboardStateProvider = ChangeNotifierProvider<DashboardState>(
      (ref) => DashboardState(),
);
