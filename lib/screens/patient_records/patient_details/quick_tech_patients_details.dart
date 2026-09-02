// quick_tech_patients_details.dart
import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/controllers/patient_controller/quick_tech_patient_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/models/patient_model.dart';
import 'package:e_prescription/screens/patient_records/patient_details/widgets/quick_tech_patient_details_widgets.dart';
import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../../responsive.dart';

class QuickTechPatientsDetails extends StatefulWidget {
  final Patient patient;
  const QuickTechPatientsDetails({super.key, required this.patient});

  @override
  State<QuickTechPatientsDetails> createState() =>
      _QuickTechPatientsDetailsState();
}

class _QuickTechPatientsDetailsState extends State<QuickTechPatientsDetails> {
  final QuickTechThemeController themeController =
      locator.get<QuickTechThemeController>();
  final QuickTechPatientController patientController =
      locator.get<QuickTechPatientController>();

  @override
  void initState() {
    super.initState();
    final token = QuickTechAuthStorageService.getToken();
    if (token != null) {
      patientController.fetchPrescriptions(widget.patient.id, token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Obx(() {
      final isDark = !themeController.isDay.value;
      final mainColor = isDark
          ? QuickTechAppColors.darkmaincolor
          : QuickTechAppColors.lightmaincolor;
      final isMale = widget.patient.gender == 'Male';

      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        appBar: _buildAppBar(isDark, mainColor, isDesktop),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 80.w : 16.w,
            vertical: 32.h,
          ),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 320.w,
                      child: _PatientProfileCard(
                        patient: widget.patient,
                        isDark: isDark,
                        mainColor: mainColor,
                        isMale: isMale,
                        isDesktop: isDesktop,
                      ),
                    ),
                    SizedBox(width: 32.w),
                    Expanded(
                      child: _PrescriptionsSection(
                        isDark: isDark,
                        mainColor: mainColor,
                        isDesktop: isDesktop,
                        patientController: patientController,
                        patient: widget.patient,
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PatientProfileCard(
                      patient: widget.patient,
                      isDark: isDark,
                      mainColor: mainColor,
                      isMale: isMale,
                      isDesktop: isDesktop,
                    ),
                    SizedBox(height: 28.h),
                    _PrescriptionsSection(
                      isDark: isDark,
                      mainColor: mainColor,
                      isDesktop: isDesktop,
                      patientController: patientController,
                      patient: widget.patient,
                    ),
                  ],
                ),
        ),
      );
    });
  }

  AppBar _buildAppBar(bool isDark, Color mainColor, bool isDesktop) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF0F172A)),
      ),
      title: Text(
        'Patient Details',
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          fontSize: isDesktop ? 18.sp : 17.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: themeController.toggleTheme,
          icon: Obx(() => Icon(
                themeController.isDay.value
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              )),
        ),
        SizedBox(width: 8.w),
      ],
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
}

// ── Patient Profile Card ──────────────────────────────────────────────────────
class _PatientProfileCard extends StatelessWidget {
  final Patient patient;
  final bool isDark;
  final Color mainColor;
  final bool isMale;
  final bool isDesktop;

  const _PatientProfileCard({
    required this.patient,
    required this.isDark,
    required this.mainColor,
    required this.isMale,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Avatar Header ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 32.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isMale
                    ? [const Color(0xFF1A56DB), const Color(0xFF3B82F6)]
                    : [const Color(0xFFEC4899), const Color(0xFFF472B6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMale
                        ? FontAwesomeIcons.person.data
                        : FontAwesomeIcons.personDress.data,
                    color: Colors.white,
                    size: isDesktop ? 36.sp : 30.sp,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  patient.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 20.sp : 17.sp,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Patient #${patient.id}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: isDesktop ? 12.sp : 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Details ──
          Padding(
            padding: EdgeInsets.all(isDesktop ? 24.w : 18.w),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.person_rounded,
                  label: 'Full Name',
                  value: patient.name,
                  isDark: isDark,
                  mainColor: mainColor,
                  isDesktop: isDesktop,
                ),
                _Divider(isDark: isDark),
                _DetailRow(
                  icon: isMale ? Icons.male_rounded : Icons.female_rounded,
                  label: 'Gender',
                  value: patient.gender,
                  isDark: isDark,
                  mainColor: mainColor,
                  isDesktop: isDesktop,
                ),
                _Divider(isDark: isDark),
                _DetailRow(
                  icon: Icons.cake_rounded,
                  label: 'Age',
                  value: '${patient.age} years',
                  isDark: isDark,
                  mainColor: mainColor,
                  isDesktop: isDesktop,
                ),
                _Divider(isDark: isDark),
                _DetailRow(
                  icon: Icons.badge_rounded,
                  label: 'Patient ID',
                  value: '#${patient.id}',
                  isDark: isDark,
                  mainColor: mainColor,
                  isDesktop: isDesktop,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color mainColor;
  final bool isDesktop;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.mainColor,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: mainColor, size: isDesktop ? 15.sp : 14.sp),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.4)
                      : const Color(0xFF94A3B8),
                  fontSize: isDesktop ? 10.sp : 9.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: isDesktop ? 13.sp : 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : const Color(0xFFF1F5F9),
      height: 1,
      thickness: 1,
    );
  }
}

// ── Prescriptions Section ─────────────────────────────────────────────────────
class _PrescriptionsSection extends StatelessWidget {
  final bool isDark;
  final Color mainColor;
  final bool isDesktop;
  final QuickTechPatientController patientController;
  final Patient patient;

  const _PrescriptionsSection({
    required this.isDark,
    required this.mainColor,
    required this.isDesktop,
    required this.patientController,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
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
              'Assessments & Prescriptions',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: isDesktop ? 18.sp : 16.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        Obx(() {
          if (patientController.isLoading.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40.h),
                child: CircularProgressIndicator(
                    color: mainColor, strokeWidth: 2.5),
              ),
            );
          }

          if (patientController.error.isNotEmpty) {
            return _ErrorState(
                message: patientController.error.value, isDesktop: isDesktop);
          }

          if (patientController.prescriptions.isEmpty) {
            return _NoPrescriptionsState(
                isDark: isDark, mainColor: mainColor, isDesktop: isDesktop);
          }

          return Column(
            children: patientController.prescriptions
                .map((p) => Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: customPrescriptionListItem(
                          context, patient.id, p),
                    ))
                .toList(),
          );
        }),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final bool isDesktop;
  const _ErrorState({required this.message, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: Colors.red, size: isDesktop ? 18.sp : 16.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    color: Colors.red, fontSize: isDesktop ? 13.sp : 12.sp)),
          ),
        ],
      ),
    );
  }
}

class _NoPrescriptionsState extends StatelessWidget {
  final bool isDark;
  final Color mainColor;
  final bool isDesktop;
  const _NoPrescriptionsState(
      {required this.isDark, required this.mainColor, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.description_outlined,
                color: isDark ? Colors.white : Colors.black12,
                size: isDesktop ? 40.sp : 36.sp),
            SizedBox(height: 12.h),
            Text(
              'No prescriptions yet',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : const Color(0xFF94A3B8),
                fontSize: isDesktop ? 14.sp : 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}