import 'dart:convert';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';

import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:e_prescription/services/quick_tech_retry_service.dart';
  var token=QuickTechAuthStorageService.getToken();
class QuickTechMusclePowerController extends GetxController {
  Future<int> submitMusclePowerData({required int patientId}) async {
    final url = '${Api.baseUrl}/api/muscle-power-rom/store';
    final body = {
      'add_type': 'muscle',
      'patient_id': patientId,
      'upper_movement': uppermovementController.text,
      'upper_muscle': uppermusclenameController.text,
      'upper_initial_left': upperleftInitialController.text,
      'upper_initial_right': upperrightInitialController.text,
      'upper_discharge_left': upperleftDischargeController.text,
      'upper_discharge_right': upperrightDischargeController.text,
      'upper_comment': upperCommentController.text,
      'oxford_muscle_grading': oxfordMuscle.value,
      'lower_movement': lowermovementController.text,
      'lower_muscle': lowermusclenameController.text,
      'lower_initial_left': lowerleftInitialController.text,
      'lower_initial_right': lowerrightInitialController.text,
      'lower_discharge_left': lowerleftDischargeController.text,
      'lower_discharge_right': lowerrightDischargeController.text,
      'lower_comment': lowerCommentController.text,
    };
    try {
      final response = await retryRequest(() => http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
            body: jsonEncode(body),
          ));
      print('Muscle power status: ${response.statusCode}');
      print('Muscle power response: ${response.body}');
      return response.statusCode;
    } catch (e) {
      print('Error storing muscle power data: $e');
      return 500;
    }
  }
  //Upper Limb
  TextEditingController uppermovementController = TextEditingController();
  TextEditingController uppermusclenameController = TextEditingController();
  TextEditingController upperleftInitialController = TextEditingController();
  TextEditingController upperrightInitialController = TextEditingController();
  TextEditingController upperleftDischargeController = TextEditingController();
  TextEditingController upperrightDischargeController = TextEditingController();
  TextEditingController upperCommentController = TextEditingController();
  //Lower limb
  TextEditingController lowermovementController = TextEditingController();
  TextEditingController lowermusclenameController = TextEditingController();
  TextEditingController lowerleftInitialController = TextEditingController();
  TextEditingController lowerrightInitialController = TextEditingController();
  TextEditingController lowerleftDischargeController = TextEditingController();
  TextEditingController lowerrightDischargeController = TextEditingController();
  TextEditingController lowerCommentController = TextEditingController();
  var oxfordMuscle = Rx<String?>(null);
  var oxfordMuscleVisible = false.obs;
  TextEditingController oxfordmuscleController = TextEditingController();

  var oxfordMuscleGrades = <OxfordMuscleModel>[].obs;
  var isLoadingOxford = true.obs;
  var _oxfordGradesFetched = false;
  
  Future<void> fetchOxfordMuscleGrades() async {
    // Only fetch once - prevents duplicate requests and rate limiting
    if (_oxfordGradesFetched || oxfordMuscleGrades.isNotEmpty) {
      isLoadingOxford.value = false;
      return;
    }
    
    try {
      isLoadingOxford.value = true;
      final response = await http.get(
        Uri.parse("${Api.getOxfordMuscleAsses}"),
       
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List list = data['oxford_muscle_grades'];
        oxfordMuscleGrades.value =
            list.map((e) => OxfordMuscleModel.fromJson(e)).toList();
        _oxfordGradesFetched = true;
        print("Oxford Muscle Grades fetched successfully: ${oxfordMuscleGrades.length}");
      } else {
        print("Error Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
        // Don't show snackbar for 429 (rate limit), just log it
        if (response.statusCode != 429) {
          QuickTechSnackbar.error("Failed to fetch grades: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Exception in fetchOxfordMuscleGrades: $e");
      QuickTechSnackbar.error("Exception: $e");
    } finally {
      isLoadingOxford.value = false;
    }
  }
// Oxford Muscle
  //var oxfordmuscleOptions = ['0', '1', '2', '3', '4', '5'].obs;

   void toggleOxfordMuscle() {
    oxfordMuscleVisible.value = !oxfordMuscleVisible.value;
  }

  void updateOxfordMuscle(String muscle) {
    oxfordMuscle.value = muscle;
    // do NOT set oxfordmuscleController.text — it resets cursor on web
  }


  bool isMusclePowernull() {
  return (uppermovementController.text.isNotEmpty) ||
         (uppermusclenameController.text.isNotEmpty) ||
         (upperleftInitialController.text.isNotEmpty) ||
         (upperrightInitialController.text.isNotEmpty) ||
         (upperleftDischargeController.text.isNotEmpty) ||
         (upperrightDischargeController.text.isNotEmpty) ||
         (upperCommentController.text.isNotEmpty) ||

         (lowermovementController.text.isNotEmpty) ||
         (lowermusclenameController.text.isNotEmpty) ||
         (lowerleftInitialController.text.isNotEmpty) ||
         (lowerrightInitialController.text.isNotEmpty) ||
         (lowerleftDischargeController.text.isNotEmpty) ||
         (lowerrightDischargeController.text.isNotEmpty) ||
         (lowerCommentController.text.isNotEmpty) ||

         (oxfordMuscle.value?.isNotEmpty ?? false); // Oxford muscle value
}

  bool isMusclePowerNull() {
  return uppermovementController.text.isNotEmpty ||
         uppermusclenameController.text.isNotEmpty ||
         upperleftInitialController.text.isNotEmpty ||
         upperrightInitialController.text.isNotEmpty ||
         upperleftDischargeController.text.isNotEmpty ||
         upperrightDischargeController.text.isNotEmpty ||
         upperCommentController.text.isNotEmpty ||

         lowermovementController.text.isNotEmpty ||
         lowermusclenameController.text.isNotEmpty ||
         lowerleftInitialController.text.isNotEmpty ||
         lowerrightInitialController.text.isNotEmpty ||
         lowerleftDischargeController.text.isNotEmpty ||
         lowerrightDischargeController.text.isNotEmpty ||
         lowerCommentController.text.isNotEmpty ||

         oxfordMuscle.value != null && oxfordMuscle.value!.isNotEmpty; // Oxford muscle value
}

  /// Standardized: returns true when section has data to display
  bool hasData() => isMusclePowerNull();

   void printInputs() {
    print("Upper Limb Movement: ${uppermovementController.text}");
    print("Upper Limb Muscle Name: ${uppermusclenameController.text}");
    print("Upper Left Initial: ${upperleftInitialController.text}");
    print("Upper Right Initial: ${upperrightInitialController.text}");
    print("Upper Left Discharge: ${upperleftDischargeController.text}");
    print("Upper Right Discharge: ${upperrightDischargeController.text}");
    print("Upper Comment: ${upperCommentController.text}");

    print("Lower Limb Movement: ${lowermovementController.text}");
    print("Lower Limb Muscle Name: ${lowermusclenameController.text}");
    print("Lower Left Initial: ${lowerleftInitialController.text}");
    print("Lower Right Initial: ${lowerrightInitialController.text}");
    print("Lower Left Discharge: ${lowerleftDischargeController.text}");
    print("Lower Right Discharge: ${lowerrightDischargeController.text}");
    print("Lower Comment: ${lowerCommentController.text}");

    print("Oxford Muscle Score: ${oxfordMuscle.value}");
  }

  void clearMusclePower() {
    uppermovementController.clear();
    uppermusclenameController.clear();
    upperleftInitialController.clear();
    upperrightInitialController.clear();
    upperleftDischargeController.clear();
    upperrightDischargeController.clear();
    upperCommentController.clear();
    lowermovementController.clear();
    lowermusclenameController.clear();
    lowerleftInitialController.clear();
    lowerrightInitialController.clear();
    lowerleftDischargeController.clear();
    lowerrightDischargeController.clear();
    lowerCommentController.clear();
    oxfordMuscle.value = null;
    update();
  }
}


class OxfordMuscleModel {
  final int id;
  final String numericValue;
  final String textValue;

  OxfordMuscleModel({
    required this.id,
    required this.numericValue,
    required this.textValue,
  });

  factory OxfordMuscleModel.fromJson(Map<String, dynamic> json) {
    return OxfordMuscleModel(
      id: json['id'],
      numericValue: json['numeric_value'], // match API key
      textValue: json['text_value'],
    );
  }
}
