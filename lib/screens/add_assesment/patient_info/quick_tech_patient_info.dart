import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/controllers/assessment_controller/patient_info/quick_tech_patient_info_controlle.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/responsive.dart';

import 'package:e_prescription/widgets/quick_tech_custom_drop_down.dart';

import 'package:e_prescription/widgets/quick_tech_custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';
Widget generalInfoPage() {
  final QuickTechThemeController themeController = locator.get<QuickTechThemeController>();
  final QuickTechPatientInfoController c = locator.get<QuickTechPatientInfoController>();

  return Obx(() {
    final isDay = themeController.isDay.value;
    final mainColor = isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor;
    final textColor = isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor;
    final lblColor = textColor.withValues(alpha: 0.7);
    final bkColor = isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.darktxtfieldcolor;

    Widget tf({
      required IconData icon,
      required String label,
      required TextEditingController controller,
      Function(String)? onchanged,
      TextInputType? keyboardType,
      VoidCallback? onTap,
    }) {
      final w = QuickTechCustomTextField(
        lebelcolor: lblColor,
        txtcolor: textColor,
        iconcolor: lblColor,
        icon: icon,
        label: label,
        controller: controller,
        height: 50,
        backcolor: bkColor,
        onchanged: onchanged,
        keyboardType: keyboardType,
      );
      if (onTap != null) return GestureDetector(onTap: onTap, child: AbsorbPointer(child: w));
      return w;
    }

    Widget dd<T>({
      required String label,
      required List<T> items,
      required T value,
      required ValueChanged<T?> onChanged,
      required IconData icon,
      bool enableOthers = false,
      String? dialogTitle,
      String? dialogHint,
    }) => QuickTechCustomDropDown<T>(
      label: label,
      items: items,
      value: value,
      onChanged: onChanged,
      icon: icon,
      isDay: isDay,
      enableOthersOption: enableOthers,
      dialogTitle: dialogTitle,
      dialogHint: dialogHint,
    );

    // Header widget
    Widget header() => Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: mainColor.withValues(alpha:0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.person_pin, color: mainColor, size: 24),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Patient Information', style: myStyle(18, mainColor, FontWeight.bold)),
          if (c.currentPatientId != null)
            Text('ID: ${c.currentPatientId}', style: myStyle(13, textColor.withValues(alpha:0.5), FontWeight.w500)),
        ]),
      ],
    );

    // All form fields as flat list
    final allFields = [
      tf(icon: Icons.person, label: 'Patient Name*', controller: c.patientNameController, onchanged: c.updatePatientName),
      tf(icon: Icons.person, label: "Father's Name", controller: c.fatherNameController, onchanged: c.updateFatherName),
      tf(icon: Icons.person, label: "Mother's Name", controller: c.motherNameController, onchanged: c.updateMotherName),
      tf(icon: Icons.phone, label: "Phone Number*", controller: c.phoneController, onchanged: c.updatePhoneNumber, keyboardType: TextInputType.phone),
      tf(icon: Icons.person, label: "Spouse Name", controller: c.spouseNameController, onchanged: c.updateSpouseName),
      tf(icon: Icons.cake, label: "Age", controller: c.ageController, onchanged: (v) => c.updateAge(int.tryParse(v) ?? 0), keyboardType: TextInputType.number),
      dd<String?>(label: "Sex", items: c.sexOptions, value: c.sex.value, onChanged: (v) => c.updateSex(v!), icon: Icons.accessibility),
      dd<String?>(label: "Occupation", items: c.occupationOptions, value: c.occupation.value, onChanged: c.updateOccupation, icon: FontAwesomeIcons.briefcase.data, enableOthers: true, dialogTitle: "Add New Occupation", dialogHint: "Enter New Occupation"),
      dd<String?>(label: "Marital Status", items: c.maritalStatusOptions, value: c.maritalStatus.value, onChanged: (v) => c.updateMaritalStatus(v!), icon: Icons.favorite),
      tf(icon: Icons.bloodtype, label: "Blood Group", controller: c.bloodGroupController, onchanged: c.updateBloodGroup),
      tf(icon: Icons.person, label: "Guardian Name", controller: c.guardianNameController, onchanged: c.updateGuardianName),
      tf(icon: Icons.fingerprint, label: "Voter ID", controller: c.voterIDController, onchanged: c.updateVoterID),
      tf(icon: Icons.calendar_today, label: "Date of Birth", controller: c.birthDateController, onTap: () => c.selectDateOfBirth(Get.context!)),
      tf(icon: Icons.view_comfortable_outlined, label: "Birth Registration No", controller: c.birthRegistrationNoController, onchanged: c.updateBirthRegistrationNo),
      tf(icon: FontAwesomeIcons.wheelchairMove.data, label: "Disability ID No", controller: c.disabilityIDController, onchanged: c.updateDisabilityID),
      dd<String?>(label: "Education of Patient", items: c.educationOptions, value: c.educationOfPatient.value, onChanged: (v) => c.updateEducationOfPatient(v!), icon: Icons.school),
      dd<String?>(label: "Education of Guardian", items: c.educationOptions, value: c.educationOfGuardian.value, onChanged: (v) => c.updateEducationOfGuardian(v!), icon: FontAwesomeIcons.graduationCap.data),
    ];

    // Build grid: n columns, gap between items
    Widget buildGrid(int cols) {
      final rows = <Widget>[];
      for (int i = 0; i < allFields.length; i += cols) {
        final rowChildren = <Widget>[];
        for (int j = 0; j < cols; j++) {
          final idx = i + j;
          rowChildren.add(
            Expanded(child: idx < allFields.length ? allFields[idx] : const SizedBox()),
          );
          if (j < cols - 1) rowChildren.add(const SizedBox(width: 14));
        }
        rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: rowChildren));
        rows.add(const SizedBox(height: 12));
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
    }

    // Mobile: 1 column, compact padding
    Widget mobile() => SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        header(),
        const SizedBox(height: 16),
        buildGrid(1),
      ]),
    );

    // Tablet: 2 columns, slightly more padding
    Widget tablet() => SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        header(),
        const SizedBox(height: 20),
        // Section cards for tablet
        _sectionCard(
          color: mainColor,
          title: 'Personal Details',
          icon: Icons.person_outline,
          child: buildGrid(2),
        ),
      ]),
    );

    // Desktop: 3 columns, wide padding, section cards
    Widget desktop() => SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        header(),
        const SizedBox(height: 24),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Left column: first 9 fields
          Expanded(
            flex: 3,
            child: _sectionCard(
              color: mainColor,
              title: 'Basic Information',
              icon: Icons.badge_outlined,
              child: buildGrid(1),
            ),
          ),
          const SizedBox(width: 20),
          // Right column: last 8 fields
          Expanded(
            flex: 2,
            child: _sectionCard(
              color: mainColor,
              title: 'Additional Details',
              icon: Icons.info_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: allFields
                    .skip(9)
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: f,
                        ))
                    .toList(),
              ),
            ),
          ),
        ]),
      ]),
    );

    return Responsive(
      mobile: mobile(),
      tablet: tablet(),
      desktop: desktop(),
    );
  });
}

// Section card helper (not a custom widget class — just a function)
Widget _sectionCard({
  required Color color,
  required String title,
  required IconData icon,
  required Widget child,
}) {
  return Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha:0.03),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha:0.18)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.04), blurRadius: 10)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ]),
      const SizedBox(height: 14),
      child,
    ]),
  );
}