import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/view/auth/auth_view_model.dart';

import 'common_files/utils.dart';

class AuthRefreshService {
  Timer? _timer;

  void start(WidgetRef ref) {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(minutes: 1),
          (_) async {
        try {
          if (Utils.refreshToken.isNotEmpty) {
            await ref.read(refreshTokenNotifier.future);
            await Utils.getAllData();
          }
        } catch (e) {
          debugPrint("Refresh failed: $e");
        }
      },
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
final authRefreshServiceProvider =
Provider<AuthRefreshService>((ref) {
  return AuthRefreshService();
});