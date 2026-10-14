import 'package:e_prescription/const/quick_tech_json_parser.dart';

class templetes {
  String? message;
  List<Templates>? templates;

  templetes({this.message, this.templates});

  factory templetes.fromJson(Map<String, dynamic> json) {
    List<Templates>? parsedTemplates;
    if (json['templates'] is List) {
      parsedTemplates = (json['templates'] as List)
          .map((v) => v is Map<String, dynamic>
              ? Templates.fromJson(v)
              : v is Map
                  ? Templates.fromJson(Map<String, dynamic>.from(v))
                  : null)
          .whereType<Templates>()
          .toList();
    }

    return templetes(
      message: parseString(json['message']),
      templates: parsedTemplates,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (templates != null) {
      data['templates'] = templates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// Alias for clean naming
typedef TemplatesResponse = templetes;

class Templates {
  int? id;
  String? templateValue;
  String? packageId;
  String? image;
  String? createdAt;
  String? updatedAt;

  Templates({
    this.id,
    this.templateValue,
    this.packageId,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Templates.fromJson(Map<String, dynamic> json) {
    return Templates(
      id: parseInt(json['id']),
      templateValue: parseString(json['template_value'] ?? json['templateValue']),
      packageId: parseString(json['package_id'] ?? json['packageId']),
      image: parseString(json['image']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['template_value'] = templateValue;
    data['package_id'] = packageId;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
