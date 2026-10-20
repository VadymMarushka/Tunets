import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';

/// App logo: fish glyph on a rounded teal tile.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14918B), Color(0xFF0B7A75), Color(0xFF05504C)],
        ),
      ),
      child: Icon(AppIcons.fish, color: Colors.white, size: size * 0.55),
    );
  }
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
