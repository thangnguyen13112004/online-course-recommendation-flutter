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
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/Courses/$courseId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
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
        final List coursesJson = data['data'];
        return coursesJson.map((json) => EnrolledCourse.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
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
