import 'dart:convert';
import 'package:e_prescription/const/const.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:e_prescription/models/blogs.dart';

class QuickTechBlogController extends GetxController {
  RxList<Blog> blogs = <Blog>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  Future<void> fetchBlogs() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await http
          .get(Uri.parse('${Api.baseUrl}/api/blogs/all'))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data is Map) {
          blogs.assignAll(BlogResponse.fromJson(data).blogs);
        } else if (data is List) {
          blogs.assignAll(data.map((e) => Blog.fromJson(e)).toList());
        } else {
          blogs.clear();
        }
      } else {
        errorMessage.value = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load blogs. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<Blog?> fetchBlogDetails(int id) async {
    try {
      final response = await http
          .get(Uri.parse('${Api.baseUrl}/api/blog/details/$id'))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data is Map) {
          return BlogDetailsResponse.fromJson(data).blog ?? Blog.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('fetchBlogDetails error: $e');
    }
    return null;
  }
}