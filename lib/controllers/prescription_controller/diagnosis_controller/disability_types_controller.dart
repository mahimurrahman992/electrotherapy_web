import 'dart:convert';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/assestive_device_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/cheif_complain_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/diagnosis_controller.dart';
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
final assistiveDeviceController = locator.get<AssestiveDeviceController>();
final referredToController = locator.get<ReferredToController>();
final disabilityTypesController = locator.get<DisabilityTypesController>();
final diagnosisController = locator.get<DiagnosisController>();
class DisabilityTypesController extends GetxController {

 Future<void> storeDisabilityTypes() async {
  final patientId = patientInfoController.patientId.value;
  final addType = 'prescription';
  final date = patientInfoController.date.value!.toIso8601String().substring(0, 10);

  try {
    isLoading.value = true;
    if (disabilityTypesMap.isEmpty) {
      throw Exception('Disability Types data not loaded');
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
for (final complaintName in selecteddisabilityTypes) {
  final subcategoryData = disabilityTypesMap[complaintName];
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
  final subComplaints = selectedSubDisabilityTypes[complaintName] ?? [];
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
      print('✅ Bulk Disability Types stored successfully: $responseData');
      QuickTechSnackbar.success('Disability Types stored successfully!');
    } else {
      throw Exception('Failed to store Disability Types: ${responseData['message'] ?? 'Unknown error'}');
    }

  } catch (e) {
    print('❌ Failed to store Disability Types: $e');
    QuickTechSnackbar.error('Failed to store Disability Types: $e');
  } finally {
    isLoading.value = false;
  }
}


  var selectedSubDisabilityTypes = <String, List<String>>{}.obs;
 

  // For disability types search
  TextEditingController typesofDisabilitiesSearchController = TextEditingController();
  var disabilityTypeText = ''.obs;
  var isDisabilityTypesDropdownOpen = false.obs;

  // Map for disability types (name -> subtypes)
  var disabilityTypesMap =  <String, Map<String, dynamic>>{}.obs;
  var filteredDisabilityTypes = <String>[].obs;
  // Category ID for custom entries
  var disabilityTypesCategoryId = 0.obs;
  // Custom entries typed by user (not in DB)
  var customNewDisabilityTypes = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  // Disability types
  var selecteddisabilityTypes = <String>[].obs;
  var otherDisabilitytypes = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDisabilityTypes();
    ever(disabilityTypeText, (String value) {
      searchDisabilityTypes(value);
    });
  }

  // Fetch all disability types and show all by default
  Future<void> fetchDisabilityTypes() async {
    if (disabilityTypesMap.isNotEmpty) return; // Already loaded
    isLoading.value = true;
    error.value = '';
    try {
      final response = await http.get(Uri.parse(Api.getDiagnosis));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final parsed = DiagnosisCategoryResponse.fromJson(data);
        final categories = parsed.diagnosisCategories ?? [];
        final disabilityCategory = categories.firstWhereOrNull(
          (cat) => cat.id == 11 || cat.name == 'Types of Disabilities',
        );
        if (disabilityCategory != null) {
          disabilityTypesCategoryId.value = disabilityCategory.id ?? 0;
          final subcategories = disabilityCategory.diagnosisSubcategories ?? [];
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
          disabilityTypesMap.value = tempMap;
          filteredDisabilityTypes.value = tempMap.keys.toList();
        } else {
          error.value = 'Types of Disabilities category not found';
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

    // Local search for disability types (filter from already-loaded data)
    void searchDisabilityTypes(String searchText) {
      final query = searchText.trim().toLowerCase();
      if (query.isEmpty) {
        filteredDisabilityTypes.value = disabilityTypesMap.keys.toList();
        return;
      }
      if (disabilityTypesMap.isEmpty) {
        filteredDisabilityTypes.value = [];
        return;
      }
      // Filter from already-loaded local data (immediate results)
      filteredDisabilityTypes.value = disabilityTypesMap.keys
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    }

  // Toggle disability types dropdown
  void toggleDisabilityTypesDropdown() {
  isDisabilityTypesDropdownOpen.toggle();
    if (isDisabilityTypesDropdownOpen.value) {
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
      referredToController.isReferredDropdownOpen.value = false;
      //disabilityTypesController.isDisabilityTypesDropdownOpen.value = false;
      diagnosisController.isDiagnosisDropdownOpen.value = false;
    }
    if (!isDisabilityTypesDropdownOpen.value) {
      disabilityTypeText.value = '';
    }
  }

  // Add disability type
  void addDisabilityType(String disability) {
    if (!selecteddisabilityTypes.contains(disability)) {
      selecteddisabilityTypes.add(disability);
      // Initialize selected subtypes for this disability if not present
      if (!selectedSubDisabilityTypes.containsKey(disability)) {
        selectedSubDisabilityTypes[disability] = <String>[];
      }
      if (!disabilityTypesMap.containsKey(disability)) {
        customNewDisabilityTypes.add({
          'name': disability,
          'diagnosis_category_id': disabilityTypesCategoryId.value,
        });
      }
      selecteddisabilityTypes.refresh();
      selectedSubDisabilityTypes.refresh(); 
      update();
      QuickTechSnackbar.success('Selected: $disability');
    }
  }

  // Remove disability type
  void removeDisabilityType(String disability) {
    selecteddisabilityTypes.remove(disability);
    selectedSubDisabilityTypes.remove(disability);
    customNewDisabilityTypes.removeWhere((e) => e['name'] == disability);
    selecteddisabilityTypes.refresh();
    selectedSubDisabilityTypes.refresh(); 
    update();
  }

  // Add sub-disability type to a disability
  void addSubDisabilityType(String disability, String subType) {
    if (!selectedSubDisabilityTypes.containsKey(disability)) {
      selectedSubDisabilityTypes[disability] = <String>[];
    }
    if (!selectedSubDisabilityTypes[disability]!.contains(subType)) {
      selectedSubDisabilityTypes[disability]!.add(subType);
      selectedSubDisabilityTypes.refresh();
    }
  }

  // Remove sub-disability type from a disability
  void removeSubDisabilityType(String disability, String subType) {
    if (selectedSubDisabilityTypes.containsKey(disability)) {
      selectedSubDisabilityTypes[disability]!.remove(subType);
      selectedSubDisabilityTypes.refresh();
    }
  }

  // Clear all disability types selections
  void clearAll() {
    selecteddisabilityTypes.clear();
    selectedSubDisabilityTypes.clear();
    customNewDisabilityTypes.clear();
    update();
  }
  }
