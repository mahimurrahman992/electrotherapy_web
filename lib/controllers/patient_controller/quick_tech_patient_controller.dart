import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:e_prescription/models/patient_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class QuickTechPatientController extends GetxController {
  Future<bool> deletePatient(int patientId) async {
    final url = '${Api.baseUrl}/api/delete/patient';
    var bearerToken = QuickTechAuthStorageService.getToken();
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'patient_id': patientId}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (response.statusCode == 200 || data['success'] == true) {
          print('Patient deleted successfully.');
           QuickTechSnackbar.info('${data['message']}', title: 'ID ${patientId} deleted');
        } else {
          print('Failed to delete patient. Message: ${data['message']}');
        }
        return true;
      } else {
        print('Failed to delete patient. Status: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting patient: $e');
      return false;
    }
  }
  // Assessment PDF
  Rx<Uint8List?> assessmentPdfBytes = Rx<Uint8List?>(null);
  RxBool isAssessmentPdfLoading = false.obs;
  RxString assessmentPdfError = ''.obs;

  Future<String?> fetchAssessmentPdf(int assessmentId, String token) async {
    isAssessmentPdfLoading.value = true;
    assessmentPdfError.value = '';
    assessmentPdfBytes.value = null;
    final url = '${Api.baseUrl}/api/assessment/of/prescription/$assessmentId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      );
      if (response.statusCode == 200) {
        assessmentPdfBytes.value = response.bodyBytes;
        isAssessmentPdfLoading.value = false;
        return null;
      } else {
        String message = 'Failed to fetch assessment PDF.';
        try {
          final data = json.decode(response.body);
          if (data is Map && data['message'] != null) {
            message = data['message'];
          }
        } catch (_) {
          message = response.body.toString();
        }
        assessmentPdfError.value = message;
        isAssessmentPdfLoading.value = false;
        return message;
      }
    } catch (e) {
      assessmentPdfError.value = 'Network error: ${e.toString()}';
      isAssessmentPdfLoading.value = false;
      return assessmentPdfError.value;
    }
  }
  Rx<Uint8List?> prescriptionPreviewPdfBytes = Rx<Uint8List?>(null);
  RxBool isPdfLoading = false.obs;
  RxString pdfError = ''.obs;
  TextEditingController searchPatientController = TextEditingController();
  RxList<Map<String, dynamic>> prescriptions = <Map<String, dynamic>>[].obs;
  RxBool isPatientsLoading = false.obs;
  RxBool isLoading = false.obs;
  RxString error = ''.obs;

  // Assessments
  RxList<Map<String, dynamic>> assessments = <Map<String, dynamic>>[].obs;
  RxBool isAssessmentLoading = false.obs;
  RxString assessmentError = ''.obs;

  Future<void> fetchAssessments(int patientId, String token) async {
    isAssessmentLoading.value = true;
    assessmentError.value = '';
    final url = '${Api.baseUrl}/api/assessments/of/patient/$patientId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['assessment_prescriptions'] != null) {
            assessments.value = List<Map<String, dynamic>>.from(data['assessment_prescriptions']);
          } else {
            assessments.clear();
          }
        } else {
          assessmentError.value = 'Failed to fetch assessments. Status: ${response.statusCode}';
          assessments.clear();
        }
        isAssessmentLoading.value = false;
      });
    } catch (e) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        assessmentError.value = 'Network error: ${e.toString()}';
        assessments.clear();
        isAssessmentLoading.value = false;
      });
    }
  }

  Future<void> fetchPrescriptions(int patientId, String token) async {
    isLoading.value = true;
    error.value = '';
    final url = '${Api.baseUrl}/api/prescriptions/of/patient/$patientId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['patient_prescriptions'] != null) {
            prescriptions.value = List<Map<String, dynamic>>.from(data['patient_prescriptions']);
          } else {
            prescriptions.clear();
          }
        } else {
          error.value = 'Failed to fetch prescriptions. Status: ${response.statusCode}';
          prescriptions.clear();
        }
        isLoading.value = false;
      });
    } catch (e) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        error.value = 'Network error: ${e.toString()}';
        prescriptions.clear();
        isLoading.value = false;
      });
    }
  }

  var patients = <Patient>[].obs;
  List<Patient> allPatients = [];

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPatients();
    });
  }

  Future<void> fetchPatients() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isPatientsLoading.value = true;
    });
    final url = '${Api.baseUrl}/api/user/patient/list';
    var bearerToken = QuickTechAuthStorageService.getToken();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List patientsJson = data['patients'];
        allPatients = patientsJson.map<Patient>((json) => Patient.fromJson(json)).toList();
        patients.value = List.from(allPatients);
      } else {
        String errorMsg = 'Failed to fetch patients.';
        try {
          final data = json.decode(response.body);
          if (data is Map && data['message'] != null) {
            errorMsg = data['message'];
          }
        } catch (_) {
          errorMsg = response.body.toString();
        }
        print('Failed to fetch patients. Status: $errorMsg');
        // Show snackbar for rate limit or other errors
        QuickTechSnackbar.error(errorMsg);
      }
    } catch (e) {
      print('Error fetching patients: $e');
      QuickTechSnackbar.error('Network error: ${e.toString()}');
    }
    isPatientsLoading.value = false;
  }

  void searchPatients(String query) {
    if (query.isEmpty) {
      patients.value = List.from(allPatients);
    } else {
      final searchId = int.tryParse(query);
      if (searchId != null) {
        patients.value = allPatients
            .where((patient) => patient.id == searchId)
            .toList();
      } else {
        patients.value = allPatients
            .where((patient) => patient.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    }
  }

  Future<String?> fetchPrescriptionPreviewPdf(dynamic prescriptionId, dynamic templateId, String token) async {
    print('Selected templateId: $templateId');
    isPdfLoading.value = true;
    pdfError.value = '';
    prescriptionPreviewPdfBytes.value = null;
    final url = '${Api.baseUrl}/api/prescription/$prescriptionId/template-value/$templateId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      );
      if (response.statusCode == 200) {
        prescriptionPreviewPdfBytes.value = response.bodyBytes;
        isPdfLoading.value = false;
        return null;
      } else {
    
        String message = 'Failed to fetch PDF preview.';
        try {
          final data = json.decode(response.body);
          if (data is Map && data['message'] != null) {
            message = data['message'];
          }
        } catch (_) {
          message = response.body.toString();
        }
        pdfError.value = message;
        isPdfLoading.value = false;
        return message;
      }
    } catch (e) {
      pdfError.value = 'Network error: ${e.toString()}';
      isPdfLoading.value = false;
      return pdfError.value;
    }
  }

  void addPatient(Patient patient) {
    patients.add(patient);
  }

  void removePatient(int index) {
    patients.removeAt(index);
  }

  void updatePatient(int index, Patient patient) {
    patients[index] = patient;
  }
}