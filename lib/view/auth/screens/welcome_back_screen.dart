import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';
import 'package:smedge/common_files/support_widget.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/provider/provider.dart';
import 'package:smedge/utils/router/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common_files/network_checker.dart';
import '../../../constants/strings.dart';
import '../auth_view_model.dart';

const bool _isStaging = true;

class _Env {
  static const String iosStoreUrl =
      'https://apps.apple.com/ae/app/uae-pass/id1404607313';
  static const String playStoreUrl = _isStaging
      ? 'https://play.google.com/store/apps/details?id=ae.uaepass.mainapp.stg'
      : 'https://play.google.com/store/apps/details?id=ae.uaepass.mainapp';
}

class WelcomeBackScreen extends ConsumerStatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  ConsumerState<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends ConsumerState<WelcomeBackScreen> {
  WebViewController? _webViewController;
  Timer? _flowTimeout;
  StreamSubscription<Uri>? _deepLinkSub;

  static const Duration _timeout = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();
    _deepLinkSub = AppLinks().uriLinkStream.listen((uri) {
      if (uri.scheme == 'smedge' && uri.host == 'resume_authn') {
        _onSmedgeDeepLink(uri);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      ref.read(authProvider).setContext(context);
      await Utils.getAllData();
    });
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    _flowTimeout?.cancel();
    super.dispose();
  }

  Future<void> _startFlow() async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (!mounted) return;

      if (!hasInternet) {
        Utils.showErrorSnackBar(context, Strings.NO_INTERNET);
        return;
      }

      final response = await ref.read(signInWithUAEPassNotifier({"signin_session_token":Utils.signInToken}).future);
      _setupWebView(response.data.appUrl);
      _flowTimeout = Timer(_timeout, _onFlowTimeout);
    } catch (e) {
      if (mounted) Utils.showErrorSnackBar(context, 'Failed to start UAE PASS');
    }
  }

  void _setupWebView(String loginUrl) {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36 '
            'Mobile Safari/537.36 SmedgeApp/1.0',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (err) =>
              debugPrint('webError ${err.description}'),
          onNavigationRequest: _handleNavigationRequest,
        ),
      )
      ..loadRequest(Uri.parse(loginUrl));
  }

  Future<NavigationDecision> _handleNavigationRequest(
      NavigationRequest request,
      ) async {
    final url = request.url;
    if (url.startsWith('intent://')) {
      await _handleIntentUrl(url);
      return NavigationDecision.prevent;
    }
    if (url.startsWith('uaepass://') || url.startsWith('uaepassstg://')) {
      await _launchUaePassApp(url);
      return NavigationDecision.prevent;
    }
    if (url.startsWith('smedge://resume_authn')) {
      _handleSmedgeUrl(url);
      return NavigationDecision.prevent;
    }

    if (url.contains('/api/auth/uaepass/callback')) {
      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];
      if (code != null &&
          code.isNotEmpty &&
          state != null &&
          state.isNotEmpty) {
        _flowTimeout?.cancel();
        await _completeUaePass(code: code, state: state);
      }
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _onSmedgeDeepLink(Uri uri) {
    final innerEncoded = uri.queryParameters['url'];
    if (innerEncoded == null || innerEncoded.isEmpty) return;
    final innerUrl = Uri.decodeComponent(innerEncoded);
    _handleSmedgeUrl(innerUrl, alreadyDecoded: true);
  }

  void _handleSmedgeUrl(String url, {bool alreadyDecoded = false}) {
    try {
      final innerUrl = alreadyDecoded
          ? url
          : Uri.decodeComponent(Uri.parse(url).queryParameters['url'] ?? '');

      if (innerUrl.isEmpty) return;

      if (innerUrl.contains('status=failure') ||
          innerUrl.contains('failure=1') ||
          innerUrl.contains('error=') ||
          innerUrl.contains('cancel')) {
        _showCancelDialog();
        return;
      }

      _webViewController?.loadRequest(Uri.parse(innerUrl));
    } catch (e) {
      debugPrint('smedge URL error => $e');
    }
  }

  Future<void> _handleIntentUrl(String intentUrl) async {
    try {
      final fragmentStart = intentUrl.indexOf('#Intent;');
      if (fragmentStart == -1) {
        await _openStore();
        return;
      }

      final parts = intentUrl.substring(fragmentStart + 8).split(';');
      String? scheme;
      String? fallbackUrl;

      for (final part in parts) {
        if (part.startsWith('scheme=')) {
          scheme = part.substring('scheme='.length);
        } else if (part.startsWith('S.browser_fallback_url=')) {
          fallbackUrl = Uri.decodeComponent(
            part.substring('S.browser_fallback_url='.length),
          );
        }
      }

      if (scheme != null) {
        final pathPart = intentUrl.substring('intent://'.length, fragmentStart);
        final resolvedScheme = _isStaging ? 'uaepassstg' : scheme;
        final nativeUrl = '$resolvedScheme://$pathPart';

        final launched = await launchUrlString(
          nativeUrl,
          mode: LaunchMode.externalApplication,
        );
        if (launched) return;
      }

      if (fallbackUrl != null) {
        await launchUrlString(
          fallbackUrl,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('intent URL error => $e');
    }
  }

  Future<void> _launchUaePassApp(String url) async {
    try {
      String rewritten = _isStaging && url.startsWith('uaepass://')
          ? url.replaceFirst('uaepass://', 'uaepassstg://')
          : url;

      rewritten = _rewriteCallbackUrls(rewritten);

      final launched = await launchUrlString(
        rewritten,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) await _openStore();
    } catch (e) {
      debugPrint('UAE PASS launch error => $e');
      await _openStore();
    }
  }

  String _rewriteCallbackUrls(String url) {
    try {
      final uri = Uri.parse(url);
      String rawQuery = uri.query;

      for (final key in [
        'successurl',
        'successURL',
        'failureurl',
        'failureURL',
      ]) {
        final prefix = '$key=';
        final start = rawQuery.indexOf(prefix);
        if (start == -1) continue;

        final valueStart = start + prefix.length;
        final ampersand = rawQuery.indexOf('&', valueStart);
        final valueEnd = ampersand == -1 ? rawQuery.length : ampersand;

        final decodedInner = Uri.decodeComponent(
          rawQuery.substring(valueStart, valueEnd),
        );
        final newValue = Uri.encodeComponent(
          'smedge://resume_authn?url=${Uri.encodeComponent(decodedInner)}',
        );

        rawQuery = rawQuery.replaceRange(valueStart, valueEnd, newValue);
      }

      return uri.replace(query: rawQuery).toString();
    } catch (e) {
      debugPrint('_rewriteCallbackUrls error => $e');
      return url;
    }
  }

  Future<void> _completeUaePass({
    required String code,
    required String state,
  }) async {
    try {
      final response = await ref.read(
        signInUaePassCompleteProvider({
          'code': code,
          'state': state,
          "device_token": Utils.deviceId,
        }).future,
      );
      debugPrint('UAE PASS complete => $response');
    } catch (e) {
      debugPrint('complete error => $e');
      if (mounted) {
        Utils.showErrorSnackBar(context, 'UAE PASS verification failed');
      }
    }
  }

  Future<void> _openStore() async {
    final storeUrl = Theme.of(context).platform == TargetPlatform.iOS
        ? _Env.iosStoreUrl
        : _Env.playStoreUrl;
    await launchUrlString(storeUrl, mode: LaunchMode.externalApplication);
    if (mounted) Navigator.pop(context);
  }

  void _onFlowTimeout() {
    if (mounted) {
      Utils.showErrorSnackBar(
        context,
        'UAE PASS sign-in timed out. Please try again.',
      );
    }
  }

  void _showCancelDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('UAE PASS Cancelled'),
        content: const Text(
          'The UAE PASS authentication was cancelled or failed. '
              'Would you like to try again?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startFlow();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    ref.watch(authProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Image.asset("assets/images/sign_up.png"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            width: size.width * 0.3,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.white,
                                  theme.colorScheme.primary,
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Numbers.DOUBLE_NUMBER_4),
                        Text(
                          "Welcome back!",
                          style: theme.textTheme.titleMedium!.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: Numbers.DOUBLE_NUMBER_4),
                        Expanded(
                          child: Container(
                            width: size.width * 0.3,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  Colors.white,
                                  theme.colorScheme.primary,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Numbers.DOUBLE_NUMBER_6),
                    Text(
                      "Tapan",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  title: "Sign In",
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.signIn);
                  },
                ),
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              _OrDivider(),
              const SizedBox(height: 20),
              _uaePassButton(),
              const SizedBox(height: 48),
              SupportWidget(context: context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uaePassButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _startFlow,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF111827),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.symmetric(horizontal: Numbers.DOUBLE_NUMBER_10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fingerprint,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Sign In with UAE PASS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFFD1D5DB))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: const Color(0xFFD1D5DB))),
      ],
    );
  }
}