import 'dart:convert';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/controllers/authentication_controller/registration_controller/quick_tech_registration_controller.dart';
import 'package:e_prescription/controllers/authentication_controller/login_controller/quick_tech_login_controller.dart';
import 'package:http/http.dart' as http;

class QuickTechOtpController extends GetxController {
  // Reference to registration and login controllers
  final registrationController = locator.get<QuickTechRegistrationController>();
  final loginController = locator.get<QuickTechLoginController>();
  final RxString errorText = ''.obs;
  final RxString verifyToken = ''.obs;
  final RxBool isLoading = false.obs;

  Future<void> resendOtpWithApi({required String mobile}) async {
    try {
      isLoading.value = true;
      errorText.value = '';
      final response = await http.post(
        Uri.parse(Api.resend),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mobile': mobile}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['verifyToken'] != null) {
          verifyToken.value = data['verifyToken'].toString();
          QuickTechSnackbar.info('Your new verification code is: ${data['verifyToken']}', title: 'OTP Token');
        } else {
          errorText.value = data['message']?.toString() ?? 'Failed to resend OTP';
        }
      } else {
        errorText.value = 'Failed to resend OTP: ${response.body}';
      }
    } catch (e) {
      errorText.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void setVerifyToken(String token) {
    verifyToken.value = token;
  }

  Future<bool> verifyOtpWithApi({required String mobile, required String otp}) async {
    try {
      isLoading.value = true;
      errorText.value = '';
      final response = await http.post(
        Uri.parse(Api.verify),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile': mobile,
          'otp': otp,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final status = data['status'] != null ? data['status'].toString().toLowerCase() : null;
        final msg = data['message'] != null ? data['message'].toString().toLowerCase() : '';
        if (data['success'] == true || status == 'success') {
          if (msg.contains('verified')) {
            // Auto-login after successful verification
            final mobile = registrationController.registeredMobile.value;
            final password = registrationController.lastRegisteredPassword.value;
            if (mobile.isNotEmpty && password.isNotEmpty) {
              await loginController.loginWithCredentials(mobile, password);
            }
            errorText.value = '';
            return true;
          }
          errorText.value = '';
          return true;
        } else {
          errorText.value = data['message']?.toString() ?? 'Verification failed';
        }
      } else {
        errorText.value = 'Verification failed: ${response.body}';
      }
    } catch (e) {
      errorText.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
    return false;
  }

}
