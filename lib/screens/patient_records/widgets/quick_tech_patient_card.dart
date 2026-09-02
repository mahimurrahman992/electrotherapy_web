// quick_tech_patient_card.dart
import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/models/patient_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../responsive.dart';

Widget customPatientCard({required Patient patient}) {
  final themeController = locator.get<QuickTechThemeController>();

  return Obx(() {
    final isDark = !themeController.isDay.value;
    final mainColor =
        isDark
            ? QuickTechAppColors.darkmaincolor
            : QuickTechAppColors.lightmaincolor;
    final isMale = patient.gender == 'Male';

    return _PatientCardWidget(
      patient: patient,
      isDark: isDark,
      mainColor: mainColor,
      isMale: isMale,
    );
  });
}

class _PatientCardWidget extends StatefulWidget {
  final Patient patient;
  final bool isDark;
  final Color mainColor;
  final bool isMale;

  const _PatientCardWidget({
    required this.patient,
    required this.isDark,
    required this.mainColor,
    required this.isMale,
  });

  @override
  State<_PatientCardWidget> createState() => _PatientCardWidgetState();
}

class _PatientCardWidgetState extends State<_PatientCardWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Get.toNamed('/patientdetails', arguments: widget.patient),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: EdgeInsets.only(bottom: isDesktop ? 0 : 12.h),
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color:
                  _hovered
                      ? widget.mainColor.withValues(alpha: 0.4)
                      : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.1 : 0.05),
                blurRadius: _hovered ? 20 : 8,
                offset: Offset(0, _hovered ? 8 : 3),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 16.w : 14.w),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: isDesktop ? 48.w : 46.w,
                  height: isDesktop ? 48.w : 46.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          widget.isMale
                              ? [
                                const Color(0xFF1A56DB),
                                const Color(0xFF3B82F6),
                              ]
                              : [
                                const Color(0xFFEC4899),
                                const Color(0xFFF472B6),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    widget.isMale
                        ? FontAwesomeIcons.person.data
                        : FontAwesomeIcons.personDress.data,
                    color: Colors.white,
                    size: isDesktop ? 18.sp : 16.sp,
                  ),
                ),
                SizedBox(width: 14.w),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.patient.name,
                        style: TextStyle(
                          color:
                              widget.isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                          fontSize: isDesktop ? 14.sp : 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          _InfoChip(
                            label: widget.patient.gender,
                            icon:
                                widget.isMale
                                    ? Icons.male_rounded
                                    : Icons.female_rounded,
                            color:
                                widget.isMale
                                    ? const Color(0xFF1A56DB)
                                    : const Color(0xFFEC4899),
                            isDark: widget.isDark,
                            isDesktop: isDesktop,
                          ),
                          SizedBox(width: 6.w),
                          _InfoChip(
                            label: '${widget.patient.age}y',
                            icon: Icons.cake_rounded,
                            color: const Color(0xFF0EA5E9),
                            isDark: widget.isDark,
                            isDesktop: isDesktop,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Right meta
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: widget.mainColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '#${widget.patient.id}',
                        style: TextStyle(
                          color: widget.mainColor,
                          fontSize: isDesktop ? 11.sp : 10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      widget.patient.date.toString().split(' ')[0],
                      style: TextStyle(
                        color:
                            widget.isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : const Color(0xFF94A3B8),
                        fontSize: isDesktop ? 10.sp : 9.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: widget.isDark ? Colors.white30 : Colors.black26,
                      size: isDesktop ? 12.sp : 11.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  final bool isDesktop;

  const _InfoChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isDesktop ? 10.sp : 9.sp),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isDesktop ? 10.sp : 9.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
