import 'package:e_prescription/const/quick_tech_json_parser.dart';
import 'package:e_prescription/utils/api.dart';

class BlogResponse {
  final String message;
  final List<Blog> blogs;

  BlogResponse({
    required this.message,
    required this.blogs,
  });

  factory BlogResponse.fromJson(dynamic json) {
    if (json is! Map) {
      return BlogResponse(message: '', blogs: []);
    }
    final list = json['blogs'] ?? json['data'];
    return BlogResponse(
      message: parseString(json['message']) ?? '',
      blogs: list is List
          ? list
              .map((e) => Blog.fromJson(e))
              .where((b) => b.id != 0 || b.title.isNotEmpty)
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'blogs': blogs.map((e) => e.toJson()).toList(),
    };
  }
}

class BlogDetailsResponse {
  final String message;
  final Blog? blog;

  BlogDetailsResponse({
    required this.message,
    this.blog,
  });

  factory BlogDetailsResponse.fromJson(dynamic json) {
    if (json is! Map) {
      return BlogDetailsResponse(message: '', blog: null);
    }
    final rawBlog = json['blog'] ?? json['data'];
    return BlogDetailsResponse(
      message: parseString(json['message']) ?? '',
      blog: rawBlog != null ? Blog.fromJson(rawBlog) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      if (blog != null) 'blog': blog!.toJson(),
    };
  }
}

class Blog {
  final int id;
  final String image;
  final String title;
  final String shortDescription;
  final String longDescription;
  final String createdAt;

  Blog({
    required this.id,
    required this.image,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.createdAt,
  });

  String get fullImageUrl {
    if (image.isEmpty) return '';
    if (image.startsWith('http://') || image.startsWith('https://')) return image;
    if (image.startsWith('/')) return '${Api.baseUrl}$image';
    return '${Api.baseUrl}/$image';
  }

  factory Blog.fromJson(dynamic json) {
    if (json is! Map) {
      return Blog(
        id: 0,
        image: '',
        title: '',
        shortDescription: '',
        longDescription: '',
        createdAt: '',
      );
    }

    final longDesc = parseString(
          json['long_description'] ?? json['longDescription'] ?? json['description'],
        ) ??
        '';

    var shortDesc = parseString(
          json['short_description'] ?? json['shortDescription'],
        ) ??
        '';

    if (shortDesc.isEmpty && longDesc.isNotEmpty) {
      final stripped = longDesc
          .replaceAll(RegExp(r'<[^>]*>'), ' ')
          .replaceAll(RegExp(r'&nbsp;'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      shortDesc = stripped.length > 150 ? '${stripped.substring(0, 150)}...' : stripped;
    }

    return Blog(
      id: parseInt(json['id']) ?? 0,
      image: parseString(json['image']) ?? '',
      title: parseString(json['title']) ?? '',
      shortDescription: shortDesc,
      longDescription: longDesc,
      createdAt: parseString(json['created_at'] ?? json['createdAt']) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'short_description': shortDescription,
      'long_description': longDescription,
      'created_at': createdAt,
    };
  }
}
