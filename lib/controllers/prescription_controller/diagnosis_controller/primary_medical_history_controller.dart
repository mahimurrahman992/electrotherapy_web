import 'dart:convert';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/assestive_device_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/cheif_complain_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/diagnosis_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/disability_types_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/drug_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/on_examination_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/radiological_findings_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/referred_to_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/patient_info_controller/patient_info_controller.dart';
import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:e_prescription/utils/api.dart';
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
final drugHistoryController = locator.get<DrugHistoryController>();
final previousTherapyHistoryController = locator.get<PreviousTherapyHistoryController>();
final adviceController = locator.get<OptimizedAdviceController>();
final assistiveDeviceController = locator.get<AssestiveDeviceController>();
final referredToController = locator.get<ReferredToController>();
final disabilityTypesController = locator.get<DisabilityTypesController>();
final diagnosisController = locator.get<DiagnosisController>();
class PrimaryMedicalHistoryController extends GetxController {
  Future<void> storePrimaryMedicalHistory() async {
  final patientId = patientInfoController.patientId.value;
  final addType = 'prescription';
  final date = patientInfoController.date.value!.toIso8601String().substring(0, 10);

  try {
    isLoadingMedicalHistory.value = true;
    if (medicalHistoryMap.isEmpty) {
      throw Exception('Medical History data not loaded');
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
for (final complaintName in selectedMedicalHistory) {
  final subcategoryData = medicalHistoryMap[complaintName];
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
  final subComplaints = selectedsubMedicalHistory[complaintName] ?? [];
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
      print('✅ Bulk Medical History stored successfully: $responseData');
      QuickTechSnackbar.success('Medical History stored successfully!');
    } else {
      throw Exception('Failed to storeMedical History: ${responseData['message'] ?? 'Unknown error'}');
    }

  } catch (e) {
    print('❌ Failed to store Medical History: $e');
    QuickTechSnackbar.error('Failed to store Medical History: $e');
  } finally {
    isLoadingMedicalHistory.value = false;
  }
}

  final PreviousTherapyHistoryController previoustherapyController = locator.get<PreviousTherapyHistoryController>();
  final OptimizedAdviceController adviceController2 = locator.get<OptimizedAdviceController>();

  // For medical history search
  TextEditingController medicalHistorySearchController = TextEditingController();
  var medicalhistorySearchText = ''.obs;
  var isMedicalHistoryDropdownOpen = false.obs;

  // Medical history 
  var selectedMedicalHistory = <String>[].obs;
  var selectedsubMedicalHistory = <String, List<String>>{}.obs;
  var otherMedicalHistory = ''.obs;


  var medicalHistoryMap =  <String, Map<String, dynamic>>{}.obs;
  var isLoadingMedicalHistory = false.obs;

  // Filtered medical history for search (local and remote)
  var filteredMedicalHistory = <String>[].obs;
  // Category ID for custom entries
  var medicalHistoryCategoryId = 0.obs;
  // Custom entries typed by user (not in DB)
  var customNewMedicalHistory = <Map<String, dynamic>>[].obs;

  // Search medical history - LOCAL FILTERING FIRST (immediate results)
  void searchMedicalHistory(String searchText) {
    final query = searchText.trim().toLowerCase();
    if (query.isEmpty) {
      filteredMedicalHistory.value = medicalHistoryMap.keys.toList();
      return;
    }
    if (medicalHistoryMap.isEmpty) {
      filteredMedicalHistory.value = [];
      return;
    }
    // Filter from already-loaded local data (immediate results)
    filteredMedicalHistory.value = medicalHistoryMap.keys
        .where((item) => item.toLowerCase().contains(query))
        .toList();
  }

  // Fetch medical history from API and show all by default
  Future<void> fetchMedicalHistory() async {
    if (medicalHistoryMap.isNotEmpty) return; // Already loaded
    isLoadingMedicalHistory.value = true;
    try {
      final response = await http.get(Uri.parse(Api.getDiagnosis));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final parsed = DiagnosisCategoryResponse.fromJson(data);
        final categories = parsed.diagnosisCategories ?? [];
        final medCategory = categories.firstWhereOrNull(
          (cat) => cat.name == 'Primary Medical History',
        );
        if (medCategory != null) {
          medicalHistoryCategoryId.value = medCategory.id ?? 0;
          final subcategories = medCategory.diagnosisSubcategories ?? [];
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
          medicalHistoryMap.value = tempMap;
          filteredMedicalHistory.value = tempMap.keys.toList();
        }
      }
    } catch (e) {
      QuickTechSnackbar.error('Failed to fetch medical history');
    } finally {
      isLoadingMedicalHistory.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchMedicalHistory();
    // Listen to search text changes
    ever(medicalhistorySearchText, (String value) {
      searchMedicalHistory(value);
    });
  }

  // Toggle medical history dropdown
  void toggleMedicalHistoryDropdown() {
   isMedicalHistoryDropdownOpen.toggle();
    if (isMedicalHistoryDropdownOpen.value) {
      cheifComplainController.isComplaintDropdownOpen.value = false;
      onExaminationController.isDropdownOpen.value = false;
      radiologicalFindingsController.isRadiologicalFindingsDropdownOpen.value =
          false;
      //primarymedicalController.isMedicalHistoryDropdownOpen.value = false;
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
    if (!isMedicalHistoryDropdownOpen.value) {
      medicalhistorySearchText.value = '';
    }
  }

  // Add medical history
  void addMedicalHistory(String history) {
    if (!selectedMedicalHistory.contains(history)) {
      selectedMedicalHistory.add(history);
      if (!medicalHistoryMap.containsKey(history)) {
        customNewMedicalHistory.add({
          'name': history,
          'diagnosis_category_id': medicalHistoryCategoryId.value,
        });
      }
      selectedMedicalHistory.refresh();
      update();
      QuickTechSnackbar.success('Selected: $history');
    }
  }

  // Remove medical history
  void removeMedicalHistory(String history) {
    selectedMedicalHistory.remove(history);
    selectedsubMedicalHistory.remove(history);
    customNewMedicalHistory.removeWhere((e) => e['name'] == history);
    selectedMedicalHistory.refresh();
    update();
  }

  // Add sub medical history
  void addSubMedicalHistory(String history, String subHistory) {
    if (!selectedsubMedicalHistory.containsKey(history)) {
      selectedsubMedicalHistory[history] = [];
    }
    if (!selectedsubMedicalHistory[history]!.contains(subHistory)) {
      selectedsubMedicalHistory[history]!.add(subHistory);
      selectedsubMedicalHistory.refresh();
      update();
      QuickTechSnackbar.success('Selected: $subHistory');
    }
  }

  // Remove sub medical history
  void removeSubMedicalHistory(String history, String subHistory) {
    selectedsubMedicalHistory[history]?.remove(subHistory);
    if (selectedsubMedicalHistory[history]?.isEmpty ?? true) {
      selectedsubMedicalHistory.remove(history);
    }
    selectedMedicalHistory.refresh();
    update();
  }

  // Clear all medical history selections
  void clearAll() {
    selectedMedicalHistory.clear();
    selectedsubMedicalHistory.clear();
    customNewMedicalHistory.clear();
    update();
  }
}
