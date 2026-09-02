import 'package:e_prescription/controllers/prescription_controller/patient_info_controller/patient_info_controller.dart';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/cheif_complain_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/on_examination_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/radiological_findings_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/primary_medical_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/drug_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/previous_therapy_Controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/assestive_device_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/referred_to_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/disability_types_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/diagnosis_controller.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/models/prescription/diagnosis_category_response.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final PatientInfoController patientInfoController = locator.get<PatientInfoController>();
final cheifComplainController = locator.get<CheifComplainController>();
final onExaminationController = locator.get<OnExaminationController>();
final radiologicalFindingsController = locator.get<RadiologicalFindingsController>();
final primarymedicalController = locator.get<PrimaryMedicalHistoryController>();
final drugHistoryController = locator.get<DrugHistoryController>();
final previousTherapyHistoryController = locator.get<PreviousTherapyHistoryController>();
final assistiveDeviceController = locator.get<AssestiveDeviceController>();
final referredToController = locator.get<ReferredToController>();
final disabilityTypesController = locator.get<DisabilityTypesController>();
final diagnosisController = locator.get<DiagnosisController>();
class OptimizedAdviceController extends GetxController {
  // Add these maps inside your controller
  var testSubcategoryMapping = <String, int>{};
  var testChildcategoryMapping = <String, int>{};



  var showMainDropdown = false.obs;
  void toggleMainDropdown() => showMainDropdown.toggle();
  // Dropdown visibility controls
  var showDropdowns =
      <String, bool>{
        'main': false,
        'xray': false,
        'mri': false,
        'ctscan': false,
        'hematology': false,
        'others': false,
      }.obs;

  // Selected tests and side options
  var selectedTests = <String>[].obs;
  var showSideOptions = <String, bool>{}.obs;

  // Toggle dropdowns by key
  void toggleDropdown(String key) {
    // If opening advice main dropdown, close all other dropdowns
    if (key == 'main' && !(showDropdowns['main'] ?? false)) {
 

      cheifComplainController.isComplaintDropdownOpen.value = false;
      onExaminationController.isDropdownOpen.value = false;
      radiologicalFindingsController.isRadiologicalFindingsDropdownOpen.value = false;
      primarymedicalController.isMedicalHistoryDropdownOpen.value = false;
      drugHistoryController.isDrugHistoryDropdownOpen.value = false;
      previousTherapyHistoryController.showMainDropdown.value = false;
      previousTherapyHistoryController.showDropdowns.updateAll((k, v) => false);
      assistiveDeviceController.isAssestiveDeviceDropdownOpen.value = false;
      referredToController.isReferredDropdownOpen.value = false;
      disabilityTypesController.isDisabilityTypesDropdownOpen.value = false;
      diagnosisController.isDiagnosisDropdownOpen.value = false;
    }
    showDropdowns[key] = !(showDropdowns[key] ?? false);
  }

  // Test selection helpers
  bool isTestSelected(String test) {
    return selectedTests.contains(test) ||
        selectedTests.contains('$test (Lt)') ||
        selectedTests.contains('$test (Rt)');
  }

  bool isSideSelected(String test, String side) {
    return selectedTests.contains('$test ($side)');
  }

  bool shouldShowSideOptions(String test) {
    return showSideOptions[test] == true;
  }

  void showSideOptionsFor(String test) {
    showSideOptions[test] = true;
  }

  void addTest(String test) {
    if (!selectedTests.contains(test)) {
      selectedTests.add(test);
      QuickTechSnackbar.success('$test has been selected', title: 'Test Selected');
    }
  }

  void removeTest(String test) {
    selectedTests.remove(test);
    QuickTechSnackbar.error('$test has been unselected', title: 'Test Unselected');
  }

  void removeTestWithSides(String test) {
    selectedTests.remove(test);
    selectedTests.remove('$test (Lt)');
    selectedTests.remove('$test (Rt)');
    showSideOptions[test] = false;
    QuickTechSnackbar.error('$test has been unselected with sides', title: 'Test Unselected');
  }

  void toggleSide(String test, String side) {
    final sideTest = '$test ($side)';
    if (selectedTests.contains(sideTest)) {
      selectedTests.remove(sideTest);
      QuickTechSnackbar.error('$side side for $test has been unselected', title: 'Side Unselected');
    } else {
      selectedTests.add(sideTest);
      if (!isTestSelected(test)) {
        showSideOptionsFor(test);
      }
      QuickTechSnackbar.success('$side side for $test has been selected', title: 'Side Selected');
    }
  }

  // Test options (dynamic from API)
  var xrayOptions = <String>[].obs;
  var mriOptions = <String>[].obs;
  var ctScanOptions = <String>[].obs;
  var hematologyOptions = <String>[].obs;
  var othersOptions = <String>[].obs;
  var hasSideOptions = <String>[].obs; // options with 'With Left/Right' type
  var isLoadingAdviceOptions = false.obs;

  // Fetch adviceoptions from API
  Future<void> fetchAdviceOptions() async {
    isLoadingAdviceOptions.value = true;
    try {
      final response = await http.get(Uri.parse(Api.getDiagnosis));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final parsed = DiagnosisCategoryResponse.fromJson(data);
        final categories = parsed.diagnosisCategories ?? [];
        final adviceCategory = categories.firstWhereOrNull(
          (cat) => cat.name == 'Advice',
        );
        if (adviceCategory != null) {
          final subcategories = adviceCategory.diagnosisSubcategories ?? [];
          var tempHasSide = <String>[];
          for (var sub in subcategories) {
            final subName = sub.name ?? '';
            if (subName.isEmpty) continue;
            final childList = sub.diagnosisChildcategories ?? [];
            final List<String> childNames = childList.map((c) => c.name ?? '').where((n) => n.isNotEmpty).toList();
            // Find which child options have type 'With Left/Right'
            for (var c in childList) {
              final childName = c.name ?? '';
              if (childName.isEmpty) continue;
              final childId = c.id ?? 0;
              testChildcategoryMapping[childName] = childId;
              testSubcategoryMapping[childName] = sub.id ?? 0;
              if (c.type == 'With Left/Right') {
                tempHasSide.add(childName);
              }
            }
            if (subName == 'X ray of') {
              xrayOptions.value = childNames;
            } else if (subName == 'MRI of') {
              mriOptions.value = childNames;
            } else if (subName == 'CT scan of') {
              ctScanOptions.value = childNames;
            } else if (subName == 'Hematology & Serology') {
              hematologyOptions.value = childNames;
            } else if (subName == 'Other Tests') {
              othersOptions.value = childNames;
            }
          }
          hasSideOptions.value = tempHasSide;
        }
      }
    } catch (e) {
      QuickTechSnackbar.error('Failed to fetch advice options');
    } finally {
      isLoadingAdviceOptions.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAdviceOptions();
  }
}
