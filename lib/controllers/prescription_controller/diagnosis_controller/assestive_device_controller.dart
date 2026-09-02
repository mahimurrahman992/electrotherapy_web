import 'dart:convert';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/cheif_complain_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/diagnosis_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/disability_types_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/drug_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/on_examination_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/primary_medical_history_controller.dart';
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
final primarymedicalController = locator.get<PrimaryMedicalHistoryController>();
final drugHistoryController = locator.get<DrugHistoryController>();
final previousTherapyHistoryController = locator.get<PreviousTherapyHistoryController>();
final adviceController = locator.get<OptimizedAdviceController>();
final referredToController = locator.get<ReferredToController>();
final disabilityTypesController = locator.get<DisabilityTypesController>();
final diagnosisController = locator.get<DiagnosisController>();
class AssestiveDeviceController extends GetxController {
 Future<void> storeAssestiveDevice() async {
  final patientId = patientInfoController.patientId.value;
  final addType = 'prescription';
  final date = patientInfoController.date.value!.toIso8601String().substring(0, 10);

  try {
    isLoading.value = true;
    if (assestiveDeviceMap.isEmpty) {
      throw Exception('Assestive Device data not loaded');
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
for (final complaintName in selectedAssestiveDevice) {
  final subcategoryData = assestiveDeviceMap[complaintName];
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
  final subComplaints = selectedsubAssestiveDevice[complaintName] ?? [];
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
      print('✅ Bulk Assestive Device stored successfully: $responseData');
      QuickTechSnackbar.success('Assestive Device stored successfully!');
    } else {
      throw Exception('Failed to store Assestive Device: ${responseData['message'] ?? 'Unknown error'}');
    }

  } catch (e) {
    print('❌ Failed to store Assestive Device: $e');
    QuickTechSnackbar.error('Failed to store Assestive Device: $e');
  } finally {
    isLoading.value = false;
  }
}



  var filteredAssestiveDevice = <String>[].obs;
  // Category ID for custom entries
  var assestiveDeviceCategoryId = 0.obs;
  // Custom entries typed by user (not in DB)
  var customNewAssestiveDevice = <Map<String, dynamic>>[].obs;

  // Search assestive device - LOCAL FILTERING FIRST (immediate results)
  void searchAssestiveDevice(String searchText) {
    final query = searchText.trim().toLowerCase();
    if (query.isEmpty) {
      filteredAssestiveDevice.value = assestiveDeviceMap.keys.toList();
      return;
    }
    if (assestiveDeviceMap.isEmpty) {
      filteredAssestiveDevice.value = [];
      return;
    }
    // Filter from already-loaded local data (immediate results)
    filteredAssestiveDevice.value = assestiveDeviceMap.keys
        .where((item) => item.toLowerCase().contains(query))
        .toList();
  }
  final PreviousTherapyHistoryController previoustherapyController = locator.get<PreviousTherapyHistoryController>();
  final OptimizedAdviceController adviceController2 = locator.get<OptimizedAdviceController>();

  // For assestive device search
  TextEditingController assestiveDeviceSearchController = TextEditingController();
  var assestiveDeviceText = ''.obs;
  var isAssestiveDeviceDropdownOpen = false.obs;

  var assestiveDeviceMap = <String, Map<String, dynamic>>{}.obs;
  var isLoading = false.obs;
  var error = ''.obs;

  // Assestive device
  var selectedAssestiveDevice = <String>[].obs;
  var selectedsubAssestiveDevice = <String, List<String>>{}.obs;
  var otherSuggestiveDevice = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAssestiveDevices();
    // Listen to search text changes
    ever(assestiveDeviceText, (String value) {
      searchAssestiveDevice(value);
    });
  }

  Future<void> fetchAssestiveDevices() async {
    if (assestiveDeviceMap.isNotEmpty) return; // Already loaded
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.get(Uri.parse(Api.getDiagnosis));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final parsed = DiagnosisCategoryResponse.fromJson(data);
        final categories = parsed.diagnosisCategories ?? [];
        final assestiveCategory = categories.firstWhereOrNull(
          (cat) => cat.id == 9 || cat.name == 'Assestive Device',
        );
        if (assestiveCategory != null) {
          assestiveDeviceCategoryId.value = assestiveCategory.id ?? 0;
          final subcategories = assestiveCategory.diagnosisSubcategories ?? [];
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
          assestiveDeviceMap.value = tempMap;
          filteredAssestiveDevice.value = tempMap.keys.toList();
        } else {
          error.value = 'Assestive Device category not found';
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


  // Toggle assestive device dropdown
  void toggleAssestiveDeviceDropdown() {
    isAssestiveDeviceDropdownOpen.toggle();
    if (isAssestiveDeviceDropdownOpen.value) {
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
      //assistiveDeviceController.isAssestiveDeviceDropdownOpen.value = false;
      referredToController.isReferredDropdownOpen.value = false;
      disabilityTypesController.isDisabilityTypesDropdownOpen.value = false;
      diagnosisController.isDiagnosisDropdownOpen.value = false;
    }
    if (!isAssestiveDeviceDropdownOpen.value) {
      assestiveDeviceText.value = '';
    }
  }

  // Add assestive device
  void addAssestiveDevice(String device) {
    if (!selectedAssestiveDevice.contains(device)) {
      selectedAssestiveDevice.add(device);
      if (!assestiveDeviceMap.containsKey(device)) {
        customNewAssestiveDevice.add({
          'name': device,
          'diagnosis_category_id': assestiveDeviceCategoryId.value,
        });
      }
      selectedAssestiveDevice.refresh();
      update();
      QuickTechSnackbar.success('Selected: $device');
    }
  }

  // Remove assestive device
  void removeAssestiveDevice(String device) {
    selectedAssestiveDevice.remove(device);
    selectedsubAssestiveDevice.remove(device);
    customNewAssestiveDevice.removeWhere((e) => e['name'] == device);
    selectedAssestiveDevice.refresh();
    selectedsubAssestiveDevice.refresh();
    update();
  }

  // Add sub assestive device
  void addSubAssestiveDevice(String device, String subDevice) {
    if (!selectedsubAssestiveDevice.containsKey(device)) {
      selectedsubAssestiveDevice[device] = [];
    }
    if (!selectedsubAssestiveDevice[device]!.contains(subDevice)) {
      selectedsubAssestiveDevice[device]!.add(subDevice);
      selectedsubAssestiveDevice.refresh(); // Ensure UI updates
      update();
      QuickTechSnackbar.success('Selected: $subDevice');
    }
  }

  // Remove sub assestive device
  void removeSubAssestiveDevice(String device, String subDevice) {
    selectedsubAssestiveDevice[device]?.remove(subDevice);
    if (selectedsubAssestiveDevice[device]?.isEmpty ?? true) {
      selectedsubAssestiveDevice.remove(device);
    }
    selectedsubAssestiveDevice.refresh();
    update();
  }

  // Clear all assestive device selections
  void clearAll() {
    selectedAssestiveDevice.clear();
    selectedsubAssestiveDevice.clear();
    customNewAssestiveDevice.clear();
    update();
  }
}
