import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/controllers/assessment_controller/muscle_power/quick_tech_muscle_power_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/screens/add_assesment/widgets/quick_tech_assessment_widgets.dart';
import 'package:e_prescription/widgets/quick_tech_custom_drop_down.dart';
import 'package:e_prescription/widgets/quick_tech_custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:e_prescription/locator.dart';
import 'package:get/get.dart';

class LimbSectionCard extends StatelessWidget {
  final String title;
  final TextEditingController movementController;
  final TextEditingController muscleNameController;
  final TextEditingController leftInitialController;
  final TextEditingController rightInitialController;
  final TextEditingController leftDischargeController;
  final TextEditingController rightDischargeController;
  final TextEditingController commentController;

  const LimbSectionCard({
    Key? key,
    required this.title,
    required this.movementController,
    required this.muscleNameController,
    required this.leftInitialController,
    required this.rightInitialController,
    required this.leftDischargeController,
    required this.rightDischargeController,
    required this.commentController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final QuickTechThemeController themeController = locator.get<QuickTechThemeController>();

    return Obx(() {
      final isDay = themeController.isDay.value;
      final mainColor = isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor;
      final txtColor = isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor;
      final labelColor = txtColor.withValues(alpha:0.8);
      final bgColor = isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.darktxtfieldcolor;
      final iconColor = txtColor.withValues(alpha:0.7);

      return assessmentCard(
        color: mainColor,
        title: title,
        icon: Icons.accessibility,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movement & Muscle Name (Row on larger screens, Column on smaller, handled simply via wrapping or direct fields)
            Row(
              children: [
                Expanded(
                  child: QuickTechCustomTextField(
                    label: 'Movement',
                    controller: movementController,
                    height: 50,
                    backcolor: bgColor,
                    icon: FontAwesomeIcons.arrowsRotate.data,
                    lebelcolor: labelColor,
                    iconcolor: iconColor,
                    txtcolor: txtColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: QuickTechCustomTextField(
                    label: 'Muscle Name',
                    controller: muscleNameController,
                    height: 50,
                    backcolor: bgColor,
                    icon: Icons.fitness_center,
                    lebelcolor: labelColor,
                    iconcolor: iconColor,
                    txtcolor: txtColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Initial Assessment Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Initial', style: myStyle(15, txtColor, FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: QuickTechCustomTextField(
                    label: 'Left',
                    controller: leftInitialController,
                    height: 50,
                    backcolor: bgColor,
                    lebelcolor: labelColor,
                    txtcolor: txtColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: QuickTechCustomTextField(
                    label: 'Right',
                    controller: rightInitialController,
                    height: 50,
                    backcolor: bgColor,
                    lebelcolor: labelColor,
                    txtcolor: txtColor,
                    maxline: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Discharge Assessment Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Discharge', style: myStyle(15, txtColor, FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: QuickTechCustomTextField(
                    label: 'Left',
                    controller: leftDischargeController,
                    height: 50,
                    backcolor: bgColor,
                    lebelcolor: labelColor,
                    txtcolor: txtColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: QuickTechCustomTextField(
                    label: 'Right',
                    controller: rightDischargeController,
                    height: 50,
                    backcolor: bgColor,
                    lebelcolor: labelColor,
                    txtcolor: txtColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Comments Section
            QuickTechCustomTextField(
              maxline: 3,
              label: 'Comments',
              controller: commentController,
              height: 80,
              backcolor: bgColor,
              icon: FontAwesomeIcons.comment.data,
              lebelcolor: labelColor,
              iconcolor: iconColor,
              txtcolor: txtColor,
            ),
          ],
        ),
      );
    });
  }
}

class OxfordMuscleScaleWidget extends StatelessWidget {
  OxfordMuscleScaleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = locator.get<QuickTechThemeController>();
    final musclePowerController = locator.get<QuickTechMusclePowerController>();

    return Obx(() {
      final isDay = themeController.isDay.value;
      final mainColor = isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor;
      final txtColor = isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor;

      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Builder(builder: (context) {
                  if (musclePowerController.isLoadingOxford.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                    );
                  }
                  return QuickTechCustomDropDown(
                    label: 'Oxford muscle grading scale',
                    items: musclePowerController.oxfordMuscleGrades.map((e) => e.numericValue).toList(),
                    value: musclePowerController.oxfordMuscle.value,
                    onChanged: (value) => musclePowerController.updateOxfordMuscle(value!),
                    icon: Icons.work,
                    isDay: isDay,
                  );
                }),
              ),
              IconButton(
                onPressed: () => musclePowerController.toggleOxfordMuscle(),
                icon: Icon(
                  FontAwesomeIcons.circleInfo.data,
                  size: 20,
                  color: musclePowerController.oxfordMuscleVisible.value ? mainColor : txtColor.withValues(alpha:0.7),
                ),
              ),
            ],
          ),
          // Info Card
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: musclePowerController.oxfordMuscleVisible.value
                ? Card(
                    color: isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.bkdarktxtfld,
                    elevation: isDay ? 2 : 0,
                    margin: const EdgeInsets.only(top: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isDay ? Colors.grey.shade300 : Colors.grey.shade800),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Builder(builder: (context) {
                        if (musclePowerController.isLoadingOxford.value) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: musclePowerController.oxfordMuscleGrades.map((e) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: RichText(
                                text: TextSpan(
                                  style: myStyle(13, txtColor),
                                  children: [
                                    TextSpan(text: '${e.numericValue}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    TextSpan(text: e.textValue),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
    });
  }
}