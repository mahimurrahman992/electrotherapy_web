import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:e_prescription/screens/authentications/login/quick_tech_login_verification.dart';
import 'package:e_prescription/services/template_services/quick_tech_template_storage_service.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:e_prescription/utils/ui_helpers.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:e_prescription/models/user_model/quick_tech_user_model.dart';

class QuickTechLoginController extends GetxController {
  // Lazy-initialized Google Sign-In
  GoogleSignIn? _googleSignIn;

  // Getter that ensures initialization
  GoogleSignIn get googleSignInInstance {
    if (_googleSignIn == null) {
      if (kIsWeb) {
        _googleSignIn = GoogleSignIn(
          clientId:
              '637978940538-8ra2n5459golm1q22fo576om3pe3trfn.apps.googleusercontent.com',
          scopes: ['email', 'profile'],
        );
      } else {
        _googleSignIn = GoogleSignIn.standard();
      }
    }
    return _googleSignIn!;
  }

  Future<void> loginWithCredentials(String mobile, String password) async {
    if (validatePhoneNumber(mobile) != null ||
        validatePassword(password) != null) {
      UIHelper.showNotification(
        title: 'Error',
        message: 'Please fill all fields correctly',
      );
      return;
    }
    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse(Api.login),
        headers: {'Accept': 'application/json'},
        body: {'mobile': mobile, 'password': password},
      );
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final token = data['access_token'];
        final user = QuickTechUserModel.fromJson(data['user']);
        await QuickTechAuthStorageService.saveToken(token);
        await QuickTechAuthStorageService.saveUser(user);
        Get.offAllNamed('/mainhome');
      } else if (data['verifyToken'] != null && data['mobile'] != null) {
        UIHelper.showNotification(
          title: 'Verification Required',
          message:
              'Please verify your account. A verification code has been sent to your mobile.',
        );
        Get.to(() => QuickTechLoginVerification(staticMobile: data['mobile']));
      } else {
        UIHelper.showNotification(
          title: 'Login Failed',
          message: data['message'] ?? 'You Have to Sign Up First',
        );
      }
    } catch (e) {
      UIHelper.showNotification(
        title: 'Error',
        message: 'Login failed: \\${e.toString()}',
      );
    } finally {
      isLoading(false);
    }
  }

  // Google Sign-In
  Future<void> googleSignIn() async {
    try {
      isLoading(true);
      // Sign out first to always show account picker (reuse initialized instance)
      await googleSignInInstance.signOut();
      final GoogleSignInAccount? googleUser =
          await googleSignInInstance.signIn();
      if (googleUser == null) {
        isLoading(false);
        return; // User cancelled
      }
      final email = googleUser.email;
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/api/check/email/and/login'),
        headers: {'Accept': 'application/json'},
        body: {'email': email},
      );
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final token = data['access_token'];
        final user = QuickTechUserModel.fromJson(data['user']);
        await QuickTechAuthStorageService.saveToken(token);
        await QuickTechAuthStorageService.saveUser(user);
        Get.offAllNamed('/mainhome');
      } else if (data['status'] == 'failed' &&
          data['message'] == 'This email has no user registered') {
        showRegistrationBottomSheet(email);
      } else {
        UIHelper.showNotification(
          title: 'Login Failed',
          message: data['message'] ?? 'Unknown error',
        );
      }
    } catch (e) {
      UIHelper.showNotification(
        title: 'Error',
        message: 'Google Sign-In failed: ${e.toString()}',
      );
    } finally {
      isLoading(false);
    }
  }

  // Show registration bottom sheet for new Google users
  void showRegistrationBottomSheet(String email) {
    final phoneController = TextEditingController();
    final passController = TextEditingController();
    final confirmPassController = TextEditingController();
    // To store the password for direct login after registration
    String? tempPassword;
    Get.bottomSheet(
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Register New Account',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('Email: $email'),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 8),
              TextField(
                controller: passController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 8),
              TextField(
                controller: confirmPassController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final phone = phoneController.text.trim();
                  final pass = passController.text.trim();
                  final confirmPass = confirmPassController.text.trim();
                  if (phone.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
                    UIHelper.showNotification(
                      title: 'Error',
                      message: 'All fields are required',
                    );
                    return;
                  }
                  if (pass != confirmPass) {
                    UIHelper.showNotification(
                      title: 'Error',
                      message: 'Passwords do not match',
                    );
                    return;
                  }
                  if (validatePhoneNumber(phone) != null ||
                      validatePassword(pass) != null) {
                    UIHelper.showNotification(
                      title: 'Error',
                      message: 'Please fill all fields correctly',
                    );
                    return;
                  }
                  try {
                    isLoading(true);
                    final registerResponse = await http.post(
                      Uri.parse(Api.register),
                      headers: {'Accept': 'application/json'},
                      body: {
                        'email': email,
                        'mobile': phone,
                        'password': pass,
                        'password_confirmation': confirmPass,
                      },
                    );
                    print('Register API response: ${registerResponse.body}');
                    final registerData = json.decode(registerResponse.body);
                    if (registerData['verifyToken'] != null &&
                        registerData['mobile'] != null) {
                      // Auto verify using the verify API
                      final verifyResponse = await http.post(
                        Uri.parse('${Api.baseUrl}/api/verify'),
                        headers: {'Accept': 'application/json'},
                        body: {
                          'mobile': registerData['mobile'].toString(),
                          'otp': registerData['verifyToken'].toString(),
                        },
                      );
                      print('Auto verify API response: ${verifyResponse.body}');
                      final verifyData = json.decode(verifyResponse.body);
                      if (verifyData['status'] == 'success' ||
                          verifyData['message']
                                  ?.toString()
                                  .toLowerCase()
                                  .contains('success') ==
                              true) {
                        // After verification, log in with email and password
                        tempPassword = pass;
                        final loginResponse = await http.post(
                          Uri.parse(Api.login),
                          headers: {'Accept': 'application/json'},
                          body: {'mobile': phone, 'password': tempPassword},
                        );
                        print(
                          'Login after auto verify API response: ${loginResponse.body}',
                        );
                        final loginData = json.decode(loginResponse.body);
                        if (loginData['status'] == 'success') {
                          final token = loginData['access_token'];
                          final user = QuickTechUserModel.fromJson(
                            loginData['user'],
                          );
                          await QuickTechAuthStorageService.saveToken(token);
                          await QuickTechAuthStorageService.saveUser(user);
                          Get.back();
                          Get.offAllNamed('/mainhome');
                        } else {
                          UIHelper.showNotification(
                            title: 'Login Failed',
                            message:
                                loginData['message'] ??
                                'Login after verification failed',
                          );
                        }
                      } else {
                        UIHelper.showNotification(
                          title: 'Verification Failed',
                          message:
                              verifyData['message'] ??
                              'Auto verification failed',
                        );
                      }
                    } else if (registerData['status'] == 'success') {
                      UIHelper.showNotification(
                        title: 'Registration Success',
                        message: 'Please check your SMS for verification code.',
                      );
                    } else {
                      UIHelper.showNotification(
                        title: 'Registration Failed',
                        message: registerData['message'] ?? 'Unknown error',
                      );
                    }
                  } catch (e) {
                    UIHelper.showNotification(
                      title: 'Error',
                      message: 'Registration failed: ${e.toString()}',
                    );
                  } finally {
                    isLoading(false);
                  }
                },
                child: Text('Register'),
              ),
              SizedBox(height: 8),
              TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  Future<void> logout() async {
    final token = QuickTechAuthStorageService.getToken();

    try {
      if (token != null && token.isNotEmpty) {
        await http.post(
          Uri.parse(Api.logout),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (_) {}

    await QuickTechAuthStorageService.clear();
    QuickTechTemplateStorageService.clearSelectedTemplateId();
    // Remove ALL controllers properly
    //Get.deleteAll(force: true);
    await QuickTechAuthStorageService.clear();
    // Navigate fresh
    Get.offAllNamed('/login');

    // Get.snackbar(
    //   "Logged out",
    //   "Session cleared",
    //   snackPosition: SnackPosition.BOTTOM,
    // );
  }

  TextEditingController phonenumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  // Reactive variables
  var isLoading = false.obs;
  var phoneNumber = ''.obs;
  var password = ''.obs;
  var isPasswordVisible = false.obs;

  // Validation
  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    if (value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> login() async {
    final phone = phonenumberController.text.trim();
    final pass = passwordController.text.trim();
    if (validatePhoneNumber(phone) != null || validatePassword(pass) != null) {
      UIHelper.showNotification(
        title: 'Error',
        message: 'Please fill all fields correctly',
      );
      return;
    }
    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse(Api.login),
        headers: {'Accept': 'application/json'},
        body: {'mobile': phone, 'password': pass},
      );
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final token = data['access_token'];
        final user = QuickTechUserModel.fromJson(data['user']);
        await QuickTechAuthStorageService.saveToken(token);
        await QuickTechAuthStorageService.saveUser(user);
        print('Login successful, Token: $token, User: ${user.toJson()}');
        // Controllers are managed by locator/setUp and route bindings; avoid ad-hoc instantiation here
        Get.offAllNamed('/mainhome');
      } else if (data['verifyToken'] != null && data['mobile'] != null) {
        UIHelper.showNotification(
          title: 'Verification Required',
          message:
              'Please verify your account. A verification code has been sent to your mobile.\nVerification Code: ${data['verifyToken']}',
        );
        Get.to(() => QuickTechLoginVerification(staticMobile: data['mobile']));
      } else {
        UIHelper.showNotification(
          title: 'Login Failed',
          message: data['message'] ?? 'You Have to Sign Up First',
        );
      }
    } catch (e) {
      UIHelper.showNotification(
        title: 'Error',
        message: 'Login failed: ${e.toString()}',
      );
    } finally {
      isLoading(false);
    }
  }

  void togglePasswordVisibility() {
    print("Toggling password visibility: ${!isPasswordVisible.value}");
    isPasswordVisible.toggle();
  }

  Future<bool> onWillPop() async {
    return await showDialog(
          context: Get.context!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Exit'),
              content: Text('Are you sure you want to exit the app?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Get.back(canPop: false);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Get.back(canPop: true);
                    SystemNavigator.pop();
                  },
                  child: Text('Exit'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
