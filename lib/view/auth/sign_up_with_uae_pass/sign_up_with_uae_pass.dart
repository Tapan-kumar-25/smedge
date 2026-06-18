import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common_files/network_checker.dart';
import '../../../common_files/utils.dart';
import '../../../constants/strings.dart';
import '../../../provider/provider.dart';
import '../auth_view_model.dart';

const bool _isStaging = true;

class _Env {
  static const String iosStoreUrl =
      'https://apps.apple.com/ae/app/uae-pass/id1404607313';
  static const String playStoreUrl = _isStaging
      ? 'https://play.google.com/store/apps/details?id=ae.uaepass.mainapp.stg'
      : 'https://play.google.com/store/apps/details?id=ae.uaepass.mainapp';
}

class SignUpWithUaePass extends ConsumerStatefulWidget {
  const SignUpWithUaePass({super.key});

  @override
  ConsumerState<SignUpWithUaePass> createState() => _SignUpWithUaePassState();
}

class _SignUpWithUaePassState extends ConsumerState<SignUpWithUaePass>
    with TickerProviderStateMixin {
  WebViewController? _webViewController;
  _ViewState _viewState = _ViewState.loading;
  bool _completing = false;

  late final AnimationController _pulseController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  Timer? _flowTimeout;
  StreamSubscription<Uri>? _deepLinkSub;

  static const Duration _timeout = Duration(minutes: 2);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
    _deepLinkSub = AppLinks().uriLinkStream.listen((uri) {
      if (uri.scheme == 'smedge' && uri.host == 'resume_authn') {
        _onSmedgeDeepLink(uri);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).setContext(context);
      _startFlow();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _flowTimeout?.cancel();
    _deepLinkSub?.cancel();
    super.dispose();
  }

  Future<void> _startFlow() async {
    setState(() => _viewState = _ViewState.loading);

    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (!mounted) return;

      if (!hasInternet) {
        Utils.showErrorSnackBar(context, Strings.NO_INTERNET);
        setState(() => _viewState = _ViewState.error);
        return;
      }

      final response = await ref.read(signUpWithUAEPassNotifier({}).future);
      _setupWebView(response.data.appUrl);
      _flowTimeout = Timer(_timeout, _onFlowTimeout);
      if (mounted) setState(() => _viewState = _ViewState.webView);
    } catch (e) {
      if (mounted) setState(() => _viewState = _ViewState.error);
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
    if (_completing) return;

    try {
      _completing = true;
      final response = await ref.read(
        uaePassCompleteProvider({
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
        setState(() => _viewState = _ViewState.error);
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

  void _onFlowTimeout() {
    if (mounted) {
      Utils.showErrorSnackBar(
        context,
        'UAE PASS sign-in timed out. Please try again.',
      );
      setState(() => _viewState = _ViewState.error);
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

  Widget _buildPulseRing(double size, double delay) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final progress = (_pulseController.value + delay) % 1.0;
        return Transform.scale(
          scale: 0.8 + (progress * 0.55),
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0D47A1).withOpacity(0.18 * (1 - progress)),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (_viewState) {
      _ViewState.loading => _buildLoadingScreen(),
      _ViewState.webView => _buildWebViewScreen(),
      _ViewState.error => _buildErrorScreen(),
    };
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildPulseRing(220, 0.00),
                  _buildPulseRing(175, 0.25),
                  _buildPulseRing(130, 0.50),
                  Container(
                    height: 96,
                    width: 96,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D47A1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x330D47A1),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
                children: [
                  TextSpan(text: 'Secure '),
                  TextSpan(
                    text: 'Sign-In',
                    style: TextStyle(color: Color(0xFF0D47A1)),
                  ),
                  TextSpan(text: ' with\n'),
                  TextSpan(
                    text: 'UAE Pass',
                    style: TextStyle(color: Color(0xFF0D47A1)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "You'll be redirected to UAE Pass to complete\nthe secure sign-in process.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildStepIndicators(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: Colors.black38,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Powered by UAE Pass',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicators() {
    const steps = [
      (Icons.send_to_mobile_rounded, 'Opening UAE Pass'),
      (Icons.face_retouching_natural, 'Authenticate'),
      (Icons.check_circle_outline_rounded, 'Complete'),
    ];

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final activeStep = (_pulseController.value * steps.length)
            .floor()
            .clamp(0, 2);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < steps.length; i++) ...[
              _buildStep(
                steps[i].$1,
                steps[i].$2,
                isActive: i == activeStep,
                isDone: i < activeStep,
              ),
              if (i < steps.length - 1)
                Container(
                  width: 28,
                  height: 1.5,
                  color: i < activeStep
                      ? const Color(0xFF0D47A1)
                      : Colors.black12,
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStep(
    IconData icon,
    String label, {
    required bool isActive,
    required bool isDone,
  }) {
    final color = (isActive || isDone)
        ? const Color(0xFF0D47A1)
        : Colors.black26;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFF0D47A1)
                : isDone
                ? const Color(0xFF0D47A1).withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
          ),
          child: Icon(
            isDone ? Icons.check : icon,
            size: 18,
            color: isActive ? Colors.white : color,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color, letterSpacing: 0.2),
        ),
      ],
    );
  }

  Widget _buildWebViewScreen() {
    if (_webViewController == null) return _buildLoadingScreen();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'UAE PASS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Secure Sign-In',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              const Icon(Icons.lock, size: 14, color: Colors.green),
              const SizedBox(width: 4),
              const Text(
                'Secure',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: WebViewWidget(controller: _webViewController!),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'UAE PASS Unavailable',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Unable to start UAE PASS sign-in.\nPlease check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black45, height: 1.5),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _startFlow,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Go Back',
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ViewState { loading, webView, error }
