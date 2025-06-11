
// Model class for user profile
class UserProfile {
  final String name;
  final String title;
  final String location;
  final String projects;
  final String followers;
  final String following;
  final String avatarUrl;

  UserProfile({
    required this.name,
    required this.title,
    required this.location,
    required this.projects,
    required this.followers,
    required this.following,
    this.avatarUrl = '',
  });
}