
import 'dart:convert';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';

import 'package:e_prescription/models/package_model.dart';
import 'package:e_prescription/services/package_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class QuickTechPackageController extends GetxController {
  final PackageService _packageService = PackageService();
  final _storage = GetStorage();

  static const String _packageCacheKey = 'cached_user_package';
  static const String _pendingPaymentKey = 'has_pending_payment';
  static const String _pendingPackageIdKey = 'pending_payment_package_id';

  // State variables
  final RxBool isLoading = false.obs;
  final RxBool isLoadingUserPackage = false.obs;
  final RxBool isSubscribing = false.obs;
  final RxBool isSubmittingProof = false.obs;

  final RxList<PackageModel> allPackages = <PackageModel>[].obs;
  final Rx<UserPackageResponse?> userPackage = Rx<UserPackageResponse?>(null);
  final RxString errorMessage = ''.obs;
  final RxString paymentProofError = ''.obs;

  // Pending payment state (persisted across launches)
  final RxBool hasPendingPayment = false.obs;
  final RxInt pendingPaymentPackageId = 0.obs;

  // Non-null value triggers payment proof dialog in the screen
  final Rxn<int> paymentProofTargetPackageId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    _loadCached(); // instant display from cache (sync, no block)
    // Delay data fetch to avoid blocking app startup
    Future.delayed(const Duration(milliseconds: 800), () {
      _initData(); // background refresh (async, non-blocking)
    });
  }
Future<void> _initData() async {
  await fetchUserPackage(); // আগে user package
  await fetchAllPackages(); // পরে all packages
}
  /// Load cached user package and pending state for immediate display
  void _loadCached() {
    try {
      final raw = _storage.read<String>(_packageCacheKey);
      if (raw != null) {
        userPackage.value = UserPackageResponse.fromJson(jsonDecode(raw));
      }
    } catch (_) {}
    hasPendingPayment.value = _storage.read<bool>(_pendingPaymentKey) ?? false;
    pendingPaymentPackageId.value =
        _storage.read<int>(_pendingPackageIdKey) ?? 0;
  }

  // Fetch all available packages
  Future<void> fetchAllPackages() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final response = await _packageService.getAllPackages();
      allPackages.value = response.packages;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      QuickTechSnackbar.error(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch user's current package
  Future<void> fetchUserPackage() async {
    try {
      isLoadingUserPackage.value = true;
      final response = await _packageService.getUserPackage();
      userPackage.value = response;
      // Persist for instant display on next launch
      _storage.write(_packageCacheKey, jsonEncode(response.toJson()));
      // If admin approved the pending package, clear pending state
      if (hasPendingPayment.value &&
          pendingPaymentPackageId.value == response.packageOrder.packageId) {
        hasPendingPayment.value = false;
        pendingPaymentPackageId.value = 0;
        _storage.remove(_pendingPaymentKey);
        _storage.remove(_pendingPackageIdKey);
      }
    } catch (_) {
      // Silent — keep cached value displayed
    } finally {
      isLoadingUserPackage.value = false;
    }
  }

  // Subscribe to a package (optionally with payment proof)
  Future<void> subscribeToPackage(
    int packageId, {
    String? bkashNumber,
    String? transactionId,
    String? screenshotPath,
  }) async {
    try {
      isSubscribing.value = true;
      errorMessage.value = '';
      paymentProofError.value = ''; // Clear previous errors when starting new submit
      

      
      final response = await _packageService.subscribePackage(
        packageId,
        bkashNumber: bkashNumber,
        transactionId: transactionId,
        screenshotPath: screenshotPath,
      );
      print('✅ Subscribe successful');

      // Update user package info
      userPackage.value = UserPackageResponse(
        message: response.message,
        packageOrder: response.packageOrder,
        templates: [],
        timeRemain: '',
        prescriptionRemain: response.packageOrder.totalPrescription,
      );

      await fetchUserPackage();
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = msg;
      paymentProofError.value = msg; // Set error to display in dialog
      
      print('⚠️ Subscribe error detected: $msg');
      
      // Check if the error is "Previous Payment Not Confirmed" → show payment proof dialog
      if (msg.contains('Previous Payment') || msg.contains('Not Confirmed')) {
        print('🟠 Detected pending payment error - showing payment proof dialog');
        paymentProofTargetPackageId.value = packageId;
      } else {
        // For other errors, show snackbar
        print('🔴 Showing error snackbar');
        QuickTechSnackbar.error(msg);
      }
    } finally {
      isSubscribing.value = false;
    }
  }



  // Check if a package is already subscribed
  bool isPackageSubscribed(int packageId) {
    return userPackage.value?.packageOrder.packageId == packageId;
  }

  // Get current subscribed package
  PackageModel? getCurrentSubscribedPackage() {
    return userPackage.value?.packageOrder.package;
  }

  // Get remaining prescriptions
  String getRemainingPrescriptions() {
    return userPackage.value?.prescriptionRemain.toString() ?? 0.toString();
  }

  // Get time remaining
  String getTimeRemaining() {
    return userPackage.value?.timeRemain ?? 'N/A';
  }
}