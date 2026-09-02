
import 'dart:convert';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/controllers/assessment_controller/patient_info/quick_tech_patient_info_controlle.dart';
import 'package:e_prescription/controllers/assessment_controller/quick_tech_assessment_controller.dart';
import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:http/http.dart' as http;
import 'package:e_prescription/services/quick_tech_retry_service.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';
var token=QuickTechAuthStorageService.getToken();
final QuickTechPatientInfoController patientInfoController = locator.get<QuickTechPatientInfoController>();
class QuickTechDifferentialDiagnosisController extends GetxController {
  bool _categoryLoaded = false;
  Future<void>? _categoryLoadFuture;

  Future<void> ensureCategoryLoaded() async {
    if (_categoryLoaded) return;
    if (_categoryLoadFuture != null) return _categoryLoadFuture;

    _categoryLoadFuture = () async {
      await assessmentController.fetchAssesmentId('Diagnosis', fetchAssesDiagnosis);
      // Only mark loaded if we actually have a category.
      _categoryLoaded = diagnosisCategory.value != null;
    }();

    try {
      await _categoryLoadFuture;
    } finally {
      // Allow retry later if it failed.
      _categoryLoadFuture = null;
    }
  }

  // Store assessment diagnosis to API
  Future<int> storeAssessmentDiagnosis() async {
    final url = '${Api.baseUrl}/api/assess/diagnosis/store';
    final patientId = patientInfoController.currentPatientId ?? patientInfoController.patientId.value;
    final subcategoryValues = selectedDiagnosis.map((d) => getDetailsController(d).text).toList();
    final diagSubcatIds = selectedDiagnosis.map((d) {
      final sub = diagnosisCategory.value?.subCategories.firstWhereOrNull((s) => s.name == d);
      return sub?.id;
    }).whereType<int>().toList();
    final diagChildcatIds = <int>[];
    selectedsubDiagnosis.forEach((diagnosis, children) {
      final sub = diagnosisCategory.value?.subCategories.firstWhereOrNull((s) => s.name == diagnosis);
      if (sub != null) {
        for (var childName in children) {
          final child = sub.childCategories.firstWhereOrNull((c) => c.name == childName);
          if (child != null) diagChildcatIds.add(child.id);
        }
      }
    });

    final body = {
      'subcategory_value': subcategoryValues,
      'patient_id': patientId,
      'add_type': 'assessment',
      'diagSubcatIds': diagSubcatIds,
      'diagChildcatIds': diagChildcatIds,
    };

    try {
      final response = await retryRequest(() => http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          ));

      print('Assessment diagnosis status: ${response.statusCode}');
      print('Assessment diagnosis response: ${response.body}');
      return response.statusCode;
    } catch (e) {
      print('Error storing assessment diagnosis: $e');
      return 500;
    }
  }
  final QuickTechAssessmentController assessmentController = locator.get<QuickTechAssessmentController>();
  TextEditingController diagnosisSearchController = TextEditingController();
  TextEditingController bodyTemperatureController = TextEditingController();
  TextEditingController musclePowerController = TextEditingController();
  TextEditingController fractureAtController = TextEditingController();
  TextEditingController dislocationOfController = TextEditingController();
  
  var diagnosisText = ''.obs;
  var isDiagnosisDropdownOpen = false.obs;
  var selectedDiagnosis = <String>[].obs;
  var selectedsubDiagnosis = <String, List<String>>{}.obs;
  var otherDiagnosis = ''.obs;
  var diagnosisList = <dynamic>[];

  var diagnosisCategory = Rxn<DiagnosisCategorys>();
  var isLoading = false.obs;

  Future<void> fetchAssesDiagnosis(int id) async {
    isLoading.value = true;
    final url = '${Api.baseUrl}/api/data/of/diagnosis-category/$id';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      diagnosisCategory.value = DiagnosisCategorys.fromJson(data['diagnosis_category']);
      diagnosisList = data['diagnosis_category']['diagnosis_subcategories'] ?? [];
    }
    isLoading.value = false;
  }



  // @override
  // void onInit() {
  //   super.onInit();
  //   assessmentController.fetchAssesmentId('Diagnosis',fetchAssesDiagnosis);

  // }
   bool showDetailsField(String onExamination) {
    return onExamination == 'Body temperature' ||
        onExamination == 'Muscle power average' ||
        onExamination == 'Facture at' ||
        onExamination == 'Dislocation of';
  }
  
  TextEditingController getDetailsController(String onExamination) {
    if (onExamination == 'Body temperature') {
      return bodyTemperatureController;
    } else if (onExamination == 'Muscle power average') {
      return musclePowerController;
    } else if (onExamination == 'Facture at') {
      return fractureAtController;
    } else if (onExamination == 'Dislocation of') {
      return dislocationOfController;
    }
    return TextEditingController();
  }
  //For Suggested Assestive Device
  List<String> get filtereddiagnosis {
    // Use the list fetched from API
    List<String> deviceNames = diagnosisList.map<String>((item) => item['name'] as String).toList();
    if (diagnosisText.isEmpty) {
      return deviceNames;
    }
    return deviceNames
        .where(
          (diagnosis) => diagnosis.toLowerCase().contains(
            diagnosisText.toLowerCase(),
          ),
        )
        .toList();
  }

  void togglediagnosisDropdown() {
    isDiagnosisDropdownOpen.toggle();
    if (!isDiagnosisDropdownOpen.value) {
      diagnosisText.value = '';
    }
  }
   void addDiagnosis(String diagnosis) {
    if (!selectedDiagnosis.contains(diagnosis)) {
      selectedDiagnosis.add(diagnosis);
      update();
           QuickTechSnackbar.success('Selected: $diagnosis');
    }
  }
  void removeDiagnosis(String diagnosis) {
    selectedDiagnosis.remove(diagnosis);
   
    update();
  }
    void addSubDiagnosis(String diagnosis, String addsubDiagnosis) {
    if (!selectedsubDiagnosis.containsKey(diagnosis)) {
      selectedsubDiagnosis[diagnosis] = [];
    }
    if (!selectedsubDiagnosis[diagnosis]!.contains(addsubDiagnosis)) {
      selectedsubDiagnosis[diagnosis]!.add(addsubDiagnosis);
      update();
           QuickTechSnackbar.success('Selected: $addsubDiagnosis');
    }
  }
   void removeSubDiagnosis(String diagnosis, String addsubDiagnosis) {
    selectedsubDiagnosis[diagnosis]?.remove(addsubDiagnosis);
    if (selectedsubDiagnosis[diagnosis]?.isEmpty ?? true) {
      selectedsubDiagnosis.remove(addsubDiagnosis);
    }
    update();
  }

  void clearDifferentialDiagnosis() {
    selectedDiagnosis.clear();
    selectedsubDiagnosis.clear();
    bodyTemperatureController.clear();
    musclePowerController.clear();
    fractureAtController.clear();
    dislocationOfController.clear();
    diagnosisText.value = '';
    isDiagnosisDropdownOpen.value = false;
    update();
  }

  bool hasData() => selectedDiagnosis.isNotEmpty;
}
