import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// One kernel: three overlapping circles, matching `KernelBlob` in the
/// supplied components.
///
/// [phase] is where in the loop this kernel pops, 0..1. Staggering is the whole
/// trick — popped together the cluster reads as one lump pulsing, popped in
/// sequence it reads as corn.
class PopcornKernel {
  const PopcornKernel({
    required this.cx,
    required this.cy,
    required this.r,
    required this.phase,
  });

  final double cx;
  final double cy;
  final double r;
  final double phase;
}

/// The popcorn scene, drawn rather than loaded.
///
/// Transcribed from the layered components in `mobile_dev/components/`
/// (`KernelsAlone`, `PacketAlone`, `CupAlone`, `PopcornWithPacket`), which give
/// each piece as plain geometry. The flat `empty_state.png` could not be
/// animated per-piece — it is one 124x124 raster, and Figma holds it as a
/// single image node too. Drawing it means every element moves on its own, and
/// it stays sharp at any size where the PNG was already soft at 3x.
///
/// Coordinates are the components' own 160x200 space; the canvas is scaled to
/// whatever the widget is given, so nothing here needs to know the device.
class PopcornScenePainter extends CustomPainter {
  PopcornScenePainter(this.animation) : super(repaint: animation);

  /// Driving the painter through `repaint:` rather than an `AnimatedBuilder`
  /// means the widget tree is never rebuilt — only this paint runs each frame.
  final Animation<double> animation;

  static const Size scene = Size(160, 200);

  /// How far into each kernel's cycle the pop lasts. The rest of the cycle it
  /// sits still, which keeps the motion from looking mechanical.
  static const double _popWindow = 0.55;
  static const double _popRise = 11;

  /// Straight from `PopcornWithPacket.tsx`, including the shared `kpop-*`
  /// classes, which become shared phases here.
  static const List<PopcornKernel> kernels = [
    PopcornKernel(cx: 28, cy: 72, r: 13, phase: 0.00),
    PopcornKernel(cx: 44, cy: 60, r: 14, phase: 0.10),
    PopcornKernel(cx: 60, cy: 54, r: 15, phase: 0.20),
    PopcornKernel(cx: 76, cy: 60, r: 14, phase: 0.10),
    PopcornKernel(cx: 90, cy: 70, r: 12, phase: 0.00),
    PopcornKernel(cx: 38, cy: 54, r: 11, phase: 0.30),
    PopcornKernel(cx: 60, cy: 40, r: 12, phase: 0.40),
    PopcornKernel(cx: 82, cy: 54, r: 11, phase: 0.30),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;

    canvas.save();
    canvas.scale(size.width / scene.width);

    // Painted in the components' order: kernels first, so the bucket covers
    // any that dip back below its rim.
    _paintKernels(canvas, t);
    _paintBucket(canvas, t);
    _paintCup(canvas, t);

    canvas.restore();
  }

  // Kernels ------------------------------------------------------------------

  /// Rises and returns over [_popWindow], then rests. `sin` rather than a
  /// triangle so it eases at the top instead of snapping back.
  double _pop(double t, double phase) {
    final local = (t - phase) % 1.0;
    if (local > _popWindow) return 0;
    return math.sin(math.pi * (local / _popWindow));
  }

  void _paintKernels(Canvas canvas, double t) {
    for (final kernel in kernels) {
      final pop = _pop(t, kernel.phase);

      canvas.save();
      // Scaled about its own centre, so a kernel swells in place rather than
      // drifting sideways as it grows.
      canvas.translate(kernel.cx, kernel.cy - _popRise * pop);
      canvas.scale(1 + 0.10 * pop);
      canvas.translate(-kernel.cx, -kernel.cy);

      final r = kernel.r;
      _circle(canvas, kernel.cx - r * 0.3, kernel.cy + r * 0.1, r * 0.75,
          AppColors.popcorn);
      _circle(canvas, kernel.cx + r * 0.3, kernel.cy + r * 0.05, r * 0.72,
          AppColors.popcornDeep);
      _circle(canvas, kernel.cx, kernel.cy - r * 0.3, r * 0.65,
          AppColors.popcorn);

      canvas.restore();
    }
  }

  // Bucket -------------------------------------------------------------------

  void _paintBucket(Canvas canvas, double t) {
    canvas.save();
    // A shallow bob, so the bucket answers the kernels instead of sitting dead
    // under them.
    canvas.translate(10, 88 + 1.4 * math.sin(2 * math.pi * t));

    _shadow(canvas, 50, 102, 32, 4, 0.22);
    _polygon(canvas, const [
      Offset(14, 32), Offset(20, 100), Offset(80, 100), Offset(86, 32),
    ], AppColors.surface);

    for (final stripe in const [
      [Offset(14, 32), Offset(20, 100), Offset(32, 100), Offset(26, 32)],
      [Offset(38, 32), Offset(44, 100), Offset(56, 100), Offset(50, 32)],
      [Offset(62, 32), Offset(68, 100), Offset(80, 100), Offset(74, 32)],
    ]) {
      _polygon(canvas, stripe, AppColors.popcorn);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 26, 80, 12),
        const Radius.circular(4),
      ),
      Paint()..color = AppColors.popcorn,
    );

    _circle(canvas, 50, 68, 14, AppColors.white);
    canvas.restore();
  }

  // Cup ----------------------------------------------------------------------

  /// Out, hold, back, rest — the "hold on then go back in" the brief asked for.
  /// A plain sine would never pause at the top.
  double _cupTravel(double t) {
    if (t < 0.28) return Curves.easeOut.transform(t / 0.28);
    if (t < 0.56) return 1;
    if (t < 0.84) return 1 - Curves.easeInOut.transform((t - 0.56) / 0.28);
    return 0;
  }

  void _paintCup(Canvas canvas, double t) {
    final travel = _cupTravel(t);

    canvas.save();
    canvas.translate(108 + 4 * travel, 110 - 6 * travel);
    canvas.scale(0.72);

    _shadow(canvas, 36, 104, 20, 3.5, 0.2);

    // Lid: two quadratics, exactly as the component's path.
    final lid = Path()
      ..moveTo(10, 18)
      ..quadraticBezierTo(10, 10, 36, 10)
      ..quadraticBezierTo(62, 10, 62, 18)
      ..lineTo(58, 26)
      ..quadraticBezierTo(36, 22, 14, 26)
      ..close();
    canvas.drawPath(lid, Paint()..color = AppColors.popcornDeep);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(36, 18), width: 52, height: 14),
      Paint()..color = AppColors.popcorn,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(33, 0, 6, 22),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.popcorn,
    );

    _polygon(canvas, const [
      Offset(14, 26), Offset(20, 100), Offset(52, 100), Offset(58, 26),
    ], AppColors.surface);
    _polygon(canvas, const [
      Offset(14, 26), Offset(20, 100), Offset(28, 100), Offset(22, 26),
    ], AppColors.popcorn);
    _polygon(canvas, const [
      Offset(44, 26), Offset(50, 100), Offset(58, 100), Offset(52, 26),
    ], AppColors.popcorn);
    _polygon(canvas, const [
      Offset(14, 52), Offset(16, 62), Offset(56, 62), Offset(58, 52),
    ], AppColors.popcorn.withValues(alpha: 0.35));

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(36, 100), width: 32, height: 8),
      Paint()..color = AppColors.popcornDeep,
    );

    canvas.restore();
  }

  // Primitives ---------------------------------------------------------------

  void _circle(Canvas canvas, double cx, double cy, double r, Color color) =>
      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = color);

  void _polygon(Canvas canvas, List<Offset> points, Color color) {
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, Paint()..color = color);
  }

  void _shadow(
    Canvas canvas,
    double cx,
    double cy,
    double rx,
    double ry,
    double opacity,
  ) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      Paint()..color = Colors.black.withValues(alpha: opacity),
    );
  }

  // The animation is the repaint signal, so a rebuild only matters if it is a
  // different animation object.
  @override
  bool shouldRepaint(PopcornScenePainter oldDelegate) =>
      oldDelegate.animation != animation;
}
