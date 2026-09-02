
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/assestive_device_controller.dart';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/cheif_complain_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/diagnosis_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/disability_types_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/drug_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/optimized_advice_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/previous_therapy_Controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/primary_medical_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/radiological_findings_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/referred_to_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/patient_info_controller/patient_info_controller.dart';

import 'package:e_prescription/utils/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/models/prescription/diagnosis_category_response.dart';
final PatientInfoController patientInfoController = locator.get<PatientInfoController>();
final cheifComplainController = locator.get<CheifComplainController>();
final radiologicalFindingsController = locator.get<RadiologicalFindingsController>();
final primarymedicalController = locator.get<PrimaryMedicalHistoryController>();
final drugHistoryController = locator.get<DrugHistoryController>();
final previousTherapyHistoryController = locator.get<PreviousTherapyHistoryController>();
final adviceController = locator.get<OptimizedAdviceController>();
final assistiveDeviceController = locator.get<AssestiveDeviceController>();
final referredToController = locator.get<ReferredToController>();
final disabilityTypesController = locator.get<DisabilityTypesController>();
final diagnosisController = locator.get<DiagnosisController>();



class OnExaminationController extends GetxController {
  

  TextEditingController searchController = TextEditingController();
  
  // Search text
  var searchText = ''.obs;
  
  // Dropdown state
  var isDropdownOpen = false.obs;
  
  // Selected items
  var selectedExaminations = <String>[].obs;
  var selectedSubExaminations = <String, List<String>>{}.obs;
  
 
  // Store a single value for dynamic 'With Value' examinations
  var examinationValues = <String, RxString>{}.obs;

  // Dynamic On Examinations 

var onExaminationMap = <String, Map<String, dynamic>>{}.obs;
  var isLoadingOnExaminations = false.obs;

  // Filtered examinations for search (local and remote)
  var filteredExaminations = <String>[].obs;
  // Category ID for custom entries
  var onExaminationCategoryId = 0.obs;
  // Custom entries typed by user (not in DB)
  var customNewExaminations = <Map<String, dynamic>>[].obs;

 void searchOnExaminations(String searchText) {
  final query = searchText.trim().toLowerCase();
  if (query.isEmpty) {
    filteredExaminations.value = onExaminationMap.keys.toList();
    return;
  }
  if (onExaminationMap.isEmpty) {
    filteredExaminations.value = [];
    return;
  }
  // Filter from already-loaded local data (immediate results)
  filteredExaminations.value = onExaminationMap.keys
      .where((item) => item.toLowerCase().contains(query))
      .toList();
}

  Future<void> fetchOnExaminations() async {
    if (onExaminationMap.isNotEmpty) return; // Already loaded
    isLoadingOnExaminations.value = true;
    try {
      final response = await http.get(Uri.parse(Api.getDiagnosis));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final parsed = DiagnosisCategoryResponse.fromJson(data);
        final categories = parsed.diagnosisCategories ?? [];
        final onExamCategory = categories.firstWhereOrNull(
          (cat) => cat.name == 'On Examinations',
        );
        if (onExamCategory != null) {
          onExaminationCategoryId.value = onExamCategory.id ?? 0;
          final subcategories = onExamCategory.diagnosisSubcategories ?? [];
          final Map<String, Map<String, dynamic>> tempMap = {};
          for (var sub in subcategories) {
            final subName = sub.name ?? '';
            if (subName.isEmpty) continue;
            final subId = sub.id;
            final subType = sub.type ?? '';
            final childList = sub.diagnosisChildcategories ?? [];
            final List<Map<String, dynamic>> childData = childList.map((c) => {
              'id': c.id,
              'name': c.name,
            }).toList();
            tempMap[subName] = {
              'id': subId,
              'type': subType,
              'children': childData,
            };
          }
          onExaminationMap.value = tempMap;
          filteredExaminations.value = tempMap.keys.toList();
        }
      }
    } catch (e) {
      QuickTechSnackbar.error('Failed to fetch On Examinations');
    } finally {
      isLoadingOnExaminations.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchOnExaminations();
    // Listen to search text changes
    ever(searchText, (String value) {
      searchOnExaminations(value);
    });
  }


  // Dynamically show text field for any examination with type 'With Value'
  bool showDetailsField(String examination) {
    final data = onExaminationMap[examination];
    if (data != null && data['type'] == 'With Value') {
      return true;
    }
    return false;
  }

  // Get or create the RxString controller for a dynamic examination
  RxString getDetailsController(String examination) {
    if (!examinationValues.containsKey(examination)) {
      examinationValues[examination] = ''.obs;
    }
    return examinationValues[examination]!;
  }

  // Toggle dropdown visibility
  void toggleDropdown() {
   isDropdownOpen.toggle();
    if (isDropdownOpen.value) {
      cheifComplainController.isComplaintDropdownOpen.value = false;
      //onExaminationController.isDropdownOpen.value = false;
      radiologicalFindingsController.isRadiologicalFindingsDropdownOpen.value =
          false;
      primarymedicalController.isMedicalHistoryDropdownOpen.value = false;
      drugHistoryController.isDrugHistoryDropdownOpen.value = false;

      previousTherapyHistoryController.showMainDropdown.value = false;
      previousTherapyHistoryController.showDropdowns.updateAll(
        (key, value) => false,
      );

      adviceController.showMainDropdown.value = false;
      adviceController.showDropdowns.updateAll((key, value) => false);
      assistiveDeviceController.isAssestiveDeviceDropdownOpen.value = false;
      referredToController.isReferredDropdownOpen.value = false;
      disabilityTypesController.isDisabilityTypesDropdownOpen.value = false;
      diagnosisController.isDiagnosisDropdownOpen.value = false;
    }
    if (!isDropdownOpen.value) {
      searchText.value = '';
    }
  }

  // Add examination
  void addExamination(String examination) {
    if (!selectedExaminations.contains(examination)) {
      selectedExaminations.add(examination);
      if (!onExaminationMap.containsKey(examination)) {
        customNewExaminations.add({
          'name': examination,
          'diagnosis_category_id': onExaminationCategoryId.value,
        });
      }
      update();
      QuickTechSnackbar.success('Selected: $examination');
    }
  }

  // Remove examination
  void removeExamination(String examination) {
    selectedExaminations.remove(examination);
    selectedSubExaminations.remove(examination);
    customNewExaminations.removeWhere((e) => e['name'] == examination);
    selectedSubExaminations.refresh();
    update();
  }

  // Add sub-examination
  void addSubExamination(String examination, String subExamination) {
    if (!selectedSubExaminations.containsKey(examination)) {
      selectedSubExaminations[examination] = [];
    }
    if (!selectedSubExaminations[examination]!.contains(subExamination)) {
      selectedSubExaminations[examination]!.add(subExamination);
      selectedSubExaminations.refresh();
      update();
      QuickTechSnackbar.success('Selected: $subExamination');
    }
  }

  // Remove sub-examination
  void removeSubExamination(String examination, String subExamination) {
    selectedSubExaminations[examination]?.remove(subExamination);
    if (selectedSubExaminations[examination]?.isEmpty ?? true) {
      selectedSubExaminations.remove(examination);
    }
    selectedSubExaminations.refresh();
    update();
  }

  // Clear all selections
  void clearAll() {
    selectedExaminations.clear();
    selectedSubExaminations.clear();
    examinationValues.clear();
    customNewExaminations.clear();
    searchText.value = '';
    searchController.clear();
    update();
  }

  // Get all examinations as formatted string
  String getFormattedExaminations() {
    String mainExaminations = selectedExaminations.join(', ');
    
    String subExaminations = '';
    selectedSubExaminations.forEach((examination, subItems) {
      if (subItems.isNotEmpty) {
        subExaminations += '\n$examination: ${subItems.join(', ')}';
      }
    });
    
    return mainExaminations + subExaminations;
  }
}