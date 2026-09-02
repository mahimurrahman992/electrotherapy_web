
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/assestive_device_controller.dart';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/diagnosis_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/disability_types_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/drug_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/on_examination_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/primary_medical_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/radiological_findings_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/referred_to_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/patient_info_controller/patient_info_controller.dart';


import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/main_diagnosis_controller.dart';
import 'package:e_prescription/models/prescription/diagnosis_category_response.dart';

import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/optimized_advice_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/previous_therapy_Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';


final PatientInfoController patientInfoController = locator.get<PatientInfoController>();
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
class CheifComplainController extends GetxController {


  

  final MainDiagnosisController mainDiagnosisController = locator.get<MainDiagnosisController>();
  // For chief complaint search
  TextEditingController cheifComplainsearchController = TextEditingController();
  var complaintSearchText = ''.obs;
  var isComplaintDropdownOpen = false.obs;

  // Chief complaints selection
  var selectedComplaints = <String>[].obs;
  var selectedSubComplaints = <String, List<String>>{}.obs;
  var otherComplaint = ''.obs;
  // Custom entries typed by user (not found in DB) – sent as newSubCats[] to the API
  var customNewComplaints = <Map<String, dynamic>>[].obs;

  // Diagnosis model data
  var chiefComplaintCategory = Rxn<DiagnosisCategories>();
  var isLoadingChiefComplaints = false.obs;
  var filteredChiefComplaints = <String>[].obs;
  int? chiefComplaintCategoryId;

  // Simple local search for chief complaints
  void searchChiefComplaints(String searchText) {
    final query = searchText.trim().toLowerCase();
    final complaints =
        chiefComplaintCategory.value?.diagnosisSubcategories
            ?.map((e) => e.name ?? '')
            .where((n) => n.isNotEmpty)
            .toList() ??
        [];
    if (query.isEmpty) {
      filteredChiefComplaints.value = complaints;
      return;
    }
    filteredChiefComplaints.value =
        complaints
            .where((complaint) => complaint.toLowerCase().contains(query))
            .toList();
  }

  // Use MainDiagnosisController to fetch all categories, then filter id==2 for chief complaints
  Future<void> fetchChiefComplaintsFromMainController(
    MainDiagnosisController mainDiagnosisController,
  ) async {
    try {
      isLoadingChiefComplaints.value = true;
      print('[ChiefComplainController] Starting to fetch diagnosis categories...');
      
      await mainDiagnosisController.fetchDiagnosisCategories();
      print('[ChiefComplainController] Diagnosis categories fetched. Total: ${mainDiagnosisController.diagnosisCategories.length}');
      
      if (mainDiagnosisController.diagnosisCategories.isEmpty) {
        throw 'No diagnosis categories found from API';
      }
      
      final chiefCategory = mainDiagnosisController.diagnosisCategories
          .firstWhere(
            (cat) => cat.name == "Chief Complaint",
            orElse: () => throw 'Chief Complaint category not found. Available: ${mainDiagnosisController.diagnosisCategories.map((c) => c.name).join(", ")}',
          );
      
      print('[ChiefComplainController] Found Chief Complaint category with ${chiefCategory.diagnosisSubcategories?.length ?? 0} subcategories');
      
      chiefComplaintCategoryId = chiefCategory.id;
      chiefComplaintCategory.value = chiefCategory;
      filteredChiefComplaints.value =
          chiefComplaintCategory.value?.diagnosisSubcategories
              ?.map((e) => e.name ?? '')
              .where((n) => n.isNotEmpty)
              .toList() ??
          [];
      print('[ChiefComplainController] Loaded ${filteredChiefComplaints.length} complaints');
    } catch (e) {
      print('[ChiefComplainController] ERROR: $e');
      filteredChiefComplaints.value = [];
    } finally {
      isLoadingChiefComplaints.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Fetch chief complaints on initialization (with error handling)
    fetchChiefComplaintsFromMainController(mainDiagnosisController);

    // Watch for search text changes
    ever(complaintSearchText, (String value) {
      searchChiefComplaints(value);
    });
  }

  // Toggle complaint dropdown
  void toggleComplaintDropdown() {
    isComplaintDropdownOpen.toggle();
    if (isComplaintDropdownOpen.value) {
      // If complaints haven't loaded yet, fetch them
      if (filteredChiefComplaints.isEmpty && !isLoadingChiefComplaints.value) {
        fetchChiefComplaintsFromMainController(mainDiagnosisController);
      }
      
      //cheifComplainController.isComplaintDropdownOpen.value = false;
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
      disabilityTypesController.isDisabilityTypesDropdownOpen.value = false;
      diagnosisController.isDiagnosisDropdownOpen.value = false;
    }
    if (!isComplaintDropdownOpen.value) {
      complaintSearchText.value = '';
    }
  }

  // Add complaint
  void addComplaint(String complaint) {
    if (!selectedComplaints.contains(complaint)) {
      selectedComplaints.add(complaint);
      // If it's not a known subcategory fetched from the API, track it as a new entry
      final knownNames =
          chiefComplaintCategory.value?.diagnosisSubcategories
              ?.map((s) => s.name)
              .toSet() ??
          {};
      if (!knownNames.contains(complaint) && chiefComplaintCategoryId != null) {
        customNewComplaints.add({
          'name': complaint,
          'diagnosis_category_id': chiefComplaintCategoryId,
        });
        customNewComplaints.refresh();
      }
      update();
      QuickTechSnackbar.success('Selected: $complaint');
    }
  }

  // Remove complaint
  void removeComplaint(String complaint) {
    selectedComplaints.remove(complaint);
    selectedSubComplaints.remove(complaint);
    customNewComplaints.removeWhere((c) => c['name'] == complaint);
    customNewComplaints.refresh();
    update();
  }

  // Add sub complaint
  void addSubComplaint(String chiefComplaint, String subComplaint) {
    if (!selectedSubComplaints.containsKey(chiefComplaint)) {
      selectedSubComplaints[chiefComplaint] = [];
    }
    if (!selectedSubComplaints[chiefComplaint]!.contains(subComplaint)) {
      selectedSubComplaints[chiefComplaint]!.add(subComplaint);
      selectedSubComplaints.refresh(); // Ensure UI updates
      update();
      QuickTechSnackbar.success('Selected: $subComplaint');
    }
  }

  // Remove sub complaint
  void removeSubComplaint(String chiefComplaint, String subComplaint) {
    selectedSubComplaints[chiefComplaint]?.remove(subComplaint);
    if (selectedSubComplaints[chiefComplaint]?.isEmpty ?? true) {
      selectedSubComplaints.remove(chiefComplaint);
    }
    selectedSubComplaints.refresh(); // Ensure UI updates
    update();
  }

  // Helper to get sub-complaints for a chief complaint using model
  List<String> getSubComplaints(String chiefComplaintName) {
    final subcategory = chiefComplaintCategory.value?.diagnosisSubcategories
        ?.firstWhereOrNull((sub) => sub.name == chiefComplaintName);
    if (subcategory != null) {
      return subcategory.diagnosisChildcategories
              ?.map((c) => c.name ?? '')
              .where((n) => n.isNotEmpty)
              .toList() ??
          [];
    }
    return [];
  }

  var isOnExaminationsDropdownOpen = false.obs;
  var isradiologicalFindingsDropdownOpen = false.obs;
  var isMedicalHistoryDropdownOpen = false.obs;
  var isDrugHistoryDropdownOpen = false.obs;
  var isAssestiveDeviceDropdownOpen = false.obs;
  var isReferredDropdownOpen = false.obs;
  var isDisabilityTypesDropdownOpen = false.obs;
  var isDiagnosisDropdownOpen = false.obs;

  // Other selected items
  var selectedExaminations = <String>[].obs;
  var selectedsubExaminations = <String, List<String>>{}.obs;
  var selectedRadioLogicalFindings = <String>[].obs;
  var selectedsubRadiologicalFindings = <String, List<String>>{}.obs;
  var selectedMedicalHistory = <String>[].obs;
  var selectedsubMedicalHistory = <String, List<String>>{}.obs;
  var selectedDrugHistory = <String>[].obs;
  var selectedsubDrugHistory = <String, List<String>>{}.obs;
  var selectedAssestiveDevice = <String>[].obs;
  var selectedsubAssestiveDevice = <String, List<String>>{}.obs;
  var selectedReferredTo = <String>[].obs;
  var selecteddisabilityTypes = <String>[].obs;
  var selectedDiagnosis = <String>[].obs;
  var selectedsubDiagnosis = <String, List<String>>{}.obs;

  // Other text controllers and search texts
  TextEditingController onexaminationsearchController = TextEditingController();
  TextEditingController radiologicalFindingsearchController =
      TextEditingController();
  TextEditingController medicalHistorySearchController =
      TextEditingController();
  TextEditingController drugHistorySearchController = TextEditingController();
  TextEditingController assestiveDeviceSearchController =
      TextEditingController();
  TextEditingController referredToSearchController = TextEditingController();
  TextEditingController typesofDisabilitiesSearchController =
      TextEditingController();
  TextEditingController diagnosisSearchController = TextEditingController();

  var examinationsSearchText = ''.obs;
  var radiologicalfindingSearchText = ''.obs;
  var medicalhistorySearchText = ''.obs;
  var drughistorySearchText = ''.obs;
  var assestiveDeviceText = ''.obs;
  var referredToText = ''.obs;
  var disabilityTypeText = ''.obs;
  var diagnosisText = ''.obs;

  // Patient information
  var patientName = ''.obs;
  var age = ''.obs;
  var gender = ''.obs;
  var weight = ''.obs;
  Rx<DateTime?> date = Rx<DateTime?>(null);
  TextEditingController dateContoller = TextEditingController();
  void clearChiefComplaint() {
    selectedComplaints.clear();
    selectedSubComplaints.clear();
    customNewComplaints.clear();
    otherComplaint.value = '';
    complaintSearchText.value = '';
    isComplaintDropdownOpen.value = false;
    // Refresh the observables to update UI
    selectedComplaints.refresh();
    selectedSubComplaints.refresh();
    customNewComplaints.refresh();
    update();
    print('✅ All chief complaints cleared');
  }

}