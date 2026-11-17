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

  // Value equality: widgets that select the user rebuild only when
  // something they show has actually changed.
  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.uid == uid &&
      other.name == name &&
      other.email == email &&
      other.phone == phone &&
      other.photoUrl == photoUrl;

  @override
  int get hashCode => Object.hash(uid, name, email, phone, photoUrl);
}
