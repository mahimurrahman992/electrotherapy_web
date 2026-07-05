import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/const/web_image.dart';
import 'package:e_prescription/controllers/package_controller/quick_tech_package_controller.dart';
import 'package:e_prescription/controllers/profile_controller/quick_tech_profile_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';


import 'package:e_prescription/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:e_prescription/controllers/authentication_controller/login_controller/quick_tech_login_controller.dart';
import 'package:e_prescription/locator.dart';

import '../responsive.dart';

final themeController = locator.get<QuickTechThemeController>();
final profileController = locator.get<QuickTechProfileController>();
final packageController = locator.get<QuickTechPackageController>();

Widget customDrawer(BuildContext context) {
  return Obx(
    () {
      final isDay = themeController.isDay.value;
      final bgColor = isDay
          ? QuickTechAppColors.lightScaffoldColor
          : QuickTechAppColors.darkScaffoldColor;
      final headerColor = isDay
          ? QuickTechAppColors.lightmaincolor
          : QuickTechAppColors.darkmaincolor;

      return Drawer(
        backgroundColor: bgColor,
        child: Column(
          children: <Widget>[
            // --- HEADER ---
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
              decoration: BoxDecoration(color: headerColor),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    profileController.profilePhoto.value.isNotEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.w),
                            ),
                            child: ClipOval(
                              child: SizedBox(
                                width: Responsive.isDesktop(context) ? 90.r : 80.r,
                                height: Responsive.isDesktop(context) ? 90.r : 80.r,
                                child: WebImage(
                                  imageUrl: "${Api.baseUrl}/${profileController.profilePhoto.value}",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor: QuickTechAppColors.white,
                            radius: Responsive.isDesktop(context) ? 45.r : 40.r,
                            backgroundImage: const AssetImage('assets/images/mainlogo.png'),
                          ),
                    SizedBox(height: 10.h),
                    Text(
                      profileController.name.value.isNotEmpty
                          ? profileController.name.value
                          : 'Therapy Center',
                      style: myStyle(
                        Responsive.isDesktop(context) ? 12.sp : 12.sp,
                        QuickTechAppColors.darkmaintextcolor,
                        FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // --- SCROLLABLE MENU ITEMS ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                children: [
                  _buildDrawerItem(
                    context: context,
                    title: 'Home',
                    icon: Icons.dashboard_rounded,
                    onTap: () => Get.offNamed('/mainhome'),
                  ),
                  _buildDrawerItem(
                    context: context,
                    title: 'Add Prescription',
                    icon: Icons.note_add_rounded,
                    onTap: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Get.offNamed('/prescriptionform');
                        
                      });
                    },
                  ),
                  _buildDrawerItem(
                    context: context,
                    title: 'Add Assessment',
                    icon: Icons.assignment_add,
                    onTap: () => Get.offNamed('/addassessment'),
                  ),
                  _buildDrawerItem(
                    context: context,
                    title: 'Patient List',
                    icon: Icons.people_alt_rounded,
                    onTap: () => Get.toNamed('/patientrecords'),
                  ),
                  _buildDrawerItem(
                    context: context,
                    title: 'Packages',
                    icon: Icons.inventory_2_rounded,
                    onTap: () => Get.toNamed('/packages'),
                  ),
                  _buildDrawerItem(
                    context: context,
                    title: 'Templates',
                    icon: Icons.file_copy_rounded,
                    onTap: () => Get.toNamed('/templateselect'),
                  ),
                  _buildDrawerItem(
                    context: context,
                    title: 'Profile',
                    icon: Icons.person_rounded,
                    onTap: () => Get.toNamed('/profile'),
                  ),
                  _buildDrawerItem(
                    context: context,
                    title: 'Settings',
                    icon: Icons.settings_rounded,
                    onTap: () => Get.toNamed('/settings'),
                    showDivider: false, // Hide divider on last item before bottom
                  ),
                ],
              ),
            ),

            // --- BOTTOM LOGOUT SECTION ---
            Divider(
              height: 1,
              thickness: 1.5,
              color: isDay ? Colors.grey.shade300 : Colors.grey.shade800,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8.h, top: 8.h),
              child: _buildDrawerItem(
                context: context,
                title: 'Logout',
                icon: Icons.logout_rounded,
                isLogout: true,
                showDivider: false,
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      title: Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          ),
                          onPressed: () => Get.back(result: true),
                          child: Text('Logout', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  
                  if (shouldLogout == true) {
                    final loginController = locator.get<QuickTechLoginController>();
                    await loginController.logout();
                  }
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

// --- REUSABLE HELPER WIDGET ---
Widget _buildDrawerItem({
  required BuildContext context,
  required String title,
  required IconData icon,
  required VoidCallback onTap,
  bool isLogout = false,
  bool showDivider = true,
}) {
  final isDay = themeController.isDay.value;
  
  // Define text and icon color based on day/night mode and logout status
  final defaultColor = isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor;
  final itemColor = isLogout ? Colors.redAccent : defaultColor;

  return Column(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          leading: Icon(
            icon,
            color: itemColor,
            size: Responsive.isDesktop(context) ? 18.sp : 18.sp,
          ),
          title: Text(
            title,
            style: myStyle(
              Responsive.isDesktop(context) ? 13.sp : 12.sp,
              itemColor,
              FontWeight.w600,
            ),
          ),
          onTap: onTap,
          dense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
          hoverColor: itemColor.withValues(alpha:0.05),
        ),
      ),
      if (showDivider)
        Divider(
          height: 1,
          thickness: 1,
          color: isDay ? Colors.grey.shade200 : Colors.grey.shade800,
          indent: 20.w,
          endIndent: 20.w,
        ),
    ],
  );
}