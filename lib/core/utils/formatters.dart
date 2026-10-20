/// Date and number formatting without extra packages.
abstract final class Formatters {
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _monthsFull = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// `29 Sep 2026`
  static String date(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// `06:30`
  static String time(DateTime d) =>
      '${_twoDigits(d.hour)}:${_twoDigits(d.minute)}';

  /// `Mon, 21 Sep 2026 · 06:30`
  static String tripDateTime(DateTime d) =>
      '${_weekdays[d.weekday - 1]}, ${date(d)} · ${time(d)}';

  /// `September 2026`
  static String monthYear(DateTime d) =>
      '${_monthsFull[d.month - 1]} ${d.year}';

  /// `2.3 kg` — one decimal, as in the mockup.
  static String kg(double value) => '${value.toStringAsFixed(1)} kg';

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
