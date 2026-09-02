import 'package:e_prescription/models/profile/profile_model.dart';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class QuickTechProfileController extends GetxController {
  // Observables
  var therapyCenter = ''.obs;
  var name = ''.obs;
  var address = ''.obs;
  var phone = ''.obs;
  var doctor = ''.obs;
  var designation = ''.obs;
  var profilePhoto = ''.obs;
  var isLoading = false.obs;
  var error = ''.obs;
  
  // New fields from model
  var centerName = ''.obs;
  var centerAddress = ''.obs;
  var bnFirstName = ''.obs;
  var bnTherapyCenter = ''.obs;
  var bnDesignation = ''.obs;
  var bnClinicAddress = ''.obs;
  
  // Store the full profile model
  Rx<Profile?> profile = Rx<Profile?>(null);

  @override
  void onInit() {
    super.onInit();
    // Delay profile fetch to avoid blocking initialization
    // Profile will be fetched when drawer is opened or screen loads
    Future.delayed(const Duration(milliseconds: 500), () {
      fetchProfile();
    });
  }

  // -------------------------------
  // Fetch profile details
  // -------------------------------
  Future<void> fetchProfile() async {
    isLoading.value = true;
    error.value = '';
    try {
      final token = QuickTechAuthStorageService.getFreshToken();
      if (token == null) {
        await QuickTechAuthStorageService.handleUnauthorized();
        return;
      }
      final response = await http.get(
        Uri.parse(Api.getProfile),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        await QuickTechAuthStorageService.handleUnauthorized();
      } else if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Use the Profile model
        profile.value = Profile.fromJson(data);
        final user = profile.value?.user;

        if (user != null) {
          // English fields
          name.value = user.firstName ?? '';
          therapyCenter.value = user.therapyCenter ?? '';
          designation.value = user.designation ?? '';
          address.value = user.clinicAddress ?? '';
          
          // Additional fields
          centerName.value = user.centerName ?? '';
          centerAddress.value = user.centerAddress ?? '';
          phone.value = user.mobile ?? '';
          
          // Bengali fields
          bnFirstName.value = user.bnFirstName ?? '';
          bnTherapyCenter.value = user.bnTherapyCenter ?? '';
          bnDesignation.value = user.bnDesignation ?? '';
          bnClinicAddress.value = user.bnClinicAddress ?? '';

          // Profile photo
          profilePhoto.value = user.profilePhoto ?? '';
        }
      } else {
        error.value = 'Failed to load profile: ${response.body}';
      }
    } catch (e) {
      error.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------------------
  // Save/update profile
  // -------------------------------
  Future<void> saveProfile({bool isNewImage = false, String? localImagePath}) async {
    isLoading.value = true;
    error.value = '';
    try {
      final token = QuickTechAuthStorageService.getFreshToken();
      if (token == null) {
        await QuickTechAuthStorageService.handleUnauthorized();
        return;
      }
      http.Response response;

      // If user picked a new image
      if (isNewImage && localImagePath != null && File(localImagePath).existsSync()) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(Api.updateProfile),
        );
        request.headers.addAll({
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        });
        
        // English fields
        request.fields['first_name'] = name.value;
        request.fields['therapy_center'] = therapyCenter.value;
        request.fields['designation'] = designation.value;
        request.fields['clinic_address'] = address.value;
        
        // Additional fields
        request.fields['center_name'] = centerName.value;
        request.fields['center_address'] = centerAddress.value;
        
        // Bengali fields
        request.fields['bn_first_name'] = bnFirstName.value;
        request.fields['bn_therapy_center'] = bnTherapyCenter.value;
        request.fields['bn_designation'] = bnDesignation.value;
        request.fields['bn_clinic_address'] = bnClinicAddress.value;

        request.files.add(await http.MultipartFile.fromPath(
          'profile_photo',
          localImagePath,
        ));

        var streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // No new image, send JSON body
        response = await http.post(
          Uri.parse(Api.updateProfile),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            // English fields
            'first_name': name.value,
            'therapy_center': therapyCenter.value,
            'designation': designation.value,
            'clinic_address': address.value,
            
            // Additional fields
            'center_name': centerName.value,
            'center_address': centerAddress.value,
            
            // Bengali fields
            'bn_first_name': bnFirstName.value,
            'bn_therapy_center': bnTherapyCenter.value,
            'bn_designation': bnDesignation.value,
            'bn_clinic_address': bnClinicAddress.value,
          }),
        );
      }

      if (response.statusCode == 401) {
        await QuickTechAuthStorageService.handleUnauthorized();
      } else if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Refresh profile data first
        await fetchProfile();
        Get.back(); // Go back to profile page
        QuickTechSnackbar.success(data['message'] ?? 'Profile updated successfully');
      } else {
        final errorData = json.decode(response.body);
        error.value = errorData['message'] ?? 'Failed to update profile: ${response.statusCode}';
        QuickTechSnackbar.error(error.value);
      }
    } catch (e) {
      error.value = 'Error: ${e.toString()}';
      QuickTechSnackbar.error(error.value);
    } finally {
      isLoading.value = false;
    }
  }
}