import 'package:fluent_ui/fluent_ui.dart' as fl;
import 'package:flutter/material.dart';

import '../platform/platform_style.dart';

/// Icons by meaning: Material Symbols on Android, Fluent icons on Windows.
///
/// Domain glyphs that Fluent has no equivalent for (fish, tackle, weather
/// readings) use the Material set on both platforms.
abstract final class AppIcons {
  static IconData _pick(IconData material, IconData fluent) =>
      PlatformStyle.isFluent ? fluent : material;

  static IconData get home => _pick(Icons.home_outlined, fl.FluentIcons.home);
  static IconData get homeSelected => _pick(Icons.home, fl.FluentIcons.home);
  static IconData get trips =>
      _pick(Icons.list_alt_outlined, fl.FluentIcons.bulleted_list);
  static IconData get tripsSelected =>
      _pick(Icons.list_alt, fl.FluentIcons.bulleted_list);
  static IconData get profile =>
      _pick(Icons.person_outline, fl.FluentIcons.contact);
  static IconData get profileSelected =>
      _pick(Icons.person, fl.FluentIcons.contact);

  static IconData get add => _pick(Icons.add, fl.FluentIcons.add);
  static IconData get edit => _pick(Icons.edit_outlined, fl.FluentIcons.edit);
  static IconData get delete =>
      _pick(Icons.delete_outline, fl.FluentIcons.delete);
  static IconData get open =>
      _pick(Icons.open_in_new, fl.FluentIcons.open_in_new_window);
  static IconData get save => _pick(Icons.check, fl.FluentIcons.check_mark);
  static IconData get cancel => _pick(Icons.close, fl.FluentIcons.cancel);
  static IconData get back => _pick(Icons.arrow_back, fl.FluentIcons.back);
  static IconData get search => _pick(Icons.search, fl.FluentIcons.search);
  static IconData get calendar =>
      _pick(Icons.calendar_today_outlined, fl.FluentIcons.calendar);
  static IconData get clock =>
      _pick(Icons.schedule_outlined, fl.FluentIcons.clock);
  static IconData get mail => _pick(Icons.mail_outline, fl.FluentIcons.mail);
  static IconData get lock => _pick(Icons.lock_outline, fl.FluentIcons.lock);
  static IconData get synced =>
      _pick(Icons.cloud_done_outlined, fl.FluentIcons.cloud);
  static IconData get offline =>
      _pick(Icons.cloud_off_outlined, fl.FluentIcons.cloud_not_synced);
  static IconData get photo =>
      _pick(Icons.add_photo_alternate_outlined, fl.FluentIcons.photo2_add);
  static IconData get camera =>
      _pick(Icons.photo_camera_outlined, fl.FluentIcons.camera);
  static IconData get gallery =>
      _pick(Icons.photo_library_outlined, fl.FluentIcons.photo_collection);
  static IconData get signOut => _pick(Icons.logout, fl.FluentIcons.sign_out);
  static IconData get notes =>
      _pick(Icons.notes_outlined, fl.FluentIcons.quick_note);
  static IconData get trophy =>
      _pick(Icons.emoji_events_outlined, fl.FluentIcons.trophy2);
  static IconData get waterBody =>
      _pick(Icons.water_outlined, fl.FluentIcons.globe);

  static const IconData fish = Icons.set_meal_outlined;
  static const IconData tackle = Icons.phishing;
  static const IconData temperature = Icons.device_thermostat;
  static const IconData pressure = Icons.speed;
  static const IconData wind = Icons.air;
  static const IconData weight = Icons.scale_outlined;
  static const IconData visibility = Icons.visibility_outlined;
  static const IconData visibilityOff = Icons.visibility_off_outlined;
}
