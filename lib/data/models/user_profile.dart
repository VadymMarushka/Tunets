class UserProfile {
  const UserProfile({required this.name, required this.email, this.phone});

  final String name;
  final String email;
  final String? phone;

  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
}
