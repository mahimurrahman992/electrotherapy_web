
import 'package:e_prescription/const/quick_tech_json_parser.dart';

class Patient {
  final int id;
  final String name;
  final String age;
  final String userId;
  final String gender;
  final String date;

  Patient(this.name, this.age, this.gender, this.date, this.id, this.userId);

  factory Patient.fromJson(Map<String, dynamic> json) {
    // Parse date safely
    DateTime parsedDate = DateTime.now();
    final prescriptionDateStr = parseString(json['prescription_date'] ?? json['date']);
    final createdAtStr = parseString(json['created_at']);

    if (prescriptionDateStr != null && prescriptionDateStr.trim().isNotEmpty) {
      final trimmed = prescriptionDateStr.trim();
      final directParsed = DateTime.tryParse(trimmed);
      if (directParsed != null) {
        parsedDate = directParsed;
      } else {
        try {
          final parts = trimmed.split(RegExp(r'[-/.]'));
          if (parts.length == 3) {
            final year = parseInt(parts[0]);
            final month = parseInt(parts[1]);
            final day = parseInt(parts[2]);
            if (year != null && month != null && day != null) {
              parsedDate = DateTime(year, month, day);
            }
          }
        } catch (_) {}
      }
    } else if (createdAtStr != null && createdAtStr.trim().isNotEmpty) {
      parsedDate = DateTime.tryParse(createdAtStr.trim()) ?? DateTime.now();
    }

    return Patient(
      parseString(json['name'] ?? json['patient_name']) ?? '',
      parseString(json['age']) ?? '',
      parseString(json['gender'] ?? json['sex']) ?? '',
      parsedDate.toIso8601String().split('T').first,
      parseInt(json['id'] ?? json['patient_id']) ?? 0,
      parseString(json['user_id'] ?? json['userId']) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'date': date,
      'user_id': userId,
    };
  }
}