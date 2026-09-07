import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_text_styles.dart';
import 'popcorn_scene_painter.dart';

/// The animated popcorn illustration shown on an empty screen, with its
/// caption.
///
/// One [AnimationController] drives the whole thing — the kernels, the bucket,
/// the cup and the caption. A second ticker for the text would cost another
/// frame callback for two properties.
///
/// Cheap by construction:
/// - the painter takes the controller as its `repaint`, so each frame repaints
///   the picture and never rebuilds the widget tree;
/// - a [RepaintBoundary] keeps those repaints off the rest of the screen;
/// - `TickerMode` in `LayoutScreen` already freezes this whenever Search is not
///   the visible tab, so it costs nothing sitting in the background.
class PopcornEmptyArt extends StatefulWidget {
  const PopcornEmptyArt({super.key, required this.message, this.width});

  final String message;

  /// Defaults to the 124 the still illustration used, so nothing shifts.
  final double? width;

  @override
  State<PopcornEmptyArt> createState() => _PopcornEmptyArtState();
}

class _PopcornEmptyArtState extends State<PopcornEmptyArt>
    with SingleTickerProviderStateMixin {
  /// Slow on purpose. This sits under a search box the user is about to type
  /// in — it should read as alive, not as something demanding attention.
  static const Duration _cycle = Duration(milliseconds: 2800);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _cycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Honours the OS "reduce motion" setting: the scene still draws, it just
    // holds a still frame instead of looping.
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (reduceMotion) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? 124.w;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            size: Size(
              width,
              width *
                  PopcornScenePainter.scene.height /
                  PopcornScenePainter.scene.width,
            ),
            painter: PopcornScenePainter(_controller),
          ),
        ),
        SizedBox(height: 16.h),
        AnimatedBuilder(
          animation: _controller,
          // The text never changes, so it is built once and reused rather than
          // rebuilt on every frame.
          child: Text(
            widget.message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
          builder: (context, child) {
            final wave = math.sin(2 * math.pi * _controller.value);
            return Transform.translate(
              offset: Offset(0, -2 * wave),
              child: Opacity(opacity: 0.78 + 0.22 * (0.5 + 0.5 * wave), child: child),
            );
          },
        ),
      ],
    );
  }
}
