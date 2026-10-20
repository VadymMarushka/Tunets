import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
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
      child: FishMark(size: size * 0.66),
    );
  }
}

/// The fish glyph of the logo (white body, eye in the tile color).
class FishMark extends StatelessWidget {
  const FishMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _FishPainter());
  }
}

class _FishPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Based on the mockup SVG (viewBox 0 0 48 48), with a slimmer, longer
    // body and a smaller tail.
    canvas.scale(size.width / 48);
    final body = Path()
      ..moveTo(5, 24)
      ..cubicTo(10, 16.5, 23, 14, 34, 19.5)
      ..lineTo(42, 16)
      ..lineTo(42, 32)
      ..lineTo(34, 28.5)
      ..cubicTo(23, 34, 10, 31.5, 5, 24)
      ..close();
    canvas
      ..drawPath(body, Paint()..color = Colors.white)
      ..drawCircle(
        const Offset(13.5, 22.5),
        2.2,
        Paint()..color = AppLogo.eyeColor,
      );
  }

  @override
  bool shouldRepaint(_FishPainter oldDelegate) => false;
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
      child: Icon(AppIcons.fish, size: size * 0.55, color: palette.primary),
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
