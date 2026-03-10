import 'models.dart';

class SampleData {
  static final List<Mentor> mentors = [
    Mentor(
      id: 'm1',
      name: 'Heather Kunde',
      role: 'Principal Engineer | Director ...',
    ),
    Mentor(
      id: 'm2',
      name: 'John Doe',
      role: 'Senior Educator | Math...',
    ),
    Mentor(
      id: 'm3',
      name: 'Alice Smith',
      role: 'Lead Designer | UI/UX',
    ),
    Mentor(
      id: 'm4',
      name: 'Bob Johnson',
      role: 'Mobile Developer | Flutter',
    ),
  ];

  static final List<Session> sessions = [
    Session(
      id: 's1',
      title: 'Managing Education\nPrograms for\nInternational...',
      subtitle: 'Managing Education Progra...',
    ),
    Session(
      id: 's2',
      title: 'Advanced Mathematics\nfor High School...',
      subtitle: 'Advanced Math Concepts...',
    ),
    Session(
      id: 's3',
      title: 'Introduction to\nFlutter Development',
      subtitle: 'Build your first app...',
    ),
    Session(
      id: 's4',
      title: 'UI/UX Design\nPrinciples',
      subtitle: 'Creating better interfaces...',
    ),
  ];

  static final List<Course> courses = [
    Course(
      id: 'c1',
      title: 'Advanced Flutter Development',
      progress: 0.2,
    ),
    Course(
      id: 'c2',
      title: 'Machine Learning A-Z',
      progress: 0.65,
    ),
    Course(
      id: 'c3',
      title: 'UI/UX Design Masterclass',
      progress: 0.05,
    ),
    Course(
      id: 'c4',
      title: 'Python for Data Science',
      progress: 0.9,
    ),
  ];

  static final List<Bookmark> bookmarks = [
    Bookmark(
      id: 'b1',
      title: 'Introduction to Machine Learning',
      author: 'By Andrew Ng',
    ),
    Bookmark(
      id: 'b2',
      title: 'Clean Code Principles',
      author: 'By Robert C. Martin',
    ),
    Bookmark(
      id: 'b3',
      title: 'Flutter State Management',
      author: 'By Reso Coder',
    ),
    Bookmark(
      id: 'b4',
      title: 'Design Patterns in Dart',
      author: 'By Flutter Team',
    ),
    Bookmark(
      id: 'b5',
      title: 'Building REST APIs',
      author: 'By Code with Mosh',
    ),
    Bookmark(
      id: 'b6',
      title: 'The Algorithms of Life',
      author: 'By Brian Christian',
    ),
  ];

  static final UserProfile currentUser = UserProfile(
    name: 'Joffin',
    email: 'joffin@example.com',
  );
}
