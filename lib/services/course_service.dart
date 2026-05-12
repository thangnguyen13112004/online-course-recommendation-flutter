import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';
import '../api_constants.dart';
import 'auth_service.dart';

class CourseService {
  static Future<List<ApiCourse>> searchCourses(String query) async {
    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/Courses?search=$query'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List coursesJson = data['data'];
        return coursesJson.map((json) => ApiCourse.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getCourseDetails(int courseId) async {
    try {
      final user = await AuthService.getCurrentUser();
      final headers = user != null ? {'Authorization': 'Bearer ${user.token}'} : <String, String>{};
      
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Courses/$courseId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final courseData = jsonDecode(response.body);
        bool isCompleted = false;
        bool isEnrolled = false;
        dynamic userReview;

        final user = await AuthService.getCurrentUser();
        if (user != null) {
          try {
            final contentResponse = await http.get(
              Uri.parse('${ApiConstants.baseUrl}/Learning/course/$courseId'),
              headers: {'Authorization': 'Bearer ${user.token}'},
            );
            if (contentResponse.statusCode == 200) {
              final contentData = jsonDecode(contentResponse.body);
              isCompleted = (contentData['phanTramTienDo'] ?? 0) >= 100;
              isEnrolled = true;
            }
          } catch (e) {
            // Ignore error if not enrolled
          }

          if (courseData['danhGia'] != null) {
            final reviews = courseData['danhGia'] as List;
            try {
              userReview = reviews.firstWhere(
                (r) => r['nguoiDanhGia'] != null && r['nguoiDanhGia']['maNguoiDung'] == user.userId,
              );
            } catch (e) {
              userReview = null;
            }
          }
        }

        return {
          'course': courseData,
          'isCompleted': isCompleted,
          'isEnrolled': isEnrolled,
          'userReview': userReview,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<RecommendedCourse>> getRecommendedCourses() async {
    final user = await AuthService.getCurrentUser();
    if (user == null) return [];

    try {
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/Recommendation/user-profile/${user.userId}'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => RecommendedCourse.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<EnrolledCourse>> getMyCourses() async {
    final user = await AuthService.getCurrentUser();
    if (user == null) return [];

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Learning/my-courses'),
        headers: {'Authorization': 'Bearer ${user.token}'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List? coursesJson = data['data'] ?? data['Data'];
        if (coursesJson == null) return [];
        return coursesJson.map((json) => EnrolledCourse.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getCourseContent(int courseId) async {
    final user = await AuthService.getCurrentUser();
    if (user == null) return null;
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Learning/course/$courseId'),
        headers: {'Authorization': 'Bearer ${user.token}'},
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> completeLesson(int lessonId) async {
    final user = await AuthService.getCurrentUser();
    if (user == null) return null;
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/Learning/lesson/$lessonId/complete'),
        headers: {'Authorization': 'Bearer ${user.token}'},
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> buyCourse(int courseId) async {
    final user = await AuthService.getCurrentUser();
    if (user == null) return false;

    try {
      // 1. Add to cart
      final addCartRes = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/Cart/$courseId'),
        headers: {'Authorization': 'Bearer ${user.token}'},
      );

      // If status is not 200 and not 400 (already in cart/owned), fail
      if (addCartRes.statusCode != 200 && addCartRes.statusCode != 400) {
        return false;
      }

      // 2. Checkout the cart
      final checkoutRes = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/Orders/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode({'PhuongThucThanhToan': 'Thanh toán trực tiếp'}),
      );

      return checkoutRes.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> enrollCourse(int courseId) async {
    final user = await AuthService.getCurrentUser();
    if (user == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/Learning/enroll/$courseId'),
        headers: {'Authorization': 'Bearer ${user.token}'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> rateCourse(int courseId, double rating, String review) async {
    final user = await AuthService.getCurrentUser();
    if (user == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/Interactions/rate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${user.token}',
        },
        body: jsonEncode({'MaKhoaHoc': courseId, 'Rating': rating, 'BinhLuan': review}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> toggleBookmark(int courseId) async {
    final user = await AuthService.getCurrentUser();
    if (user == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/Interactions/like/$courseId'),
        headers: {'Authorization': 'Bearer ${user.token}'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<ApiCourse>> getBookmarks() async {
    final user = await AuthService.getCurrentUser();
    if (user == null) return [];

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Interactions/likes'),
        headers: {'Authorization': 'Bearer ${user.token}'},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => ApiCourse.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
