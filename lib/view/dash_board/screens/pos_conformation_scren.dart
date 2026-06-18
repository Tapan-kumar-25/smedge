import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:smedge/common_files/custom_elevated_button.dart';

class _AnimatedSuccessCircle extends StatefulWidget {
  const _AnimatedSuccessCircle();

  @override
  State<_AnimatedSuccessCircle> createState() => _AnimatedSuccessCircleState();
}

class _AnimatedSuccessCircleState extends State<_AnimatedSuccessCircle>
    with TickerProviderStateMixin {
  // Ring pulse
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  // Outer glow ring draw
  late final AnimationController _ringController;
  late final Animation<double> _ringProgress;

  // Inner circle scale-in
  late final AnimationController _circleController;
  late final Animation<double> _circleScale;

  // Checkmark draw
  late final AnimationController _checkController;
  late final Animation<double> _checkProgress;

  @override
  void initState() {
    super.initState();

    // 1. Outer ring draws itself
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _ringProgress = CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeOut,
    );

    // 2. Inner green circle pops in
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _circleScale = CurvedAnimation(
      parent: _circleController,
      curve: Curves.elasticOut,
    );

    // 3. Checkmark draws
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkProgress = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    );

    // 4. Continuous pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _pulseScale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    // Chain: ring → circle → check
    _ringController.forward().whenComplete(() {
      _circleController.forward().whenComplete(() {
        _checkController.forward();
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    _circleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Pulse ring ──
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Transform.scale(
              scale: _pulseScale.value,
              child: Opacity(
                opacity: _pulseOpacity.value,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // ── Outer arc ring ──
          AnimatedBuilder(
            animation: _ringProgress,
            builder: (_, __) => CustomPaint(
              size: const Size(110, 110),
              painter: _ArcPainter(
                progress: _ringProgress.value,
                color: const Color(0xFFA5D6A7),
                strokeWidth: 6,
              ),
            ),
          ),

          // ── Green circle ──
          AnimatedBuilder(
            animation: _circleScale,
            builder: (_, __) => Transform.scale(
              scale: _circleScale.value,
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x554CAF50),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Checkmark ──
          AnimatedBuilder(
            animation: _checkProgress,
            builder: (_, __) => CustomPaint(
              size: const Size(88, 88),
              painter: _CheckPainter(progress: _checkProgress.value),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  const _ArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - strokeWidth / 2,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

class _CheckPainter extends CustomPainter {
  final double progress;

  const _CheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Check path: short leg then long leg
    final p1 = Offset(cx - 18, cy + 2);
    final p2 = Offset(cx - 5, cy + 14);
    final p3 = Offset(cx + 18, cy - 14);

    final totalLen = (p2 - p1).distance + (p3 - p2).distance;
    final drawn = totalLen * progress;

    final path = Path();
    final seg1 = (p2 - p1).distance;

    if (drawn <= seg1) {
      final t = drawn / seg1;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(
        p1.dx + (p2.dx - p1.dx) * t,
        p1.dy + (p2.dy - p1.dy) * t,
      );
    } else {
      final t = (drawn - seg1) / (p3 - p2).distance;
      path.moveTo(p1.dx, p1.dy);
      path.lineTo(p2.dx, p2.dy);
      path.lineTo(
        p2.dx + (p3.dx - p2.dx) * t,
        p2.dy + (p3.dy - p2.dy) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}

class POSConformation extends StatefulWidget {
  const POSConformation({super.key});

  @override
  State<POSConformation> createState() => _POSConformationState();
}

class _POSConformationState extends State<POSConformation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _contentController;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 48),

                    // ── Animated circle ──
                    const _AnimatedSuccessCircle(),

                    const SizedBox(height: 28),

                    // ── Title ──
                    FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: const Text(
                          'Application submitted\nsuccessfully',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                            height: 1.35,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Details card ──
                    FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: _buildDetailsCard(),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── What happens next ──
                    FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: _buildNextSteps(),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Button ──
            FadeTransition(
              opacity: _contentFade,
              child: _buildBottomButton(),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Details card ─────────────────────────────────────────────────────────

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            label: 'Product Type',
            value: 'POS Financing',
            valueBold: true,
            isFirst: true,
          ),
          _buildDivider(),
          _buildDetailRow(
            label: 'Application ID',
            value: 'GSTIN12345',
            valueBold: true,
          ),
          _buildDivider(),
          _buildDetailRow(
            label: 'Submitted Date',
            value: 'Oct 24, 2026',
            valueBold: true,
          ),
          _buildDivider(),
          _buildDetailRow(
            label: 'Status',
            valueWidget: _buildStatusBadge(),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    String? value,
    Widget? valueWidget,
    bool valueBold = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        isFirst ? 16 : 14,
        18,
        isLast ? 16 : 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w400,
            ),
          ),
          if (valueWidget != null)
            valueWidget
          else
            Text(
              value ?? '',
              style: TextStyle(
                fontSize: 13.5,
                color: const Color(0xFF111827),
                fontWeight:
                valueBold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF3F4F6),
      indent: 18,
      endIndent: 18,
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
      ),
      child: const Text(
        'Processing',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF59E0B),
        ),
      ),
    );
  }

  // ─── What happens next ────────────────────────────────────────────────────

  Widget _buildNextSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What happens next?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        _buildNextStep(
          icon: Icons.person_search_outlined,
          text: 'Our team will review your application',
        ),
        const SizedBox(height: 12),
        _buildNextStep(
          icon: Icons.verified_user_outlined,
          text: 'You may be contacted for additional verification',
        ),
        const SizedBox(height: 12),
        _buildNextStepWithHighlight(),
      ],
    );
  }

  Widget _buildNextStep({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF1A3A6B)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextStepWithHighlight() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.access_time_rounded,
              size: 18, color: Color(0xFF1A3A6B)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF374151),
                    height: 1.5),
                children: [
                  TextSpan(
                      text:
                      'You will be updated with the application status within the '),
                  TextSpan(
                    text: '48 hours.',
                    style: TextStyle(
                      color: Color(0xFF1A3A6B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Bottom button ────────────────────────────────────────────────────────

  Widget _buildBottomButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: SizedBox(
        width: double.infinity,
        child: CustomElevatedButton(
          onPressed: () {
            for (int i = 0; i < 4; i++) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
          },
          title: "Back to Home",
        ),
      ),
    );
  }
}