/// Signed-in user as the UI sees it (built from the Firebase user).
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    this.uid = '',
    this.phone,
    this.photoUrl,
  });

  final String uid;
  final String name;
  final String email;
  final String? phone;

  /// HTTPS link to the profile photo (Firebase stores the URL only).
  final String? photoUrl;

  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
}
