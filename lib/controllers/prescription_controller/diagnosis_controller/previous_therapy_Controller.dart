import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/assestive_device_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/cheif_complain_controller.dart';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/diagnosis_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/disability_types_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/drug_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/on_examination_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/optimized_advice_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/primary_medical_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/radiological_findings_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/referred_to_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/patient_info_controller/patient_info_controller.dart';

import 'package:e_prescription/utils/api.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/models/prescription/diagnosis_category_response.dart';
final PatientInfoController patientInfoController = locator.get<PatientInfoController>();
final cheifComplainController = locator.get<CheifComplainController>();
final onExaminationController = locator.get<OnExaminationController>();
final radiologicalFindingsController = locator.get<RadiologicalFindingsController>();
final primarymedicalController = locator.get<PrimaryMedicalHistoryController>();
final drugHistoryController = locator.get<DrugHistoryController>();
final adviceController = locator.get<OptimizedAdviceController>();
final assistiveDeviceController = locator.get<AssestiveDeviceController>();
final referredToController = locator.get<ReferredToController>();
final disabilityTypesController = locator.get<DisabilityTypesController>();
final diagnosisController = locator.get<DiagnosisController>();
class PreviousTherapyHistoryController extends GetxController {



  var showMainDropdown = false.obs;
  void toggleMainDropdown() => showMainDropdown.toggle();
  
  // Separate controllers for each therapy option
  final Map<String, TextEditingController> durationControllers = {};
  final Map<String, TextEditingController> frequencyControllers = {};
  
  var showDropdowns = <String, bool>{
    'main': false,
    'electrotherapy': false,
    'manual': false,
    'additional': false,
  }.obs;
  var others = ''.obs;
  var othersDetails = ''.obs;
  int? previousTherapyCategoryId;

  var electrotherapyOptions = <Map<String, dynamic>>[].obs;
var manualTherapyOptions = <Map<String, dynamic>>[].obs;
var additionalTherapyOptions = <Map<String, dynamic>>[].obs;

  var isLoadingTherapyOptions = false.obs;

  // Fetch Previous Therapy History 
  Future<void> fetchTherapyOptions() async {
    isLoadingTherapyOptions.value = true;
    try {
      final response = await http.get(Uri.parse(Api.getDiagnosis));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final parsed = DiagnosisCategoryResponse.fromJson(data);
        final categories = parsed.diagnosisCategories ?? [];
        final prevTherapyCategory = categories.firstWhereOrNull(
          (cat) => cat.name == 'Previous Therapy History',
        );
        if (prevTherapyCategory != null) {
          previousTherapyCategoryId = prevTherapyCategory.id;
          final subcategories = prevTherapyCategory.diagnosisSubcategories ?? [];
          for (var sub in subcategories) {
            final subName = sub.name ?? '';
            if (subName.isEmpty) continue;
            final subId = sub.id ?? 0;
            final childList = sub.diagnosisChildcategories ?? [];
            final List<Map<String, dynamic>> childOptions = childList.map((c) {
              return {
                'id': c.id,
                'name': c.name,
                'subcategory_id': subId,
                'category_id': prevTherapyCategory.id,
              };
            }).toList();
            if (subName == 'Electrotherapy') {
              electrotherapyOptions.value = childOptions;
            } else if (subName == 'Manual Therapy') {
              manualTherapyOptions.value = childOptions;
            } else if (subName == 'Other Therapies') {
              additionalTherapyOptions.value = childOptions;
            }
          }
        }
      }
    } catch (e) {
      QuickTechSnackbar.error('Failed to fetch therapy options');
    } finally {
      isLoadingTherapyOptions.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchTherapyOptions();
  }

var selectedElectrotherapy = <Map<String, dynamic>>[].obs;
var selectedManualTherapy = <Map<String, dynamic>>[].obs;
var selectedAdditionalTherapies = <Map<String, dynamic>>[].obs;

  var therapyDetails = <String, Map<String, dynamic>>{}.obs;

  void toggleDropdown(String key) {
    // If opening previous therapy main dropdown, close all other dropdowns
    if (key == 'main' && !(showDropdowns['main'] ?? false)) {
      cheifComplainController.isComplaintDropdownOpen.value = false;
      onExaminationController.isDropdownOpen.value = false;
      radiologicalFindingsController.isRadiologicalFindingsDropdownOpen.value = false;
      primarymedicalController.isMedicalHistoryDropdownOpen.value = false;
      drugHistoryController.isDrugHistoryDropdownOpen.value = false;
      adviceController.showMainDropdown.value = false;
      adviceController.showDropdowns.updateAll((k, v) => false);
      assistiveDeviceController.isAssestiveDeviceDropdownOpen.value = false;
      referredToController.isReferredDropdownOpen.value = false;
      disabilityTypesController.isDisabilityTypesDropdownOpen.value = false;
      diagnosisController.isDiagnosisDropdownOpen.value = false;
    }
    showDropdowns[key] = !(showDropdowns[key] ?? false);
    update();
  }

  void updateOthers(String value) {
    others.value = value;
    othersDetails.value = value;
    update();
  }

  void clearOthers() {
    others.value = '';
    othersDetails.value = '';
    update();
  }

void toggleElectrotherapyOption(Map<String, dynamic> option) {
  final therapyId = option['id'].toString();
  if (selectedElectrotherapy.any((e) => e['id'] == option['id'])) {
    selectedElectrotherapy.removeWhere((e) => e['id'] == option['id']);
    therapyDetails.remove(therapyId);
    // Dispose controllers
    durationControllers[therapyId]?.dispose();
    frequencyControllers[therapyId]?.dispose();
    durationControllers.remove(therapyId);
    frequencyControllers.remove(therapyId);
    QuickTechSnackbar.error('${option['name']} unselected', title: 'Electrotherapy Option');
  } else {
    selectedElectrotherapy.add(option);
    therapyDetails[therapyId] = {
      'duration': '',
      'frequency': '',
      'isRegular': null,
    };
    // Create separate controllers for this therapy
    durationControllers[therapyId] = TextEditingController();
    frequencyControllers[therapyId] = TextEditingController();
    QuickTechSnackbar.success('${option['name']} selected', title: 'Electrotherapy Option');
  }
}
void toggleManualTherapyOption(Map<String, dynamic> option) {
  final therapyId = option['id'].toString();
  if (selectedManualTherapy.any((e) => e['id'] == option['id'])) {
    selectedManualTherapy.removeWhere((e) => e['id'] == option['id']);
    therapyDetails.remove(therapyId);
    // Dispose controllers
    durationControllers[therapyId]?.dispose();
    frequencyControllers[therapyId]?.dispose();
    durationControllers.remove(therapyId);
    frequencyControllers.remove(therapyId);
    QuickTechSnackbar.error('${option['name']} unselected', title: 'Manual Therapy Option');
  } else {
    selectedManualTherapy.add(option);
    therapyDetails[therapyId] = {
      'duration': '',
      'frequency': '',
      'isRegular': null,
    };
    // Create separate controllers for this therapy
    durationControllers[therapyId] = TextEditingController();
    frequencyControllers[therapyId] = TextEditingController();
    QuickTechSnackbar.success('${option['name']} selected', title: 'Manual Therapy Option');
  }
}



void toggleAdditionalTherapyOption(Map<String, dynamic> option) {
  final therapyId = option['id'].toString();
  if (selectedAdditionalTherapies.any((e) => e['id'] == option['id'])) {
    selectedAdditionalTherapies.removeWhere((e) => e['id'] == option['id']);
    therapyDetails.remove(therapyId);
    // Dispose controllers
    durationControllers[therapyId]?.dispose();
    frequencyControllers[therapyId]?.dispose();
    durationControllers.remove(therapyId);
    frequencyControllers.remove(therapyId);
    QuickTechSnackbar.error('${option['name']} unselected', title: 'Additional Therapy Option');
  } else {
    selectedAdditionalTherapies.add(option);
    therapyDetails[therapyId] = {
      'duration': '',
      'frequency': '',
      'isRegular': null,
    };
    // Create separate controllers for this therapy
    durationControllers[therapyId] = TextEditingController();
    frequencyControllers[therapyId] = TextEditingController();
    QuickTechSnackbar.success('${option['name']} selected', title: 'Additional Therapy Option');
  }
}
 
  void updateTherapyDetails({
    required String therapy,
    String? duration,
    String? frequency,
    bool? isRegular,
  }) {
    therapyDetails[therapy] = {
      'duration': duration ?? therapyDetails[therapy]?['duration'] ?? '',
      'frequency': frequency ?? therapyDetails[therapy]?['frequency'] ?? '',
      'isRegular': isRegular ?? therapyDetails[therapy]?['isRegular'],
    };
    update();
  }
  
  @override
  void onClose() {
    // Dispose all controllers
    for (var controller in durationControllers.values) {
      controller.dispose();
    }
    for (var controller in frequencyControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  Map<String, dynamic> getFormData() {
    return {
      'electrotherapy': selectedElectrotherapy.map((e) => {'type': e, 'details': therapyDetails[e]}).toList(),
      'manualTherapy': selectedManualTherapy.toList(),
      'additionalTherapies': selectedAdditionalTherapies.toList(),
      'others': others.value,
    };
  }
}
