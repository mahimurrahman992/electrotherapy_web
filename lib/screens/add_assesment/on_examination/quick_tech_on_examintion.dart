import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/controllers/assessment_controller/on_examination/quick_tech_on_examination_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';

import 'package:e_prescription/screens/add_assesment/on_examination/widgets/quick_tech_on_examination_widgets.dart';
import 'package:e_prescription/screens/add_assesment/on_examination/widgets/reflex/quick_tech_reflex.dart';
import 'package:e_prescription/screens/add_assesment/widgets/quick_tech_assessment_widgets.dart'; // Added for responsive grid/cards
import 'package:e_prescription/widgets/quick_tech_custom_drop_down.dart';
import 'package:e_prescription/widgets/quick_tech_custom_text_field.dart';
import 'package:e_prescription/responsive.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';

class OnExamination extends StatelessWidget {
  final String? patientId;

  OnExamination({Key? key, this.patientId}) : super(key: key) {
    // Initialize data once when widget is created
    locator.get<QuickTechOnExaminationController>().initializeAllData();
  }

  @override
  Widget build(BuildContext context) {
    final QuickTechThemeController themeController = locator.get<QuickTechThemeController>();
    final QuickTechOnExaminationController examinationController = locator.get<QuickTechOnExaminationController>();

    return Obx(() {
      final isDay = themeController.isDay.value;
      final mainColor = isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor;
      final textColor = isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor;
      final bgColor = isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.bkdarktxtfld;
      final iconColor = textColor.withValues(alpha:0.7);

      // ─────────────────────────────────────────────
      // GROUP 1: General & Vitals Fields
      // ─────────────────────────────────────────────
      final generalFields = [
        OnExaminationDropDown(
          label: 'Body type',
          items: examinationController.bodyTypeOptions,
          value: examinationController.bodyType.value,
          onChanged: (value) => examinationController.updateBodyType(value!),
          icon: Icons.accessibility,
          infoContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: examinationController.bodyTypeList.asMap().entries.map(
              (entry) => OnExaminationInfoItem(
                title: '${entry.key + 1}. ${entry.value.numericValue}:',
                description: entry.value.textValue ,
              ),
            ).toList(),
          ),
          isExpanded: examinationController.bodyTypeInfoVisible,
        ),
        QuickTechCustomDropDown(
          label: 'Posture',
          items: examinationController.postureOptions,
          value: examinationController.posture.value,
          onChanged: (value) => examinationController.updatePosture(value!),
          icon: Icons.accessibility_new,
          isDay: isDay,
          dialogHint: 'Enter New Posture',
          dialogTitle: "Add New Posture",
          enableOthersOption: true,
        ),
        QuickTechCustomDropDown(
          label: 'Gait',
          items: examinationController.gaitOptions,
          value: examinationController.gait.value,
          onChanged: (value) => examinationController.updateGait(value!),
          icon: Icons.directions_walk,
          isDay: isDay,
        ),
        QuickTechCustomDropDown(
          label: 'Activity',
          items: examinationController.activityOptions,
          value: examinationController.activity.value,
          onChanged: (value) => examinationController.updateActivity(value!),
          icon: Icons.fitness_center,
          isDay: isDay,
        ),
        QuickTechCustomDropDown(
          label: 'Percussion',
          items: examinationController.percussionOptions,
          value: examinationController.percussion.value,
          onChanged: (value) => examinationController.updatePercussion(value!),
          icon: Icons.music_note,
          isDay: isDay,
        ),
        QuickTechCustomDropDown(
          label: 'Temperature (°C)',
          items: examinationController.temperatureOption,
          value: examinationController.temperature.value,
          onChanged: examinationController.updateTemperature,
          icon: Icons.thermostat,
          isDay: isDay,
          dialogTitle: 'Add Temperature',
          dialogHint: 'Enter Temperature(°C)',
          enableOthersOption: true,
        ),
        QuickTechCustomDropDown(
          label: 'Pulse (bpm)',
          items: examinationController.pulseOptions,
          value: examinationController.pulse.value,
          onChanged: examinationController.updatePulse,
          icon: Icons.monitor_heart,
          isDay: isDay,
          dialogTitle: 'Add Pulse',
          dialogHint: 'Enter Pulse(bpm)',
          enableOthersOption: true,
        ),
        QuickTechCustomTextField(
          txtcolor: textColor,
          lebelcolor: iconColor,
          backcolor: bgColor,
          icon: Icons.local_hospital,
          iconcolor: iconColor,
          label: 'Blood Pressure (mmHg)',
          controller: examinationController.bloodPressureController,
          onchanged: (value) => examinationController.updateBloodPressure(value),
        ),
      ];

      // ─────────────────────────────────────────────
      // GROUP 2: Neurological & Musculoskeletal Fields
      // ─────────────────────────────────────────────
      final neuroFields = [
        OnExaminationDropDown(
          label: 'Sensory',
          items: examinationController.sensoryGradeOptions,
          value: examinationController.sensory.value,
          onChanged: examinationController.updateSensory,
          icon: FontAwesomeIcons.eyeLowVision.data,
          infoContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: examinationController.sensoryGradeList.map(
              (grade) => OnExaminationInfoItem(
                title: '${grade.numericValue}:',
                description: grade.textValue ,
              ),
            ).toList(),
          ),
          isExpanded: examinationController.sensoryInfoVisible,
          dialogHint: 'Enter Sensory',
          dialogTitle: 'Add Sensory',
          enableOthersOption: true,
        ),
        OnExaminationDropDown(
          label: 'Motor',
          items: examinationController.motorGradeOptions,
          value: examinationController.motor.value,
          onChanged: (value) => examinationController.updateMotor(value!),
          icon: FontAwesomeIcons.personRunning.data,
          infoContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: examinationController.motorGradeList.map(
              (grade) => OnExaminationInfoItem(
                title: '${grade.numericValue}:',
                description: grade.textValue,
              ),
            ).toList(),
          ),
          isExpanded: examinationController.motorINfoVisible,
        ),
        OnExaminationDropDown(
          label: 'Muscle Tone',
          items: examinationController.muscleToneOptions,
          value: examinationController.muscleTone.value,
          onChanged: (value) => examinationController.updateMuscleTone(value!),
          icon: FontAwesomeIcons.dumbbell.data,
          infoContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: examinationController.muscleToneList.map(
              (grade) => OnExaminationInfoItem(
                title: '${grade.numericValue}:',
                description: grade.textValue ,
              ),
            ).toList(),
          ),
          dialogHint: 'Enter Muscle Tone',
          dialogTitle: 'Add Muscle Tone',
          enableOthersOption: true,
          isExpanded: examinationController.muscleToneInfoVisible,
        ),
        OnExaminationDropDown(
          label: 'Spasticity',
          items: examinationController.spasticityOptions,
          value: examinationController.spasticity.value,
          onChanged: (value) => examinationController.updateSpasticity(value),
          icon: FontAwesomeIcons.personWalking.data,
          infoContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: examinationController.spasticityList.map(
              (grade) => OnExaminationInfoItem(
                title: '${grade.numericValue}:',
                description: grade.textValue ,
              ),
            ).toList(),
          ),
          dialogHint: 'Enter Spasticity',
          dialogTitle: 'Add Spasticity',
          enableOthersOption: true,
          isExpanded: examinationController.spasticityINfoVisible,
        ),
        OnExaminationDropDown(
          label: 'Bowel bladder control',
          items: examinationController.bowelBladderControlOptions,
          value: examinationController.bowelBladderControl.value,
          onChanged: (value) => examinationController.updateBowelBladderControl(value!),
          icon: FontAwesomeIcons.toilet.data,
          infoContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: examinationController.bowelBladderControlList.map(
              (grade) => OnExaminationInfoItem(
                title: '${grade.numericValue}:',
                description: grade.textValue ,
              ),
            ).toList(),
          ),
          isExpanded: examinationController.bowelControlInfoVisible,
        ),
        QuickTechCustomTextField(
          txtcolor: textColor,
          lebelcolor: iconColor,
          backcolor: bgColor,
          icon: FontAwesomeIcons.bedPulse.data,
          iconcolor: iconColor,
          label: 'Any limb or organ absence',
          controller: examinationController.limborganabsenseController,
          onchanged: (value) => examinationController.updateLimbOrOrganAbsence(value),
        ),
        QuickTechCustomTextField(
          txtcolor: textColor,
          lebelcolor: iconColor,
          backcolor: bgColor,
          icon: FontAwesomeIcons.scaleBalanced.data,
          iconcolor: iconColor,
          label: 'Balancing or coordination',
          controller: examinationController.balancingCoordinatingController,
          onchanged: (value) => examinationController.updateBalancingCondition(value),
        ),
        QuickTechCustomTextField(
          txtcolor: textColor,
          lebelcolor: iconColor,
          backcolor: bgColor,
          icon: Icons.note_add,
          iconcolor: iconColor,
          label: 'Other findings',
          controller: examinationController.othersController,
          onchanged: (value) => examinationController.updateOthers(value),
        ),
      ];

      // ─────────────────────────────────────────────
      // Full Width Components
      // ─────────────────────────────────────────────
      Widget inflammatorySignsSection = CustomMultipleChip(
        label: 'Inflammatory Signs',
        items: examinationController.inflammatorySignOptions,
        selectedItems: examinationController.inflammatorySign, // Assuming this is an RxList<String> based on previous code
        onSelectionChanged: (selectedValues) {
          examinationController.updateInflammatorySigns(selectedValues);
        },
      );

      // Mobile Layout
      Widget mobile() => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            assessmentHeader(mainColor: mainColor, title: 'On Examination', icon: Icons.person_search),
            const SizedBox(height: 16),
            assessmentGrid(fields: generalFields, cols: 1),
            const SizedBox(height: 16),
            inflammatorySignsSection,
            const SizedBox(height: 16),
            ReflexSelection(),
            const SizedBox(height: 16),
            assessmentGrid(fields: neuroFields, cols: 1),
          ],
        ),
      );

      // Tablet Layout
      Widget tablet() => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            assessmentHeader(mainColor: mainColor, title: 'On Examination', icon: Icons.person_search),
            const SizedBox(height: 20),
            assessmentCard(color: mainColor, title: 'General & Vitals', icon: Icons.monitor_heart, child: assessmentGrid(fields: generalFields, cols: 2)),
            const SizedBox(height: 16),
            assessmentCard(color: mainColor, title: 'Inflammatory Signs', icon: Icons.coronavirus, child: inflammatorySignsSection),
            const SizedBox(height: 16),
            assessmentCard(color: mainColor, title: 'Reflexes', icon: Icons.sports_gymnastics, child: ReflexSelection()),
            const SizedBox(height: 16),
            assessmentCard(color: mainColor, title: 'Neurological & Musculoskeletal', icon: Icons.psychology, child: assessmentGrid(fields: neuroFields, cols: 2)),
          ],
        ),
      );

      // Desktop Layout
      Widget desktop() => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            assessmentHeader(mainColor: mainColor, title: 'On Examination', icon: Icons.person_search),
            const SizedBox(height: 24),
            assessmentCard(color: mainColor, title: 'General & Vitals', icon: Icons.monitor_heart, child: assessmentGrid(fields: generalFields, cols: 3)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: assessmentCard(color: mainColor, title: 'Inflammatory Signs', icon: Icons.coronavirus, child: inflammatorySignsSection)),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: assessmentCard(color: mainColor, title: 'Reflexes', icon: Icons.sports_gymnastics, child: ReflexSelection())),
              ],
            ),
            const SizedBox(height: 16),
            assessmentCard(color: mainColor, title: 'Neurological & Musculoskeletal', icon: Icons.psychology, child: assessmentGrid(fields: neuroFields, cols: 3)),
          ],
        ),
      );

      return Responsive(mobile: mobile(), tablet: tablet(), desktop: desktop());
    });
  }
}