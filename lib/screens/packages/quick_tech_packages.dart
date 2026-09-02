import 'dart:io';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/const/const.dart';
import 'package:e_prescription/controllers/package_controller/quick_tech_package_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e_prescription/widgets/quick_tech_custom_drawer.dart';

class QuickTechPackages extends StatefulWidget {
  const QuickTechPackages({super.key});

  @override
  State<QuickTechPackages> createState() => _QuickTechPackagesState();
}

class _QuickTechPackagesState extends State<QuickTechPackages> {
  final controller = locator.get<QuickTechPackageController>();
  late final themeController = locator.get<QuickTechThemeController>();
  Worker? _paymentProofWorker;

  @override
  void initState() {
    super.initState();
    _paymentProofWorker = ever(controller.paymentProofTargetPackageId, (int? id) {
      if (id != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showPaymentProofDialog(id, !themeController.isDay.value);
            controller.paymentProofTargetPackageId.value = null;
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchUserPackage();
      await controller.fetchAllPackages();
    });
  }

  @override
  void dispose() {
    _paymentProofWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = !themeController.isDay.value;
      final mainColor = isDark
          ? QuickTechAppColors.darkmaincolor
          : QuickTechAppColors.lightmaincolor;

      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        appBar: _buildAppBar(isDark, mainColor, context),
        drawer: customDrawer(context),
        body: Responsive(
          mobile: _buildMobileBody(context, isDark, mainColor),
          tablet: _buildTabletBody(context, isDark, mainColor),
          desktop: _buildDesktopBody(context, isDark, mainColor),
        ),
      );
    });
  }

  // ── Mobile Layout ──
  Widget _buildMobileBody(BuildContext context, bool isDark, Color mainColor) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Current Subscription ──
            Obx(() {
              final current = controller.getCurrentSubscribedPackage();
              if (current == null) return const SizedBox.shrink();
              return Column(
                children: [
                  _CurrentPlanCard(
                    package: current,
                    isDark: isDark,
                    mainColor: mainColor,
                    isDesktop: false,
                    controller: controller,
                    context: context,
                  ),
                  SizedBox(height: 28.h),
                ],
              );
            }),

            // ── Section Title ──
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Available Plans',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // ── Package List ──
            Obx(() {
              if (controller.isLoading.value || controller.isLoadingUserPackage.value) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60.h),
                    child: CircularProgressIndicator(color: mainColor, strokeWidth: 2.5),
                  ),
                );
              }

              if (controller.allPackages.isEmpty) {
                return _EmptyState(isDark: isDark, mainColor: mainColor, isDesktop: false);
              }

              return Column(
                children: controller.allPackages.map((pkg) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _PackageCard(
                      package: pkg,
                      isDark: isDark,
                      mainColor: mainColor,
                      isDesktop: false,
                      controller: controller,
                      onSubscribe: () => _handleSubscribe(pkg.id, isDark),
                      context: context,
                    ),
                  );
                }).toList(),
              );
            }),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  // ── Tablet Layout ──
  Widget _buildTabletBody(BuildContext context, bool isDark, Color mainColor) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Current Subscription ──
            Obx(() {
              final current = controller.getCurrentSubscribedPackage();
              if (current == null) return const SizedBox.shrink();
              return Column(
                children: [
                  _CurrentPlanCard(
                    package: current,
                    isDark: isDark,
                    mainColor: mainColor,
                    isDesktop: false,
                    controller: controller,
                    context: context,
                  ),
                  SizedBox(height: 36.h),
                ],
              );
            }),

            // ── Section Title ──
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 26.h,
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Available Plans',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // ── Package List - 2 Column Grid ──
            Obx(() {
              if (controller.isLoading.value || controller.isLoadingUserPackage.value) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60.h),
                    child: CircularProgressIndicator(color: mainColor, strokeWidth: 2.5),
                  ),
                );
              }

              if (controller.allPackages.isEmpty) {
                return _EmptyState(isDark: isDark, mainColor: mainColor, isDesktop: false);
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18.w,
                  mainAxisSpacing: 18.h,
                  childAspectRatio: 0.8,
                ),
                itemCount: controller.allPackages.length,
                itemBuilder: (context, index) {
                  return _PackageCard(
                    package: controller.allPackages[index],
                    isDark: isDark,
                    mainColor: mainColor,
                    isDesktop: false,
                    controller: controller,
                    onSubscribe: () => _handleSubscribe(controller.allPackages[index].id, isDark),
                    context: context,
                  );
                },
              );
            }),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ── Desktop Layout ──
  Widget _buildDesktopBody(BuildContext context, bool isDark, Color mainColor) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 80.w, vertical: 32.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Page Header ──
            _PageHeader(isDark: isDark, mainColor: mainColor),
            SizedBox(height: 36.h),

            // ── Current Subscription ──
            Obx(() {
              final current = controller.getCurrentSubscribedPackage();
              if (current == null) return const SizedBox.shrink();
              return Column(
                children: [
                  _CurrentPlanCard(
                    package: current,
                    isDark: isDark,
                    mainColor: mainColor,
                    isDesktop: true,
                    controller: controller,
                    context: context,
                  ),
                  SizedBox(height: 40.h),
                ],
              );
            }),

            // ── Section Title ──
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 26.h,
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Available Plans',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // ── Package List - 3 Column Grid ──
            Obx(() {
              if (controller.isLoading.value || controller.isLoadingUserPackage.value) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60.h),
                    child: CircularProgressIndicator(color: mainColor, strokeWidth: 2.5),
                  ),
                );
              }

              if (controller.allPackages.isEmpty) {
                return _EmptyState(isDark: isDark, mainColor: mainColor, isDesktop: true);
              }

              return _DesktopPackageGrid(
                packages: controller.allPackages,
                isDark: isDark,
                mainColor: mainColor,
                isDesktop: true,
                controller: controller,
                onSubscribe: (id) => _handleSubscribe(id, isDark),
                context: context,
              );
            }),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isDark, Color mainColor, BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (ctx) => IconButton(
          onPressed: () => Scaffold.of(ctx).openDrawer(),
          icon: Icon(
            Icons.menu_rounded,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
      title: Text(
        'Subscription Plans',
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          fontSize: isDesktop ? 18.sp : 17.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFE2E8F0),
        ),
      ),
    );
  }

  void _handleSubscribe(int id, bool isDark) {
    if (controller.userPackage.value?.packageOrder.paymentMessage != null) {
      QuickTechSnackbar.warning(controller.userPackage.value!.packageOrder.paymentMessage!, title: 'Payment Status');
    } else {
      _showPaymentProofDialog(id, isDark);
    }
  }

  void _showPaymentProofDialog(int packageId, bool isDark) {
    final bkashCtrl = TextEditingController();
    final txnCtrl = TextEditingController();
    XFile? pickedImage;
    final formKey = GlobalKey<FormState>();
    final mainColor = isDark
        ? QuickTechAppColors.darkmaincolor
        : QuickTechAppColors.lightmaincolor;

    Get.dialog(
      barrierDismissible: false,
      StatefulBuilder(
        builder: (context, setDialogState) {
         
          final isTablet = Responsive.isTablet(context);
          final isDesktop = Responsive.isDesktop(context);
          
          // Responsive dialog sizing
          double horizontalPadding;
          double dialogWidth;
          if (isDesktop) {
            horizontalPadding = 400.w;
            dialogWidth = 600.w;
          } else if (isTablet) {
            horizontalPadding = 60.w;
            dialogWidth = 500.w;
          } else {
            horizontalPadding = 16.w;
            dialogWidth = double.infinity;
          }
          
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 24.h,
            ),
            child: Container(
              width: isDesktop ? dialogWidth : null,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header ──
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: isDesktop ? 32.h : 28.h,
                          horizontal: isDesktop ? 32.w : 28.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [mainColor, mainColor.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isDesktop ? 16.w : 14.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.payment_rounded,
                                color: Colors.white,
                                size: isDesktop ? 32.sp : 30.sp),
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            'Complete Your Payment',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isDesktop ? 18.sp : 16.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Submit your bKash payment details below',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: isDesktop ? 12.sp : 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Form ──
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isDesktop ? 32.w : 28.w),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Error banner
                              Obx(() => controller.paymentProofError.value.isEmpty
                                  ? const SizedBox.shrink()
                                  : _ErrorBanner(
                                      message: controller.paymentProofError.value,
                                      isDesktop: isDesktop,
                                    )),

                              // bKash Number
                              _FieldLabel(
                                  label: 'bKash Number',
                                  required: true,
                                  isDark: isDark,
                                  isDesktop: isDesktop),
                              SizedBox(height: 8.h),
                              _StyledField(
                                controller: bkashCtrl,
                                hint: '01XXXXXXXXX',
                                icon: Icons.phone_android_rounded,
                                iconColor: const Color(0xFFE2136E),
                                isDark: isDark,
                                mainColor: mainColor,
                                isDesktop: isDesktop,
                                keyboardType: TextInputType.phone,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'bKash number is required';
                                  if (v.trim().length < 11)
                                    return 'Enter a valid number';
                                  return null;
                                },
                              ),
                              SizedBox(height: 18.h),

                              // Transaction ID
                              _FieldLabel(
                                  label: 'Transaction ID',
                                  required: true,
                                  isDark: isDark,
                                  isDesktop: isDesktop),
                              SizedBox(height: 8.h),
                              _StyledField(
                                controller: txnCtrl,
                                hint: 'e.g. 8N7HRJ2ETK',
                                icon: Icons.receipt_long_rounded,
                                iconColor: mainColor,
                                isDark: isDark,
                                mainColor: mainColor,
                                isDesktop: isDesktop,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'Transaction ID is required';
                                  return null;
                                },
                              ),
                              SizedBox(height: 18.h),

                              // Screenshot
                              _FieldLabel(
                                  label: 'Payment Screenshot',
                                  required: false,
                                  isDark: isDark,
                                  isDesktop: isDesktop),
                              SizedBox(height: 8.h),
                              _ImagePickerArea(
                                pickedImage: pickedImage,
                                isDark: isDark,
                                mainColor: mainColor,
                                isDesktop: isDesktop,
                                onPick: () async {
                                  final img = await ImagePicker()
                                      .pickImage(source: ImageSource.gallery);
                                  if (img != null) {
                                    setDialogState(() => pickedImage = img);
                                  }
                                },
                                onRemove: () =>
                                    setDialogState(() => pickedImage = null),
                              ),
                              SizedBox(height: 28.h),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: _OutlineBtn(
                                      label: 'Cancel',
                                      mainColor: mainColor,
                                      isDark: isDark,
                                      isDesktop: isDesktop,
                                      onTap: () => Get.back(),
                                    ),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    flex: 2,
                                    child: Obx(() => _SubmitBtn(
                                          mainColor: mainColor,
                                          isDesktop: isDesktop,
                                          isLoading: controller.isSubmittingProof.value,
                                          onTap: () async {
                                            if (!formKey.currentState!.validate()) return;
                                            await controller.subscribeToPackage(
                                              packageId,
                                              bkashNumber: bkashCtrl.text,
                                              transactionId: txnCtrl.text,
                                              screenshotPath: pickedImage?.path,
                                            );
                                            if (mounted &&
                                                controller.paymentProofError.value.isEmpty) {
                                              Get.back();
                                              Future.delayed(
                                                  const Duration(milliseconds: 100), () {
                                                QuickTechSnackbar.success('Awaiting admin verification.', title: 'Payment Submitted!');
                                              });
                                            }
                                          },
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Page Header (Desktop only) ────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  final bool isDark;
  final Color mainColor;
  const _PageHeader({required this.isDark, required this.mainColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: mainColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(Icons.workspace_premium_rounded, color: mainColor, size: 28.sp),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subscription Plans',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Choose a plan that fits your practice',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : const Color(0xFF64748B),
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Current Plan Card ─────────────────────────────────────────────────────────
class _CurrentPlanCard extends StatelessWidget {
  final dynamic package;
  final bool isDark;
  final Color mainColor;
  final bool isDesktop;
  final dynamic controller;
  final BuildContext context;

  const _CurrentPlanCard({
    required this.package,
    required this.isDark,
    required this.mainColor,
    required this.isDesktop,
    required this.controller,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 32.w : 20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mainColor, mainColor.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: mainColor.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: _PlanInfo(package: package, isDesktop: isDesktop)),
                SizedBox(width: 40.w),
                _PlanStats(controller: controller, isDesktop: isDesktop),
                if (controller.userPackage.value?.packageOrder.paymentMessage != null)
                  _PaymentMsg(controller: controller, isDesktop: isDesktop),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PlanInfo(package: package, isDesktop: isDesktop),
                SizedBox(height: 20.h),
                _PlanStats(controller: controller, isDesktop: isDesktop),
                if (controller.userPackage.value?.packageOrder.paymentMessage != null)
                  _PaymentMsg(controller: controller, isDesktop: isDesktop),
              ],
            ),
    );
  }
}

class _PlanInfo extends StatelessWidget {
  final dynamic package;
  final bool isDesktop;
  const _PlanInfo({required this.package, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded, color: Colors.white, size: 12.sp),
                  SizedBox(width: 5.w),
                  Text('Active Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 11.sp : 10.sp,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          package.type ?? 'Premium',
          style: TextStyle(
            color: Colors.white,
            fontSize: isDesktop ? 28.sp : 22.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          package.title ?? 'Subscription Plan',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: isDesktop ? 13.sp : 12.sp,
          ),
        ),
      ],
    );
  }
}

class _PlanStats extends StatelessWidget {
  final dynamic controller;
  final bool isDesktop;
  const _PlanStats({required this.controller, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    // On desktop: show horizontally, on mobile/tablet: show vertically
    if (isDesktop) {
      return Row(
        children: [
          _StatChip(
            label: 'Prescriptions Left',
            value: controller.getRemainingPrescriptions().toString(),
            icon: Icons.description_rounded,
            isDesktop: isDesktop,
          ),
          SizedBox(width: 14.w),
          _StatChip(
            label: 'Time Remaining',
            value: controller.getTimeRemaining(),
            icon: Icons.timer_rounded,
            isDesktop: isDesktop,
          ),
        ],
      );
    } else {
      // Mobile/Tablet: stack vertically
      return Column(
        children: [
          _StatChip(
            label: 'Prescriptions Left',
            value: controller.getRemainingPrescriptions().toString(),
            icon: Icons.description_rounded,
            isDesktop: isDesktop,
          ),
          SizedBox(height: 10.h),
          _StatChip(
            label: 'Time Remaining',
            value: controller.getTimeRemaining(),
            icon: Icons.timer_rounded,
            isDesktop: isDesktop,
          ),
        ],
      );
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDesktop;
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 16.w : 12.w, vertical: isDesktop ? 14.h : 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: isDesktop ? 18.sp : 16.sp),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 16.sp : 13.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: isDesktop ? 10.sp : 9.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMsg extends StatelessWidget {
  final dynamic controller;
  final bool isDesktop;
  const _PaymentMsg({required this.controller, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Obx(() => Text(
            controller.userPackage.value?.packageOrder.paymentMessage ?? '',
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 13.sp : 11.sp,
              fontWeight: FontWeight.w600,
            ),
          )),
    );
  }
}

// ── Desktop Grid ──────────────────────────────────────────────────────────────
class _DesktopPackageGrid extends StatelessWidget {
  final List packages;
  final bool isDark;
  final Color mainColor;
  final bool isDesktop;
  final dynamic controller;
  final Function(int) onSubscribe;
  final BuildContext context;

  const _DesktopPackageGrid({
    required this.packages,
    required this.isDark,
    required this.mainColor,
    required this.isDesktop,
    required this.controller,
    required this.onSubscribe,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: packages.length >= 3 ? 3 : packages.length,
        crossAxisSpacing: 24.w,
        mainAxisSpacing: 24.h,
        childAspectRatio: 1.15,
      ),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        return _PackageCard(
          package: packages[index],
          isDark: isDark,
          mainColor: mainColor,
          isDesktop: true,
          controller: controller,
          onSubscribe: () => onSubscribe(packages[index].id),
          context: context,
        );
      },
    );
  }
}

// ── Package Card ──────────────────────────────────────────────────────────────
class _PackageCard extends StatefulWidget {
  final dynamic package;
  final bool isDark;
  final Color mainColor;
  final bool isDesktop;
  final dynamic controller;
  final VoidCallback onSubscribe;
  final BuildContext context;

  const _PackageCard({
    required this.package,
    required this.isDark,
    required this.mainColor,
    required this.isDesktop,
    required this.controller,
    required this.onSubscribe,
    required this.context,
  });

  @override
  State<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<_PackageCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final pkg = widget.package;
    final isSubscribed = widget.controller.isPackageSubscribed(pkg.id);
    final isPending = widget.controller.hasPendingPayment.value &&
        widget.controller.pendingPaymentPackageId.value == pkg.id;
    final isFree = pkg.price == '0.00';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSubscribed
                ? widget.mainColor
                : isPending
                    ? Colors.orange
                    : (_hovered
                        ? widget.mainColor.withValues(alpha: 0.4)
                        : Colors.transparent),
            width: isSubscribed || isPending ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSubscribed
                  ? widget.mainColor.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: _hovered ? 0.12 : 0.06),
              blurRadius: _hovered ? 24 : 12,
              offset: Offset(0, _hovered ? 10 : 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(widget.isDesktop ? 28.w : 20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row ──
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: widget.mainColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      isFree ? Icons.card_giftcard_rounded : Icons.workspace_premium_rounded,
                      color: widget.mainColor,
                      size: widget.isDesktop ? 20.sp : 18.sp,
                    ),
                  ),
                  const Spacer(),
                  if (isSubscribed)
                    _Badge(label: 'Active', color: widget.mainColor)
                  else if (isPending)
                    _Badge(label: 'Pending', color: Colors.orange),
                ],
              ),
              SizedBox(height: 18.h),

              // ── Plan Name ──
              Text(
                pkg.type,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: widget.isDesktop ? 20.sp : 18.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                pkg.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : const Color(0xFF64748B),
                  fontSize: widget.isDesktop ? 12.sp : 11.sp,
                ),
              ),
              SizedBox(height: 20.h),

              // ── Price ──
              Text(
                isFree ? 'Free' : '৳${pkg.price}',
                style: TextStyle(
                  color: widget.mainColor,
                  fontSize: widget.isDesktop ? 28.sp : 24.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 18.h),

              // ── Details ──
              _DetailRow(
                icon: Icons.description_rounded,
                label: '${pkg.maximumPrescription} Prescriptions',
                isDark: widget.isDark,
                mainColor: widget.mainColor,
                isDesktop: widget.isDesktop,
              ),
              SizedBox(height: 10.h),
              _DetailRow(
                icon: Icons.calendar_month_rounded,
                label: '${pkg.dayDuration} Days Duration',
                isDark: widget.isDark,
                mainColor: widget.mainColor,
                isDesktop: widget.isDesktop,
              ),
              SizedBox(height: 20.h),

              // ── CTA ──
              if (isSubscribed)
                _StatusBox(
                  label: 'Currently Subscribed',
                  color: widget.mainColor,
                  isDesktop: widget.isDesktop,
                )
              else if (isPending)
                _PendingBox(isDark: widget.isDark, isDesktop: widget.isDesktop)
              else
                Obx(() => _SubscribeBtn(
                      mainColor: widget.mainColor,
                      isDesktop: widget.isDesktop,
                      isLoading: widget.controller.isSubscribing.value,
                      onTap: widget.onSubscribe,
                    )),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color mainColor;
  final bool isDesktop;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.mainColor,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: mainColor, size: isDesktop ? 15.sp : 14.sp),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.65)
                : const Color(0xFF475569),
            fontSize: isDesktop ? 12.sp : 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatusBox extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDesktop;
  const _StatusBox({required this.label, required this.color, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: color, size: isDesktop ? 16.sp : 14.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: isDesktop ? 13.sp : 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingBox extends StatelessWidget {
  final bool isDark;
  final bool isDesktop;
  const _PendingBox({required this.isDark, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top_rounded, color: Colors.orange, size: isDesktop ? 15.sp : 14.sp),
              SizedBox(width: 6.w),
              Text('Payment Pending',
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: isDesktop ? 13.sp : 12.sp,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Awaiting admin approval',
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.45) : const Color(0xFF94A3B8),
              fontSize: isDesktop ? 11.sp : 10.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SubscribeBtn extends StatefulWidget {
  final Color mainColor;
  final bool isDesktop;
  final bool isLoading;
  final VoidCallback onTap;
  const _SubscribeBtn({
    required this.mainColor,
    required this.isDesktop,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_SubscribeBtn> createState() => _SubscribeBtnState();
}

class _SubscribeBtnState extends State<_SubscribeBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: widget.isLoading
                ? widget.mainColor.withValues(alpha: 0.6)
                : (_hovered
                    ? widget.mainColor.withValues(alpha: 0.85)
                    : widget.mainColor),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: widget.mainColor.withValues(alpha: _hovered ? 0.4 : 0.2),
                blurRadius: _hovered ? 16 : 8,
                offset: Offset(0, _hovered ? 6 : 3),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    height: 18.h,
                    width: 18.w,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Subscribe Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.isDesktop ? 14.sp : 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: widget.isDesktop ? 15.sp : 14.sp),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final Color mainColor;
  final bool isDesktop;
  const _EmptyState({required this.isDark, required this.mainColor, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80.h),
        child: Column(
          children: [
            Icon(Icons.inventory_2_rounded,
                size: isDesktop ? 60.sp : 56.sp,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.1)),
            SizedBox(height: 16.h),
            Text(
              'No plans available',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : const Color(0xFF94A3B8),
                fontSize: isDesktop ? 15.sp : 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dialog Helpers ────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  final bool isDark;
  final bool isDesktop;
  const _FieldLabel({
    required this.label,
    required this.required,
    required this.isDark,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: isDark ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF334155),
          fontSize: isDesktop ? 13.sp : 12.sp,
          fontWeight: FontWeight.w600,
        ),
        children: required
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: isDesktop ? 13.sp : 12.sp,
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final Color mainColor;
  final bool isDesktop;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _StyledField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.mainColor,
    required this.isDesktop,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF0F172A),
        fontSize: isDesktop ? 14.sp : 13.sp,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white30 : Colors.black26,
          fontSize: isDesktop ? 13.sp : 12.sp,
        ),
        prefixIcon: Icon(icon, color: iconColor, size: isDesktop ? 20.sp : 18.sp),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: mainColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
      ),
      validator: validator,
    );
  }
}

class _ImagePickerArea extends StatelessWidget {
  final XFile? pickedImage;
  final bool isDark;
  final Color mainColor;
  final bool isDesktop;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _ImagePickerArea({
    required this.pickedImage,
    required this.isDark,
    required this.mainColor,
    required this.isDesktop,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: pickedImage != null ? null : 80.h,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: pickedImage != null
                ? mainColor.withValues(alpha: 0.5)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE2E8F0)),
            width: 1.5,
          ),
        ),
        child: pickedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11.r),
                    child: kIsWeb
                        ? FutureBuilder<List<int>>(
                            future: pickedImage!.readAsBytes(),
                            builder: (ctx, snap) {
                              if (snap.hasData) {
                                return Image.memory(
                                  Uint8List.fromList(snap.data!),
                                  width: double.infinity,
                                  height: 130.h,
                                  fit: BoxFit.cover,
                                );
                              }
                              return SizedBox(
                                height: 130.h,
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: mainColor, strokeWidth: 2),
                                ),
                              );
                            },
                          )
                        : Image.file(
                            File(pickedImage!.path),
                            width: double.infinity,
                            height: 130.h,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: const BoxDecoration(
                            color: Colors.black54, shape: BoxShape.circle),
                        child: Icon(Icons.close_rounded,
                            color: Colors.white, size: 13.sp),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_rounded,
                      color: mainColor.withValues(alpha: 0.5),
                      size: isDesktop ? 24.sp : 22.sp),
                  SizedBox(height: 5.h),
                  Text(
                    'Tap to upload screenshot',
                    style: TextStyle(
                      color: isDark ? Colors.white30 : Colors.black26,
                      fontSize: isDesktop ? 12.sp : 11.sp,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool isDesktop;
  const _ErrorBanner({required this.message, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.red, size: isDesktop ? 16.sp : 15.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: isDesktop ? 12.sp : 11.sp)),
          ),
        ],
      ),
    );
  }
}

class _OutlineBtn extends StatefulWidget {
  final String label;
  final Color mainColor;
  final bool isDark;
  final bool isDesktop;
  final VoidCallback onTap;
  const _OutlineBtn({
    required this.label,
    required this.mainColor,
    required this.isDark,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  State<_OutlineBtn> createState() => _OutlineBtnState();
}

class _OutlineBtnState extends State<_OutlineBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.mainColor.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: widget.mainColor.withValues(alpha: _hovered ? 0.8 : 0.5),
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.mainColor,
                fontSize: widget.isDesktop ? 14.sp : 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitBtn extends StatefulWidget {
  final Color mainColor;
  final bool isDesktop;
  final bool isLoading;
  final VoidCallback onTap;
  const _SubmitBtn({
    required this.mainColor,
    required this.isDesktop,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_SubmitBtn> createState() => _SubmitBtnState();
}

class _SubmitBtnState extends State<_SubmitBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            color: widget.isLoading
                ? widget.mainColor.withValues(alpha: 0.6)
                : (_hovered
                    ? widget.mainColor.withValues(alpha: 0.85)
                    : widget.mainColor),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: widget.mainColor.withValues(alpha: _hovered ? 0.4 : 0.2),
                blurRadius: _hovered ? 14 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    height: 18.h,
                    width: 18.w,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'Submit Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.isDesktop ? 14.sp : 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}