import 'dart:convert';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/assestive_device_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/cheif_complain_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/diagnosis_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/disability_types_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/drug_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/on_examination_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/primary_medical_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/radiological_findings_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/patient_info_controller/patient_info_controller.dart';
import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:http/http.dart' as http;
// import 'package:e_prescription/const/quick_tech_static_data.dart';
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
final drugHistoryController = locator.get<DrugHistoryController>();
final previousTherapyHistoryController = locator.get<PreviousTherapyHistoryController>();
final adviceController = locator.get<OptimizedAdviceController>();
final assistiveDeviceController = locator.get<AssestiveDeviceController>();
final disabilityTypesController = locator.get<DisabilityTypesController>();
final diagnosisController = locator.get<DiagnosisController>();
class ReferredToController extends GetxController {
  Future<void> storeRefferedTo() async {
  final patientId = patientInfoController.patientId.value;
  final addType = 'prescription';
  final date = patientInfoController.date.value!.toIso8601String().substring(0, 10);

  try {
    isLoading.value = true;
    if (referredToMap.isEmpty) {
      throw Exception('Referred To data not loaded');
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
for (final complaintName in selectedReferredTo) {
  final subcategoryData = referredToMap[complaintName];
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
  final subComplaints = selectedsubReferredTo[complaintName] ?? [];
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
      print('✅ Bulk Referred To stored successfully: $responseData');
      QuickTechSnackbar.success('Referred To stored successfully!');
    } else {
      throw Exception('Failed to store Referred To: ${responseData['message'] ?? 'Unknown error'}');
    }

  } catch (e) {
    print('❌ Failed to store Referred To: $e');
    QuickTechSnackbar.error('Failed to store Referred To: $e');
  } finally {
    isLoading.value = false;
  }
}




  var referredToMap = <String, Map<String, dynamic>>{}.obs;
  // Map of referred to -> selected sub-referred
  var selectedsubReferredTo = <String, List<String>>{}.obs;
 

  // For referred to search
  TextEditingController referredToSearchController = TextEditingController();
  var referredToText = ''.obs;
  var isReferredDropdownOpen = false.obs;

  // API-driven data
  var referredToList = <String>[].obs;
  var filteredReferredTo = <String>[].obs;
  // Category ID for custom entries
  var referredToCategoryId = 0.obs;
  // Custom entries typed by user (not in DB)
  var customNewReferredTo = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  // Referred to
  var selectedReferredTo = <String>[].obs;
  var otherreferredTo = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReferredTo();
    // Listen to search text changes
    ever(referredToText, (String value) {
      searchReferredTo(value);
    });
  }

  Future<void> fetchReferredTo() async {
    if (referredToMap.isNotEmpty) return; // Already loaded
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.get(Uri.parse(Api.getDiagnosis));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final parsed = DiagnosisCategoryResponse.fromJson(data);
        final categories = parsed.diagnosisCategories ?? [];
        final referredCategory = categories.firstWhereOrNull(
          (cat) => cat.id == 10 || cat.name == 'Referred To',
        );
        if (referredCategory != null) {
          referredToCategoryId.value = referredCategory.id ?? 0;
          final subcategories = referredCategory.diagnosisSubcategories ?? [];
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
          referredToMap.value = tempMap;
          filteredReferredTo.value = tempMap.keys.toList();
        } else {
          error.value = 'Referred To category not found';
        }
      } else {
        error.value = 'Failed to load data';
      }
    } catch (e) {
      error.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Search referred to - LOCAL FILTERING FIRST (immediate results)
  void searchReferredTo(String searchText) {
    final query = searchText.trim().toLowerCase();
    if (query.isEmpty) {
      filteredReferredTo.value = referredToMap.keys.toList();
      return;
    }
    if (referredToMap.isEmpty) {
      filteredReferredTo.value = [];
      return;
    }
    // Filter from already-loaded local data (immediate results)
    filteredReferredTo.value = referredToMap.keys
        .where((item) => item.toLowerCase().contains(query))
        .toList();
  }

  // (getter removed, now using observable filteredReferredTo)

  // Toggle referred to dropdown
  void toggleReferredToDropdown() {
    isReferredDropdownOpen.toggle();
    if (isReferredDropdownOpen.value) {
      cheifComplainController.isComplaintDropdownOpen.value = false;
      onExaminationController.isDropdownOpen.value = false;
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
      //referredToController.isReferredDropdownOpen.value = false;
      disabilityTypesController.isDisabilityTypesDropdownOpen.value = false;
      diagnosisController.isDiagnosisDropdownOpen.value = false;
    }
    if (!isReferredDropdownOpen.value) {
      referredToText.value = '';
    }
  }

  // Add referred to
  void addReferredTo(String referred) {
    if (!selectedReferredTo.contains(referred)) {
      selectedReferredTo.add(referred);
      // Initialize selected sub-referred for this referred if not present
      if (!selectedsubReferredTo.containsKey(referred)) {
        selectedsubReferredTo[referred] = <String>[];
      }
      if (!referredToMap.containsKey(referred)) {
        customNewReferredTo.add({
          'name': referred,
          'diagnosis_category_id': referredToCategoryId.value,
        });
      }
      update();
      QuickTechSnackbar.success('Selected: $referred');
    }
  }

  // Remove referred to
  void removeReferredTo(String referred) {
    selectedReferredTo.remove(referred);
    selectedsubReferredTo.remove(referred);
    customNewReferredTo.removeWhere((e) => e['name'] == referred);
    update();
  }

  // Add sub-referred to a referred
  void addSubReferredTo(String referred, String subReferred) {
    if (!selectedsubReferredTo.containsKey(referred)) {
      selectedsubReferredTo[referred] = <String>[];
    }
    if (!selectedsubReferredTo[referred]!.contains(subReferred)) {
      selectedsubReferredTo[referred]!.add(subReferred);
      selectedsubReferredTo.refresh();
    }
  }

  // Remove sub-referred from a referred
  void removeSubReferredTo(String referred, String subReferred) {
    if (selectedsubReferredTo.containsKey(referred)) {
      selectedsubReferredTo[referred]!.remove(subReferred);
      selectedsubReferredTo.refresh();
    }
  }

  // Clear all referred to selections
  void clearAll() {
    selectedReferredTo.clear();
    selectedsubReferredTo.clear();
    customNewReferredTo.clear();
    update();
  }
  }
