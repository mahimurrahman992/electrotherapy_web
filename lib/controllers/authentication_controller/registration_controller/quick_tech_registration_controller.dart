
import 'dart:convert';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'dart:io';
import 'package:e_prescription/screens/authentications/otp_verification/quick_tech_otp_verification.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class RegistrationModel {
  final String firstName;
  final String email;
  final String mobile;
  final String address;
  final String password;
  final String confirmPassword;
  final String? imagePath; 

  RegistrationModel({
    required this.firstName,
    required this.email,
    required this.mobile,
    required this.address,
    required this.password,
    required this.confirmPassword,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'email': email,
    'mobile': mobile,
    'address': address,
    'password': password,
    'password_confirmation': confirmPassword,
   
  };
}

class QuickTechRegistrationController extends GetxController {
  // Store last registered password for auto-login after OTP
  final RxString lastRegisteredPassword = ''.obs;
  // For OTP verification
  final RxString verifyToken = ''.obs;
  final RxString registeredMobile = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController therapycenternameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();

  final Rx<XFile?> profileImage = Rx<XFile?>(null);
  final RxString profileImagePath = ''.obs;
 
  void clearAllFields() {
    fullNameController.clear();
    phoneController.clear();
    addressController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    therapycenternameController.clear();
    designationController.clear();
    profileImage.value = null;
    profileImagePath.value = '';
    errorMessage('');
  }
  
  bool get isValid {
    return fullNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
  }

  Future<void> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, 
        maxWidth: 800, 
      );
      if (image != null) {
        profileImage.value = image;
        profileImagePath.value = image.path;
      }
    } catch (e) {
      errorMessage('Failed to pick image: $e');
    }
  }

  Future<void> register() async {
  if (!isValid) {
      errorMessage('Please fill all required fields');
      QuickTechSnackbar.error('Please fill all required fields', title: 'Registration Error');
      return;
    }

  if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      errorMessage('Password and Confirm Password do not match');
      QuickTechSnackbar.error('Password and Confirm Password do not match', title: 'Registration Error');
      return;
    }

    try {
      isLoading(true);
      errorMessage('');

      // Always set registeredMobile from the form before API call
      registeredMobile.value = phoneController.text.trim();
      lastRegisteredPassword.value = passwordController.text.trim();

      var uri = Uri.parse(Api.register);
      var request = http.MultipartRequest('POST', uri);

      request.fields['first_name'] = fullNameController.text.trim();
      request.fields['email'] = emailController.text.trim();
      request.fields['mobile'] = phoneController.text.trim();
      request.fields['address'] = addressController.text.trim();
      request.fields['password'] = passwordController.text.trim();
      request.fields['password_confirmation'] = confirmPasswordController.text.trim();

      if (therapycenternameController.text.isNotEmpty) {
        request.fields['therapy_center'] = therapycenternameController.text.trim();
      }

      if (designationController.text.isNotEmpty) {
        request.fields['designation'] = designationController.text.trim();
      }

      if (profileImage.value != null && profileImagePath.value.isNotEmpty) {
        final file = File(profileImagePath.value);
        if (await file.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'profile_photo',
              profileImagePath.value,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          );
        } else {
          errorMessage('Selected image file not found');
          QuickTechSnackbar.error('Selected image file not found. Please choose another image.', title: 'Image Error');
          isLoading(false);
          return;
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['verifyToken'] != null) {
          verifyToken.value = data['verifyToken'].toString();
          // Update registeredMobile from APi if present, else keep form value
          if (data['mobile'] != null && data['mobile'].toString().isNotEmpty) {
            registeredMobile.value = data['mobile'].toString();
          }
          QuickTechSnackbar.info('Your verification code is: ${data['verifyToken']}', title: 'OTP Token');

          Get.to(()=>QuickTechOtpVerification(mobile: registeredMobile.value, verifyToken: verifyToken.value));
        } else if (data['success'] == true || data['status'] == true) {
          QuickTechSnackbar.success(data['message']?.toString() ?? 'Registration successful');
          Get.offAllNamed('/home');
        } else {
          final errMsg = data['message']?.toString() ?? 'Registration failed';
          errorMessage(errMsg);
          QuickTechSnackbar.error(errMsg, title: 'Registration Error');
        }
      } else {
        String errMsg;
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['errors'] != null && errorData['errors'] is Map) {
       
            final errors = errorData['errors'] as Map;
            errMsg = errors.entries
                .map((entry) =>
                    "${entry.key}: ${(entry.value is List ? (entry.value as List).join(', ') : entry.value.toString())}")
                .join('\n');
          } else {
            errMsg = errorData['message']?.toString() ??
                errorData['error']?.toString() ??
                'Registration failed with status ${response.body}';
          }
        } catch (e) {
          errMsg = 'Registration failed with status ${response.body}';
        }

        errorMessage(errMsg);
        QuickTechSnackbar.error(errMsg, title: 'Registration Failed');
      }
    } catch (e) {
      final errMsg = 'Registration failed: ${e.toString()}';
      errorMessage(errMsg);
      QuickTechSnackbar.error(errMsg, title: 'Registration Error');
    } finally {
      isLoading(false);
    }
  }
}
