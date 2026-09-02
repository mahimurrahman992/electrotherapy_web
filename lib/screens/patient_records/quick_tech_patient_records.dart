// quick_tech_patient_records.dart
import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';

import 'package:e_prescription/controllers/patient_controller/quick_tech_patient_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/screens/patient_records/widgets/quick_tech_patient_card.dart';
import 'package:e_prescription/widgets/quick_tech_custom_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../responsive.dart';

class QuickTechPatientRecords extends StatefulWidget {
  final bool isAppBarVisible;
  const QuickTechPatientRecords({super.key, required this.isAppBarVisible});

  @override
  State<QuickTechPatientRecords> createState() => _QuickTechPatientRecordsState();
}

class _QuickTechPatientRecordsState extends State<QuickTechPatientRecords> {
  final QuickTechPatientController patientController =
      locator.get<QuickTechPatientController>();
  final QuickTechThemeController themeController =
      locator.get<QuickTechThemeController>();

  @override
  void initState() {
    super.initState();
    patientController.fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Obx(() {
      final isDark = !themeController.isDay.value;
      final mainColor = isDark
          ? QuickTechAppColors.darkmaincolor
          : QuickTechAppColors.lightmaincolor;

      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        appBar: widget.isAppBarVisible
            ? _buildAppBar(isDark, mainColor, isDesktop)
            : null,
        body: Column(
          children: [
            // ── Header Banner ──
            _HeaderBanner(
              isDark: isDark,
              mainColor: mainColor,
              isDesktop: isDesktop,
              patientController: patientController,
            ),

            // ── Search Bar ──
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40.w : 16.w,
                vertical: 16.h,
              ),
              child: _SearchBar(
                isDark: isDark,
                mainColor: mainColor,
                isDesktop: isDesktop,
                controller: patientController.searchPatientController,
                onChanged: patientController.searchPatients,
              ),
            ),

            // ── List ──
            Expanded(
              child: Obx(() {
                if (patientController.isPatientsLoading.value) {
                  return const Center(child: CustomSpinner());
                }

                if (patientController.patients.isEmpty) {
                  return _EmptyState(isDark: isDark, mainColor: mainColor, isDesktop: isDesktop);
                }

                return isDesktop
                    ? _DesktopPatientGrid(
                        patients: patientController.patients,
                        isDark: isDark,
                        mainColor: mainColor,
                        patientController: patientController,
                      )
                    : _MobilePatientList(
                        patients: patientController.patients,
                        isDark: isDark,
                        patientController: patientController,
                      );
              }),
            ),
          ],
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
        icon: Icon(
          Icons.arrow_back_rounded,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
      ),
      title: Text(
        'Patient Records',
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
                themeController.isDay.value ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
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

// ── Header Banner ─────────────────────────────────────────────────────────────
class _HeaderBanner extends StatelessWidget {
  final bool isDark;
  final Color mainColor;
  final bool isDesktop;
  final QuickTechPatientController patientController;

  const _HeaderBanner({
    required this.isDark,
    required this.mainColor,
    required this.isDesktop,
    required this.patientController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40.w : 16.w,
        vertical: isDesktop ? 28.h : 20.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.people_alt_rounded,
                color: mainColor, size: isDesktop ? 26.sp : 22.sp),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient Records',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: isDesktop ? 22.sp : 18.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 3.h),
              Obx(() => Text(
                    '${patientController.patients.length} patients found',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.45)
                          : const Color(0xFF94A3B8),
                      fontSize: isDesktop ? 12.sp : 11.sp,
                    ),
                  )),
            ],
          ),
          const Spacer(),
          if (isDesktop)
            _AddPatientBtn(mainColor: mainColor, isDesktop: isDesktop),
        ],
      ),
    );
  }
}

class _AddPatientBtn extends StatefulWidget {
  final Color mainColor;
  final bool isDesktop;
  const _AddPatientBtn({required this.mainColor, required this.isDesktop});

  @override
  State<_AddPatientBtn> createState() => _AddPatientBtnState();
}

class _AddPatientBtnState extends State<_AddPatientBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Get.toNamed('/addassessment'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.mainColor.withValues(alpha: 0.85)
                : widget.mainColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: widget.mainColor.withValues(alpha: _hovered ? 0.4 : 0.2),
                blurRadius: _hovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_add_rounded,
                  color: Colors.white, size: widget.isDesktop ? 16.sp : 14.sp),
              SizedBox(width: 8.w),
              Text(
                'Add Patient',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.isDesktop ? 13.sp : 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Search Bar ────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final bool isDark;
  final Color mainColor;
  final bool isDesktop;
  final TextEditingController controller;
  final Function(String) onChanged;

  const _SearchBar({
    required this.isDark,
    required this.mainColor,
    required this.isDesktop,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          fontSize: isDesktop ? 14.sp : 13.sp,
        ),
        decoration: InputDecoration(
          hintText: 'Search patients by name, ID...',
          hintStyle: TextStyle(
            color: isDark ? Colors.white30 : Colors.black26,
            fontSize: isDesktop ? 13.sp : 12.sp,
          ),
          prefixIcon: Icon(Icons.search_rounded,
              color: mainColor, size: isDesktop ? 20.sp : 18.sp),
          suffixIcon: Icon(Icons.tune_rounded,
              color: isDark ? Colors.white30 : Colors.black26,
              size: isDesktop ? 18.sp : 16.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: isDesktop ? 16.h : 14.h,
            horizontal: 16.w,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ── Desktop Grid ──────────────────────────────────────────────────────────────
class _DesktopPatientGrid extends StatelessWidget {
  final List patients;
  final bool isDark;
  final Color mainColor;
  final QuickTechPatientController patientController;

  const _DesktopPatientGrid({
    required this.patients,
    required this.isDark,
    required this.mainColor,
    required this.patientController,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 3.8,
      ),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        return Dismissible(
          key: Key(patient.id.toString()),
          direction: DismissDirection.endToStart,
          background: _DeleteBg(),
          onDismissed: (_) async {
            final ok = await patientController.deletePatient(patient.id);
            if (!ok) {
              patientController.patients.insert(index, patient);
              QuickTechSnackbar.error('Failed to delete patient');
            }
          },
          child: customPatientCard(patient: patient),
        );
      },
    );
  }
}

// ── Mobile List ───────────────────────────────────────────────────────────────
class _MobilePatientList extends StatelessWidget {
  final List patients;
  final bool isDark;
  final QuickTechPatientController patientController;

  const _MobilePatientList({
    required this.patients,
    required this.isDark,
    required this.patientController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      physics: const BouncingScrollPhysics(),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        return Dismissible(
          key: Key(patient.id.toString()),
          direction: DismissDirection.endToStart,
          background: _DeleteBg(),
          onDismissed: (_) async {
            final ok = await patientController.deletePatient(patient.id);
            if (!ok) {
              patientController.patients.insert(index, patient);
              QuickTechSnackbar.error('Failed to delete patient');
            }
          },
          child: customPatientCard(patient: patient),
        );
      },
    );
  }
}

class _DeleteBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(16.r),
      ),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(Icons.delete_rounded, color: Colors.white, size: 20.sp),
          SizedBox(width: 8.w),
          Text('Delete',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp)),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final Color mainColor;
  final bool isDesktop;
  const _EmptyState(
      {required this.isDark, required this.mainColor, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_search_rounded,
                color: mainColor, size: isDesktop ? 48.sp : 40.sp),
          ),
          SizedBox(height: 20.h),
          Text(
            'No patients found',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: isDesktop ? 18.sp : 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your search or add a new patient',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : const Color(0xFF94A3B8),
              fontSize: isDesktop ? 13.sp : 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}