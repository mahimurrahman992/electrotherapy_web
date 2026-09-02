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

var token = QuickTechAuthStorageService.getToken();
final QuickTechPatientInfoController patientInfoController = locator.get<QuickTechPatientInfoController>();
class QuickTechAssestiveDeviceController extends GetxController {

  bool _categoryLoaded = false;
  Future<void>? _categoryLoadFuture;

  Future<void> ensureCategoryLoaded() async {
    if (_categoryLoaded) return;
    if (_categoryLoadFuture != null) return _categoryLoadFuture;

    _categoryLoadFuture = () async {
      await assessmentController.fetchAssesmentId('Assestive Device', fetchAssesDevice);
      _categoryLoaded = assestiveDeviceCategory.value != null;
    }();

    try {
      await _categoryLoadFuture;
    } finally {
      _categoryLoadFuture = null;
    }
  }

  final QuickTechAssessmentController assessmentController = locator.get<QuickTechAssessmentController>();
  TextEditingController assestiveDeviceSearchController = TextEditingController();
  TextEditingController bodyTemperatureController = TextEditingController();
  TextEditingController musclePowerController = TextEditingController();
  TextEditingController fractureAtController = TextEditingController();
  TextEditingController dislocationOfController = TextEditingController();
  
  var assestiveDeviceText = ''.obs;
  var isAssestiveDeviceDropdownOpen = false.obs;
  
  var selectedAssestiveDevice = <String>[].obs;
  var assestiveDeviceDataList = <dynamic>[].obs;
  var selectedsubAssestiveDevice = <String, List<String>>{}.obs;
  var otherSuggestiveDevice = ''.obs;
  var isLoading = false.obs;
  var assestiveDeviceCategory = Rxn<DiagnosisCategorys>();



  Future<void> fetchAssesDevice(int id) async {
    isLoading.value = true;
    final url = '${Api.baseUrl}/api/data/of/diagnosis-category/$id';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      assestiveDeviceCategory.value = DiagnosisCategorys.fromJson(data['diagnosis_category']);
      assestiveDeviceDataList.value = data['diagnosis_category']['diagnosis_subcategories'] ?? [];
    }
    isLoading.value = false;
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   assessmentController.fetchAssesmentId('Assestive Device', fetchAssesDevice);

  // }

  bool showDetailsField(String onExamination) {
    return onExamination == 'Body temperature' ||
        onExamination == 'Muscle power average' ||
        onExamination == 'Facture at' ||
        onExamination == 'Dislocation of';
  }

  TextEditingController getDetailsController(String onExamination) {
    if (onExamination == 'Body temperature') {
      return bodyTemperatureController;
    } else if (onExamination == 'Muscle power average') {
      return musclePowerController;
    } else if (onExamination == 'Facture at') {
      return fractureAtController;
    } else if (onExamination == 'Dislocation of') {
      return dislocationOfController;
    }
    return TextEditingController();
  }

  List<String> get filteredassestiveDevice {
    List<String> deviceNames = assestiveDeviceDataList.map<String>((item) => item['name'] as String).toList();
    if (assestiveDeviceText.isEmpty) {
      return deviceNames;
    }
    return deviceNames
        .where((assestiveDevice) => assestiveDevice.toLowerCase().contains(assestiveDeviceText.toLowerCase()))
        .toList();
  }

  void toggleassestiveDeviceDropdown() {
    isAssestiveDeviceDropdownOpen.toggle();
    if (!isAssestiveDeviceDropdownOpen.value) {
      assestiveDeviceText.value = '';
    }
  }

  void addsuggestiveDevice(String suggestiveDevice) {
    if (!selectedAssestiveDevice.contains(suggestiveDevice)) {
      selectedAssestiveDevice.add(suggestiveDevice);
      update();
      QuickTechSnackbar.success('Selected: $suggestiveDevice');
    }
  }

  void removeSuggestiveDevice(String suggestiveDevice) {
    selectedAssestiveDevice.remove(suggestiveDevice);
    selectedsubAssestiveDevice.remove(suggestiveDevice);
    update();
  }

  void addSubassestiveDevice(String assestiveDevice, String addSubassestiveDevice) {
    if (!selectedsubAssestiveDevice.containsKey(assestiveDevice)) {
      selectedsubAssestiveDevice[assestiveDevice] = [];
    }
    if (!selectedsubAssestiveDevice[assestiveDevice]!.contains(addSubassestiveDevice)) {
      selectedsubAssestiveDevice[assestiveDevice]!.add(addSubassestiveDevice);
      update();
      QuickTechSnackbar.success('Selected: $addSubassestiveDevice');
    }
  }

  void removeSubAssestiveDevice(String assestiveDevice, String addSubassestiveDevice) {
    selectedsubAssestiveDevice[assestiveDevice]?.remove(addSubassestiveDevice);
    if (selectedsubAssestiveDevice[assestiveDevice]?.isEmpty ?? true) {
      selectedsubAssestiveDevice.remove(assestiveDevice);
    }
    update();
  }

  // API call to store assistive device data using new endpoint and keys
  Future<int> storeAssestiveDeviceData() async {
    

    isLoading.value = true;
    try {
      final url = '${Api.baseUrl}/api/assessment/device/store';

      // Prepare the data for the API
      List<String> subcategoryValues = selectedAssestiveDevice.toList();
      List<int> diagSubcatIds = [];
      List<int> diagChildcatIds = [];

      // Add selected assistive devices (subcategories)
      for (String device in selectedAssestiveDevice) {
        var subcategory = assestiveDeviceDataList.firstWhere(
          (item) => item['name'] == device,
          orElse: () => null
        );
        if (subcategory != null) {
          diagSubcatIds.add(subcategory['id']);
        }
      }

      // Add selected sub-assistive devices (child categories)
      selectedsubAssestiveDevice.forEach((device, subDevices) {
        var parentSubcategory = assestiveDeviceDataList.firstWhere(
          (item) => item['name'] == device,
          orElse: () => null
        );
        if (parentSubcategory != null && parentSubcategory['diagnosis_childcategories'] != null) {
          for (String subDevice in subDevices) {
            var childCategory = parentSubcategory['diagnosis_childcategories'].firstWhere(
              (child) => child['name'] == subDevice,
              orElse: () => null
            );
            if (childCategory != null) {
              diagChildcatIds.add(childCategory['id']);
            }
          }
        }
      });

      Map<String, dynamic> requestData = {
        'subcategory_value': subcategoryValues,
        'patient_id': patientInfoController.patientId.value,
        'add_type': 'assessment',
        'diagSubcatIds': diagSubcatIds,
        'diagChildcatIds': diagChildcatIds.isNotEmpty ? diagChildcatIds : null,
      };

      final response = await retryRequest(() => http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${token}'
            },
            body: json.encode(requestData),
          ));

      print('Assistive device status: ${response.statusCode}');
      print('Assistive device response: ${response.body}');
      return response.statusCode;
    } catch (e) {
      print('Error storing assistive device: $e');
      return 500;
    } finally {
      isLoading.value = false;
    }
  }

  // Method to get details for a specific device
  String? getDeviceDetails(String device) {
    if (device == 'Body temperature') return bodyTemperatureController.text;
    if (device == 'Muscle power average') return musclePowerController.text;
    if (device == 'Facture at') return fractureAtController.text;
    if (device == 'Dislocation of') return dislocationOfController.text;
    return null;
  }

  void clearAssestiveDevice() {
    selectedAssestiveDevice.clear();
    selectedsubAssestiveDevice.clear();
    bodyTemperatureController.clear();
    musclePowerController.clear();
    fractureAtController.clear();
    dislocationOfController.clear();
    assestiveDeviceText.value = '';
    isAssestiveDeviceDropdownOpen.value = false;
    update();
  }

  bool hasData() => selectedAssestiveDevice.isNotEmpty;
}