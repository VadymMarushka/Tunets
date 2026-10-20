import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// App logo from the design mockup: white fish on a rounded teal tile.
/// The same drawing is used for the launcher icons (assets/icon).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});

  final double size;

  /// Tile background: CSS `linear-gradient(145deg, …)` from the mockup.
  static const gradient = LinearGradient(
    begin: Alignment(-0.57, -0.82),
    end: Alignment(0.57, 0.82),
    colors: [Color(0xFF12948D), Color(0xFF0B7A75), Color(0xFF075E5A)],
    stops: [0, 0.6, 1],
  );

  /// Fish eye color — the tile color shows through.
  static const eyeColor = Color(0xFF0B7A75);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: gradient,
      ),
      alignment: Alignment.center,
      child: FishMark(size: size * 0.9),
    );
  }
}

/// Fish silhouette in a 48×48 grid, nose on the left, centered at (24, 24).
/// Shared by the logo ([FishMark]) and the fish icon ([FishIcon]).
final Path _fishBody = Path()
  ..moveTo(5, 24.1) // nose
  ..cubicTo(7.8, 20.3, 12, 18.6, 18, 18.2) // head
  ..cubicTo(20, 16.8, 21.8, 15.2, 23.5, 14.4) // dorsal fin, leading edge
  ..cubicTo(25.5, 15.6, 27.3, 17.3, 28.5, 19.1) // dorsal fin, trailing edge
  ..cubicTo(31, 19.8, 33.3, 20.9, 35.3, 22.1) // back
  ..cubicTo(37.5, 20, 40, 18, 42.6, 16.4) // upper tail lobe
  ..cubicTo(41, 19.2, 40, 21.6, 39.7, 24) // tail fork
  ..cubicTo(40, 26.4, 41, 28.8, 42.6, 31.6)
  ..cubicTo(40, 30, 37.5, 28, 35.3, 25.9) // lower tail lobe
  ..cubicTo(34.3, 26.8, 33.2, 27.6, 32, 28.2) // belly
  ..cubicTo(31.9, 29.2, 31.9, 30.3, 31.8, 31.3) // anal fin
  ..cubicTo(30.6, 30.6, 29.7, 29.8, 29, 28.9)
  ..cubicTo(27, 29.6, 24.8, 30, 22.6, 30.1) // belly
  ..cubicTo(22.4, 31.2, 22.1, 32.2, 21.6, 33) // pelvic fin
  ..cubicTo(20.4, 31.9, 19.2, 30.8, 18.2, 29.8)
  ..cubicTo(13, 29.4, 8, 27.6, 5, 24.1) // chin
  ..close();

/// The logo glyph: a fish caught on a hook, pulled up by the line
/// (white fish, eye in the tile color).
class FishMark extends StatelessWidget {
  const FishMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _HookedFishPainter());
  }
}

class _HookedFishPainter extends CustomPainter {
  /// The fish is tilted nose-up, as if pulled by the line.
  static const _tilt = 22 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 48);

    canvas
      ..save()
      ..translate(25.5, 28)
      ..rotate(_tilt)
      ..translate(-24, -24)
      ..drawPath(_fishBody, Paint()..color = Colors.white)
      ..drawCircle(
        const Offset(12, 22.4),
        1.9,
        Paint()..color = AppLogo.eyeColor,
      )
      ..restore();

    // Fishing line: thin and semi-transparent.
    canvas.drawLine(
      const Offset(10, 0),
      const Offset(10, 16.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 1.1,
    );
    // Hook: its bend sits right at the fish's nose.
    canvas.drawPath(
      Path()
        ..moveTo(10, 15.5)
        ..lineTo(10, 19.1)
        ..arcToPoint(
          const Offset(5.6, 19.1),
          radius: const Radius.circular(2.2),
        )
        ..lineTo(5.6, 17.6),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.6,
    );
  }

  @override
  bool shouldRepaint(_HookedFishPainter oldDelegate) => false;
}

/// The app's fish symbol as an icon (the logo fish without the hook),
/// used for catches. Behaves like [Icon]: size and color come from the
/// surrounding [IconTheme] unless given. The eye is cut out, so it works on
/// any background.
class FishIcon extends StatelessWidget {
  const FishIcon({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final iconSize = size ?? theme.size ?? 24;
    return CustomPaint(
      size: Size.square(iconSize),
      painter: _FishIconPainter(color ?? theme.color ?? Colors.black),
    );
  }
}

class _FishIconPainter extends CustomPainter {
  _FishIconPainter(this.color);

  final Color color;

  /// Body with the eye cut out. The eye is a bit larger than on the logo
  /// so it stays visible at 14–16 px.
  static final _shape = Path.combine(
    PathOperation.difference,
    _fishBody,
    Path()
      ..addOval(Rect.fromCircle(center: const Offset(12, 22.4), radius: 2.6)),
  );

  @override
  void paint(Canvas canvas, Size size) {
    // The fish is long and flat (x 5…42.6 of the 48 grid), so the icon uses
    // a tighter 40-unit box around it — otherwise it looks tiny next to text.
    canvas
      ..scale(size.width / 40)
      ..translate(-4, -4)
      ..drawPath(_shape, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_FishIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Round avatar: a person silhouette, or the user's initial when [initial]
/// is set (compact header avatar).
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.size = 96, this.initial});

  final double size;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.primaryContainer, palette.primary],
        ),
      ),
      alignment: Alignment.center,
      child: initial != null
          ? Text(
              initial!,
              style: TextStyle(
                fontSize: size * 0.45,
                fontWeight: FontWeight.w600,
                color: palette.onPrimaryContainer,
              ),
            )
          : Icon(Icons.person, size: size * 0.7, color: palette.onPrimary),
    );
  }
}

/// Catch / trip thumbnail. Real photos arrive with media upload (FR-5) in a
/// later lab; until then a water-colored tile with a fish glyph is shown.
class FishThumbnail extends StatelessWidget {
  const FishThumbnail({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.small * 2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.primaryContainer, palette.surfaceVariant],
        ),
      ),
      alignment: Alignment.center,
      child: FishIcon(size: size * 0.7, color: palette.primary),
    );
  }
}

/// Wide trip photo used on the details screen.
class TripPhoto extends StatelessWidget {
  const TripPhoto({super.key, this.height = 160, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.fluent),
      child: Image.asset(
        'assets/images/fishing.jpg',
        height: height,
        width: width ?? double.infinity,
        fit: BoxFit.cover,
        semanticLabel: 'Trip photo',
      ),
    );
  }
}
