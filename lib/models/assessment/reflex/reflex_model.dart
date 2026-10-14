

import 'package:e_prescription/const/quick_tech_json_parser.dart';

class ReflexSubcategory {
  final int? id;
  final String? deepTendonId;
  final String? numericValue;
  final String? textValue;
  final String? createdAt;
  final String? updatedAt;

  ReflexSubcategory({
    this.id,
    this.deepTendonId,
    this.numericValue,
    this.textValue,
    this.createdAt,
    this.updatedAt,
  });

  factory ReflexSubcategory.fromJson(Map<String, dynamic> json) {
    return ReflexSubcategory(
      id: parseInt(json['id']),
      deepTendonId: parseString(json['deep_tendon_id']),
      numericValue: parseString(json['numeric_value']),
      textValue: parseString(json['text_value']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'deep_tendon_id': deepTendonId,
    'numeric_value': numericValue,
    'text_value': textValue,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class DeepTendon {
  final int? id;
  final String? reflexId;
  final String? name;
  final String? type;
  final String? createdAt;
  final String? updatedAt;
  final List<ReflexSubcategory>? reflexSubcategories;

  DeepTendon({
    this.id,
    this.reflexId,
    this.name,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.reflexSubcategories,
  });

  factory DeepTendon.fromJson(Map<String, dynamic> json) {
    return DeepTendon(
      id: parseInt(json['id']),
      reflexId: parseString(json['reflex_id']),
      name: parseString(json['name']),
      type: parseString(json['type']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
      reflexSubcategories: json['reflex_subcategories'] is List
          ? (json['reflex_subcategories'] as List)
              .map((e) => e is Map<String, dynamic>
                  ? ReflexSubcategory.fromJson(e)
                  : e is Map
                      ? ReflexSubcategory.fromJson(Map<String, dynamic>.from(e))
                      : null)
              .whereType<ReflexSubcategory>()
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reflex_id': reflexId,
    'name': name,
    'type': type,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'reflex_subcategories': reflexSubcategories?.map((e) => e.toJson()).toList(),
  };
}

class ReflexModel {
  final int? id;
  final String? name;
  final String? createdAt;
  final String? updatedAt;
  final List<DeepTendon>? deepTendons;

  ReflexModel({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.deepTendons,
  });

  factory ReflexModel.fromJson(Map<String, dynamic> json) {
    return ReflexModel(
      id: parseInt(json['id']),
      name: parseString(json['name']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
      deepTendons: json['deep_tendons'] is List
          ? (json['deep_tendons'] as List)
              .map((e) => e is Map<String, dynamic>
                  ? DeepTendon.fromJson(e)
                  : e is Map
                      ? DeepTendon.fromJson(Map<String, dynamic>.from(e))
                      : null)
              .whereType<DeepTendon>()
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'deep_tendons': deepTendons?.map((e) => e.toJson()).toList(),
  };
}

class ReflexGrade {
  final String? message;
  final List<ReflexGrades>? reflexGrades;

  ReflexGrade({
    this.message,
    this.reflexGrades,
  });

  factory ReflexGrade.fromJson(Map<String, dynamic> json) {
    return ReflexGrade(
      message: parseString(json['message']),
      reflexGrades: json['reflex_grades'] is List
          ? (json['reflex_grades'] as List)
              .map((e) => e is Map<String, dynamic>
                  ? ReflexGrades.fromJson(e)
                  : e is Map
                      ? ReflexGrades.fromJson(Map<String, dynamic>.from(e))
                      : null)
              .whereType<ReflexGrades>()
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'reflex_grades': reflexGrades?.map((e) => e.toJson()).toList(),
  };
}

class ReflexGrades {
  final int? id;
  final String? fieldType;
  final String? numericValue;
  final String? textValue;
  final String? createdAt;
  final String? updatedAt;

  ReflexGrades({
    this.id,
    this.fieldType,
    this.numericValue,
    this.textValue,
    this.createdAt,
    this.updatedAt,
  });

  factory ReflexGrades.fromJson(Map<String, dynamic> json) {
    return ReflexGrades(
      id: parseInt(json['id']),
      fieldType: parseString(json['field_type']),
      numericValue: parseString(json['numeric_value']),
      textValue: parseString(json['text_value']),
      createdAt: parseString(json['created_at']),
      updatedAt: parseString(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'field_type': fieldType,
    'numeric_value': numericValue,
    'text_value': textValue,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}