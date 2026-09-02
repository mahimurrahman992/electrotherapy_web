import 'dart:convert';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';

import 'package:e_prescription/controllers/assessment_controller/patient_info/quick_tech_patient_info_controlle.dart';
import 'package:e_prescription/controllers/assessment_controller/quick_tech_assessment_controller.dart';
import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';
import 'package:http/http.dart' as http;
import 'package:e_prescription/services/quick_tech_retry_service.dart';

final QuickTechPatientInfoController patientInfoController = locator.get<QuickTechPatientInfoController>();
var patientId = Rxn<int>(patientInfoController.currentPatientId?.obs.value);

class QuickTechReferredToController extends GetxController {
  bool _categoryLoaded = false;
  Future<void>? _categoryLoadFuture;

  Future<void> ensureCategoryLoaded() async {
    if (_categoryLoaded) return;
    if (_categoryLoadFuture != null) return _categoryLoadFuture;

    _categoryLoadFuture = () async {
      await assessmentController.fetchAssesmentId('Referred To', fetchAssesReff);
      _categoryLoaded = referredToCategory.value != null;
    }();

    try {
      await _categoryLoadFuture;
    } finally {
      _categoryLoadFuture = null;
    }
  }

    // Observable for selected child category IDs
    var selectedDiagChildcatIds = <int>[].obs;
  final QuickTechAssessmentController assessmentController = locator.get<QuickTechAssessmentController>();
  TextEditingController referredToSearchController = TextEditingController();
  var referredToText = ''.obs;
  var isReferredDropdownOpen = false.obs;
  var selectedReferredTo = <String>[].obs;
  var otherreferredTo = ''.obs;
  var referredTolist = <dynamic>[];

  // API call to store referred to data using new endpoint and keys
  Future<int> storeReferredTo(int patientIdValue) async {
    if (patientIdValue == 0) {
      QuickTechSnackbar.error('Patient ID not set');
      return 0;
    }

    isLoading.value = true;
    final token = QuickTechAuthStorageService.getFreshToken();

    try {
      final url =
          '${Api.baseUrl}/api/assess/referred/store';

      // Prepare the data for the API
      List<String> subcategoryValues = selectedReferredTo.toList();
      List<int> diagSubcatIds = [];
      for (String device in selectedReferredTo) {
        var subcategory = referredTolist.firstWhere(
          (item) => item['name'] == device,
          orElse: () => null,
        );
        if (subcategory != null) {
          diagSubcatIds.add(subcategory['id']);
        }
      }

      Map<String, dynamic> requestData = {
        'subcategory_value': subcategoryValues,
        'patient_id': patientIdValue,
        'add_type': 'assessment',
        'diagSubcatIds': diagSubcatIds,
        'diagChildcatIds': selectedDiagChildcatIds.isNotEmpty ? selectedDiagChildcatIds.toList() : null,
      };

      final response = await retryRequest(() => http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${token}',
            },
            body: json.encode(requestData),
          ));

      if (response.statusCode == 401) {
        await QuickTechAuthStorageService.handleUnauthorized();
      }
      print('Referred to status: ${response.statusCode}');
      print('Referred to response: ${response.body}');
      return response.statusCode;
    } catch (e) {
      print('Error storing referred to: $e');

      return 500;
    } finally {

      isLoading.value = false;
    }
  }

  var isLoading = false.obs;
  var referredToCategory = Rxn<DiagnosisCategorys>();

  Future<void> fetchAssesReff(int id) async {
    isLoading.value = true;
    final url =
        '${Api.baseUrl}/api/data/of/diagnosis-category/$id';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      referredToCategory.value = DiagnosisCategorys.fromJson(
        data['diagnosis_category'],
      );
      referredTolist =
          data['diagnosis_category']['diagnosis_subcategories'] ?? [];
    }
    isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    // If this controller is managed by GetX (not only get_it), load once.
    ensureCategoryLoaded();
  }

  //
  var bodytemparture = ''.obs;
  var musclepower = ''.obs;
  var factureAt = ''.obs;
  var dislocationOf = ''.obs;

  bool showDetailsField(String onExamination) {
    return onExamination == 'Body temperature' ||
        onExamination == 'Muscle power average' ||
        onExamination == 'Facture at' ||
        onExamination == 'Dislocation of';
  }

  RxString getDetailsController(String onExamination) {
    if (onExamination == 'Body temperature') {
      return bodytemparture;
    } else if (onExamination == 'Muscle power average') {
      return musclepower;
    } else if (onExamination == 'Facture at') {
      return factureAt;
    } else if (onExamination == 'Dislocation of') {
      return dislocationOf;
    }
    ;
    return RxString('');
  }

  //For Referred To
  List<String> get filteredreferredTo {
    // Use the list fetched from API
    List<String> deviceNames =
        referredTolist.map<String>((item) => item['name'] as String).toList();
    if (referredToText.isEmpty) {
      return deviceNames;
    }
    return deviceNames
        .where(
          (referred) =>
              referred.toLowerCase().contains(referredToText.toLowerCase()),
        )
        .toList();
  }

  void togglereferredToDropdown() {
    isReferredDropdownOpen.toggle();
    if (!isReferredDropdownOpen.value) {
      referredToText.value = '';
    }
  }

  void addReferredTo(String referredTo) {
    if (!selectedReferredTo.contains(referredTo)) {
      selectedReferredTo.add(referredTo);
      update();
      QuickTechSnackbar.success('Selected: $referredTo');
    }
  }

  void removeReferredTo(String referredTo) {
    selectedReferredTo.remove(referredTo);

    update();
  }

  void clearReferredTo() {
    selectedReferredTo.clear();
    selectedDiagChildcatIds.clear();
    bodytemparture.value = '';
    musclepower.value = '';
    factureAt.value = '';
    dislocationOf.value = '';
    referredToText.value = '';
    isReferredDropdownOpen.value = false;
    update();
  }

  bool hasData() => selectedReferredTo.isNotEmpty;
}
