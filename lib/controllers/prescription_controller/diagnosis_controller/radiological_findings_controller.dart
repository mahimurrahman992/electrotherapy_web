import 'dart:convert';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/assestive_device_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/cheif_complain_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/diagnosis_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/disability_types_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/drug_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/on_examination_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/primary_medical_history_controller.dart';
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
final primarymedicalController = locator.get<PrimaryMedicalHistoryController>();
final drugHistoryController = locator.get<DrugHistoryController>();
final previousTherapyHistoryController = locator.get<PreviousTherapyHistoryController>();
final adviceController = locator.get<OptimizedAdviceController>();
final assistiveDeviceController = locator.get<AssestiveDeviceController>();
final referredToController = locator.get<ReferredToController>();
final disabilityTypesController = locator.get<DisabilityTypesController>();
final diagnosisController = locator.get<DiagnosisController>();
class RadiologicalFindingsController extends GetxController {

Future<void> storeRadiologicalFindings() async {
  final patientId = patientInfoController.patientId.value;
  final addType = 'prescription';
  final date = patientInfoController.date.value!.toIso8601String().substring(0, 10);

  try {
    isLoadingRadiologicalFindings.value = true;
    if (radiologicalFindingsMap.isEmpty) {
      throw Exception('Radiological Findings data not loaded');
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
for (final complaintName in selectedRadioLogicalFindings) {
  final subcategoryData = radiologicalFindingsMap[complaintName];
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
  final subComplaints = selectedsubRadiologicalFindings[complaintName] ?? [];
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
      print('✅ Bulk Radiological Findings stored successfully: $responseData');
      QuickTechSnackbar.success('Radiological Findings stored successfully!');
    } else {
      throw Exception('Failed to store Radiological Findings: ${responseData['message'] ?? 'Unknown error'}');
    }

  } catch (e) {
    print('❌ Failed to store Radiological Findings: $e');
    QuickTechSnackbar.error('Failed to store Radiological Findings: $e');
  } finally {
    isLoadingRadiologicalFindings.value = false;
  }
}


  final PreviousTherapyHistoryController previoustherapyController = locator.get<PreviousTherapyHistoryController>();
  final OptimizedAdviceController adviceController2 = locator.get<OptimizedAdviceController>();

  // For radiological findings search
  TextEditingController radiologicalFindingsearchController = TextEditingController();
  var radiologicalfindingSearchText = ''.obs;
  var isRadiologicalFindingsDropdownOpen = false.obs;

  // Radiological findings 
  var selectedRadioLogicalFindings = <String>[].obs;
  var selectedsubRadiologicalFindings = <String, List<String>>{}.obs;
  var otherRadiologicalFindings = ''.obs;

    var radiologicalFindingsMap = <String, Map<String, dynamic>>{}.obs;
  var isLoadingRadiologicalFindings = false.obs;

  // Filtered radiological findings for search 
  var filteredRadiologicalFindings = <String>[].obs;
  // Category ID for custom entries
  var radiologicalFindingsCategoryId = 0.obs;
  // Custom entries typed by user (not in DB)
  var customNewRadiologicalFindings = <Map<String, dynamic>>[].obs;

  // Search radiological findings - LOCAL FILTERING FIRST (immediate results)
  void searchRadiologicalFindings(String searchText) {
    final query = searchText.trim().toLowerCase();
    if (query.isEmpty) {
      filteredRadiologicalFindings.value = radiologicalFindingsMap.keys.toList();
      return;
    }
    if (radiologicalFindingsMap.isEmpty) {
      filteredRadiologicalFindings.value = [];
      return;
    }
    // Filter from already-loaded local data (immediate results)
    filteredRadiologicalFindings.value = radiologicalFindingsMap.keys
        .where((item) => item.toLowerCase().contains(query))
        .toList();
  }

  // Fetch radiological findings from API and show all by default
  Future<void> fetchRadiologicalFindings() async {
    if (radiologicalFindingsMap.isNotEmpty) return; // Already loaded
    isLoadingRadiologicalFindings.value = true;
    try {
      final response = await http.get(Uri.parse(Api.getDiagnosis));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final parsed = DiagnosisCategoryResponse.fromJson(data);
        final categories = parsed.diagnosisCategories ?? [];
        final radioCategory = categories.firstWhereOrNull(
          (cat) => cat.name == 'Radiological Findings',
        );
        if (radioCategory != null) {
          radiologicalFindingsCategoryId.value = radioCategory.id ?? 0;
          final subcategories = radioCategory.diagnosisSubcategories ?? [];
          final Map<String, Map<String, dynamic>> tempMap = {};
          for (var sub in subcategories) {
            final subName = sub.name ?? '';
            if (subName.isEmpty) continue;
            final childList = sub.diagnosisChildcategories ?? [];
            final subId = sub.id;
            final List<Map<String, dynamic>> childData = childList.map((c) => {
              'id': c.id,
              'name': c.name,
            }).toList();
            tempMap[subName] = {
              'id': subId,
              'children': childData,
            };
          }
          radiologicalFindingsMap.value = tempMap;
          // Show all radiologicalFindingsMap keys by default
          filteredRadiologicalFindings.value = tempMap.keys.toList();
        }
      }
    } catch (e) {
      QuickTechSnackbar.error('Failed to fetch radiological findings');
    } finally {
      isLoadingRadiologicalFindings.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchRadiologicalFindings();
    // Listen to search text changes
    ever(radiologicalfindingSearchText, (String value) {
      searchRadiologicalFindings(value);
    });
  }

  // Toggle radiological findings dropdown
  void toggleRadiologicalFindingsDropdown() {
    isRadiologicalFindingsDropdownOpen.toggle();
    if (isRadiologicalFindingsDropdownOpen.value) {
      cheifComplainController.isComplaintDropdownOpen.value = false;
      onExaminationController.isDropdownOpen.value = false;
      // radiologicalFindingsController.isRadiologicalFindingsDropdownOpen.value =
      //     false;
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
    if (!isRadiologicalFindingsDropdownOpen.value) {
      radiologicalfindingSearchText.value = '';
    }
  }

  // Add radiological finding
  void addRadiologicalFinding(String finding) {
    if (!selectedRadioLogicalFindings.contains(finding)) {
      selectedRadioLogicalFindings.add(finding);
      if (!radiologicalFindingsMap.containsKey(finding)) {
        customNewRadiologicalFindings.add({
          'name': finding,
          'diagnosis_category_id': radiologicalFindingsCategoryId.value,
        });
      }
      selectedRadioLogicalFindings.refresh();
      update();
      QuickTechSnackbar.success('Selected: $finding');
    }
  }

  // Remove radiological finding
  void removeRadiologicalFinding(String finding) {
    selectedRadioLogicalFindings.remove(finding);
    selectedsubRadiologicalFindings.remove(finding);
    customNewRadiologicalFindings.removeWhere((e) => e['name'] == finding);
    update();
  }

  // Add sub radiological finding
  void addSubRadiologicalFinding(String finding, String subFinding) {
    if (!selectedsubRadiologicalFindings.containsKey(finding)) {
      selectedsubRadiologicalFindings[finding] = [];
    }
    if (!selectedsubRadiologicalFindings[finding]!.contains(subFinding)) {
      selectedsubRadiologicalFindings[finding]!.add(subFinding);
      selectedRadioLogicalFindings.refresh();
      update();
      QuickTechSnackbar.success('Selected: $subFinding');
    }
  }

  // Remove sub radiological finding
  void removeSubRadiologicalFinding(String finding, String subFinding) {
    selectedsubRadiologicalFindings[finding]?.remove(subFinding);
    if (selectedsubRadiologicalFindings[finding]?.isEmpty ?? true) {
      selectedsubRadiologicalFindings.remove(finding);
    }
    selectedRadioLogicalFindings.refresh();
    update();
  }

  // Clear all radiological findings selections
  void clearAll() {
    selectedRadioLogicalFindings.clear();
    selectedsubRadiologicalFindings.clear();
    customNewRadiologicalFindings.clear();
    update();
  }
}
