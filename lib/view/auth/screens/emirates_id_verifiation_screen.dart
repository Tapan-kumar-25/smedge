import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/provider/provider.dart';
import 'package:smedge/view/auth/auth_view_model.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common_files/network_checker.dart';
import '../../../constants/strings.dart';

const bool _isStaging = true;

class _Env {
  static const String iosStoreUrl =
      'https://apps.apple.com/ae/app/uae-pass/id1404607313';
  static const String playStoreUrl = _isStaging
      ? 'https://play.google.com/store/apps/details?id=ae.uaepass.mainapp.stg'
      : 'https://play.google.com/store/apps/details?id=ae.uaepass.mainapp';
}

class EmiratesIdVerificationScreen extends ConsumerStatefulWidget {
  const EmiratesIdVerificationScreen({super.key});

  @override
  ConsumerState<EmiratesIdVerificationScreen> createState() =>
      _EmiratesIdVerificationScreenState();
}

class _EmiratesIdVerificationScreenState
    extends ConsumerState<EmiratesIdVerificationScreen> {
  WebViewController? _webViewController;

  // _ViewState _viewState = _ViewState.loading;
  bool _completing = false;
  StreamSubscription<Uri>? _deepLinkSub;

  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    Utils.getSignUpSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).setContext(context);
    });
    super.initState();
    _deepLinkSub = AppLinks().uriLinkStream.listen((uri) {
      if (uri.scheme == 'smedge' && uri.host == 'resume_authn') {
        _onSmedgeDeepLink(uri);
      }
    });
  }

  Future<void> _startFlow() async {
    // setState(() => _viewState = _ViewState.loading);
    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (!mounted) return;
      if (!hasInternet) {
        Utils.showErrorSnackBar(context, Strings.NO_INTERNET);
        // setState(() => _viewState = _ViewState.error);
        return;
      }
      final response = await ref.read(
        uaePassVerification(Utils.signUpSession).future,
      );
      _setupWebView(response.data.appUrl);
      // _flowTimeout = Timer(_timeout, _onFlowTimeout);
      // if (mounted) setState(() => _viewState = _ViewState.webView);
    } catch (e) {
      // if (mounted) setState(() => _viewState = _ViewState.error);
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

    // Backend callback — extract code + state and complete
    if (url.contains('/api/auth/uaepass/callback')) {
      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];
      if (code != null &&
          code.isNotEmpty &&
          state != null &&
          state.isNotEmpty) {
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
    if (_completing) return;

    try {
      _completing = true;
      final response = await ref.read(
        signUpUaePassCompleteProvider({
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
        // setState(() => _viewState = _ViewState.error);
      }
    } finally {
      _completing = false;
    }
  }

  Future<void> _openStore() async {
    final storeUrl = Theme.of(context).platform == TargetPlatform.iOS
        ? _Env.iosStoreUrl
        : _Env.playStoreUrl;
    await launchUrlString(storeUrl, mode: LaunchMode.externalApplication);
    if (mounted) Navigator.pop(context);
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
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Numbers.DOUBLE_NUMBER_30),
              Text(
                "Emirates ID Verification",
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_6),
              Text(
                "Verify your identity to continue. You can fetch details using UAE Pass or upload your Emirates ID manually.",
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_10),
              InkWell(
                onTap: () async {
                  await _startFlow();
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
              SizedBox(height: Numbers.DOUBLE_NUMBER_4),
              Row(
                children: [
                  Icon(Icons.keyboard_arrow_up, size: 20),
                  Text(
                    " Recommended for faster and secure verification",
                    style: theme.textTheme.titleSmall!.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: authState.isOtpVerifyLoading
                    ? Center(child: CircularProgressIndicator())
                    : CustomElevatedButton(
                        title: "I’ll do it later",
                        onPressed: () {
                          _skipKycFunction();
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _skipKycFunction() async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (hasInternet) {
        ref.read(authProvider).setOtpVerifyLoading(hasInternet);
        if (!mounted) return;
        FocusScope.of(context).unfocus();
        await ref.read(skipKycNotifier("").future);
      } else {
        if (!mounted) return;
        Utils.showSnackBar(context, Strings.NO_INTERNET, Colors.red);
      }
    } catch (e) {
      ref.read(authProvider).setOtpVerifyLoading(false);
    } finally {
      ref.read(authProvider).setOtpVerifyLoading(false);
    }
  }
}
