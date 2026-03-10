class Mentor {
  final String id;
  final String name;
  final String role;
  final String? imageUrl; // Optional: in case we want to add real images later

  Mentor({
    required this.id,
    required this.name,
    required this.role,
    this.imageUrl,
  });
}

class Session {
  final String id;
  final String title;
  final String subtitle;
  final String? thumbnailUrl; // Optional: in case we want to add real images later

  Session({
    required this.id,
    required this.title,
    required this.subtitle,
    this.thumbnailUrl,
  });
}

class Course {
  final String id;
  final String title;
  final double progress; // 0.0 to 1.0
  final String? imageUrl;

  Course({
    required this.id,
    required this.title,
    required this.progress,
    this.imageUrl,
  });
}

class Bookmark {
  final String id;
  final String title;
  final String author;
  final String? imageUrl;

  Bookmark({
    required this.id,
    required this.title,
    required this.author,
    this.imageUrl,
  });
}

class UserProfile {
  final String name;
  final String email;
  final String? avatarUrl;

  UserProfile({
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}
