import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/assestive_device_controller.dart';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/cheif_complain_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/diagnosis_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/disability_types_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/on_examination_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/primary_medical_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/radiological_findings_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/referred_to_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/patient_info_controller/patient_info_controller.dart';
import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:e_prescription/utils/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/optimized_advice_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/previous_therapy_Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/models/prescription/diagnosis_category_response.dart';
final PatientInfoController patientInfoController = locator.get<PatientInfoController>();
final cheifComplainController = locator.get<CheifComplainController>();
final onExaminationController = locator.get<OnExaminationController>();
final radiologicalFindingsController = locator.get<RadiologicalFindingsController>();
final primarymedicalController = locator.get<PrimaryMedicalHistoryController>();
final previousTherapyHistoryController = locator.get<PreviousTherapyHistoryController>();
final adviceController = locator.get<OptimizedAdviceController>();
final assistiveDeviceController = locator.get<AssestiveDeviceController>();
final referredToController = locator.get<ReferredToController>();
final disabilityTypesController = locator.get<DisabilityTypesController>();
final diagnosisController = locator.get<DiagnosisController>();
class DrugHistoryController extends GetxController {


    Future<void> storeDrugHistory() async {
  final patientId = patientInfoController.patientId.value;
  final addType = 'prescription';
  final date = patientInfoController.date.value!.toIso8601String().substring(0, 10);

  try {
    isLoadingDrugHistory.value = true;
    if (drugHistoryMap.isEmpty) {
      throw Exception('Drug History data not loaded');
    }

    // Get token
    final token = await QuickTechAuthStorageService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final url = Uri.parse('${Api.baseUrl}/api/prescription/diagnosis/store');

    // Prepare the request data
    final Map<String, dynamic> requestData = {
      'patient_id': patientId.toString(),
      'add_type': addType,
      'date': date,
    };

// Prepare arrays for bulk data
List<String> diagSubcatIds = [];
List<String> diagChildcatIds = [];
List<String> allIds = [];
List<String> subcategoryValues = [];
List<String> durations = [];
List<String> frequencies = [];
List<String> leftRights = [];

// Process selected complaints
for (final complaintName in selectedDrugHistory) {
  final subcategoryData = drugHistoryMap[complaintName];
  if (subcategoryData == null) {
    print('❌ Subcategory not found for complaint: $complaintName');
    continue;
  }

  // Subcategory
  final subcatId = subcategoryData['id'].toString();
  diagSubcatIds.add(subcatId);
  allIds.add(subcatId);
  subcategoryValues.add('');
  durations.add('');
  frequencies.add('');
  leftRights.add('');

  // Childcategories
  final subComplaints = selectedsubDrugHistory[complaintName] ?? [];
  for (final childName in subComplaints) {
    final childData = (subcategoryData['children'] as List<dynamic>).firstWhere(
      (c) => c['name'] == childName,
      orElse: () => <String, dynamic>{},
    );
    if (childData.isNotEmpty) {
      final childId = childData['id'].toString();
      diagChildcatIds.add(childId);
      allIds.add(childId);
      subcategoryValues.add('');
      durations.add('');
      frequencies.add('');
      leftRights.add('');
    }
    if (childData != null) {
      final childId = childData['id'].toString();
      diagChildcatIds.add(childId);
      allIds.add(childId);
      subcategoryValues.add('');
      durations.add('');
      frequencies.add('');
      leftRights.add('');
    }
  }
}

requestData['diagSubcatIds'] = diagSubcatIds;
requestData['diagChildcatIds'] = diagChildcatIds;
requestData['subcategory_value'] = subcategoryValues;
requestData['duration'] = durations;
requestData['frequency'] = frequencies;
requestData['left_right'] = leftRights;

    print('📦 Sending request data: ${json.encode(requestData)}');

    // Send the request
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(requestData),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Bulk Drug History stored successfully: $responseData');
      QuickTechSnackbar.success('Drug History stored successfully!');
    } else {
      throw Exception('Failed to store Drug History: ${responseData['message'] ?? 'Unknown error'}');
    }

  } catch (e) {
    print('❌ Failed to store Drug History: $e');
    QuickTechSnackbar.error('Failed to store Drug History: $e');
  } finally {
    isLoadingDrugHistory.value = false;
  }
}


  TextEditingController drugHistorySearchController = TextEditingController();
  var drughistorySearchText = ''.obs;
  var isDrugHistoryDropdownOpen = false.obs;

  // Drug history 
  var selectedDrugHistory = <String>[].obs;
  var selectedsubDrugHistory = <String, List<String>>{}.obs;
  var otherDrugHistory = ''.obs;


  var drugHistoryMap =  <String, Map<String, dynamic>>{}.obs;
  var isLoadingDrugHistory = false.obs;

  // Filtered drug history for search (local and remote)
  var filteredDrugHistory = <String>[].obs;
  // Category ID for custom entries
  var drugHistoryCategoryId = 0.obs;
  // Custom entries typed by user (not in DB)
  var customNewDrugHistory = <Map<String, dynamic>>[].obs;

  // Search drug history - LOCAL FILTERING FIRST (immediate results)
  void searchDrugHistory(String searchText) {
    final query = searchText.trim().toLowerCase();
    if (query.isEmpty) {
      filteredDrugHistory.value = drugHistoryMap.keys.toList();
      return;
    }
    if (drugHistoryMap.isEmpty) {
      filteredDrugHistory.value = [];
      return;
    }
    // Filter from already-loaded local data (immediate results)
    filteredDrugHistory.value = drugHistoryMap.keys
        .where((item) => item.toLowerCase().contains(query))
        .toList();
  }

  // Fetch drug history and show all by default
  Future<void> fetchDrugHistory() async {
    if (drugHistoryMap.isNotEmpty) return; // Already loaded
    isLoadingDrugHistory.value = true;
    try {
      final response = await http.get(Uri.parse(Api.getDiagnosis));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final parsed = DiagnosisCategoryResponse.fromJson(data);
        final categories = parsed.diagnosisCategories ?? [];
        final drugCategory = categories.firstWhereOrNull(
          (cat) => cat.name == 'Drug History',
        );
        if (drugCategory != null) {
          drugHistoryCategoryId.value = drugCategory.id ?? 0;
          final subcategories = drugCategory.diagnosisSubcategories ?? [];
          final Map<String, Map<String, dynamic>> tempMap = {};
          for (var sub in subcategories) {
            final subName = sub.name ?? '';
            if (subName.isEmpty) continue;
            final subId = sub.id;
            final childList = sub.diagnosisChildcategories ?? [];
            final List<Map<String, dynamic>> childData = childList.map((c) => {
              'id': c.id,
              'name': c.name,
            }).toList();
            tempMap[subName] = {
              'id': subId,
              'children': childData,
            };
          }
          drugHistoryMap.value = tempMap;
          filteredDrugHistory.value = tempMap.keys.toList();
        }
      }
    } catch (e) {
      QuickTechSnackbar.error('Failed to fetch drug history');
    } finally {
      isLoadingDrugHistory.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchDrugHistory();
    // Listen to search text changes
    ever(drughistorySearchText, (String value) {
      searchDrugHistory(value);
    });
  }

  // Toggle drug history dropdown
  void toggleDrugHistoryDropdown() {
  isDrugHistoryDropdownOpen.toggle();
    if (isDrugHistoryDropdownOpen.value) {
      cheifComplainController.isComplaintDropdownOpen.value = false;
      onExaminationController.isDropdownOpen.value = false;
      radiologicalFindingsController.isRadiologicalFindingsDropdownOpen.value =
          false;
      primarymedicalController.isMedicalHistoryDropdownOpen.value = false;
     // drugHistoryController.isDrugHistoryDropdownOpen.value = false;

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
    if (!isDrugHistoryDropdownOpen.value) {
      drughistorySearchText.value = '';
    }
  }

  // Add drug history
  void addDrugHistory(String history) {
    if (!selectedDrugHistory.contains(history)) {
      selectedDrugHistory.add(history);
      if (!drugHistoryMap.containsKey(history)) {
        customNewDrugHistory.add({
          'name': history,
          'diagnosis_category_id': drugHistoryCategoryId.value,
        });
      }
      selectedDrugHistory.refresh();
      update();
      QuickTechSnackbar.success('Selected: $history');
    }
  }

  // Remove drug history
  void removeDrugHistory(String history) {
    selectedDrugHistory.remove(history);
    selectedsubDrugHistory.remove(history);
    customNewDrugHistory.removeWhere((e) => e['name'] == history);
    selectedDrugHistory.refresh();
    selectedsubDrugHistory.refresh();
    update();
  }

  // Add sub drug history
  void addSubDrugHistory(String history, String subHistory) {
    if (!selectedsubDrugHistory.containsKey(history)) {
      selectedsubDrugHistory[history] = [];
    }
    if (!selectedsubDrugHistory[history]!.contains(subHistory)) {
      selectedsubDrugHistory[history]!.add(subHistory);
      selectedsubDrugHistory.refresh();
      update();
      QuickTechSnackbar.success('Selected: $subHistory');
    }
  }

  // Remove sub drug history
  void removeSubDrugHistory(String history, String subHistory) {
    selectedsubDrugHistory[history]?.remove(subHistory);
    if (selectedsubDrugHistory[history]?.isEmpty ?? true) {
      selectedsubDrugHistory.remove(history);
    }
    selectedsubDrugHistory.refresh();
    update();
  }

  // Clear all drug history selections
  void clearAll() {
    selectedDrugHistory.clear();
    selectedsubDrugHistory.clear();
    customNewDrugHistory.clear();
    update();
  }
}
