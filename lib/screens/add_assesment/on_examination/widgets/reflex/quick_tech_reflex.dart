import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/controllers/assessment_controller/on_examination/reflex/quick_tech_reflex_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/screens/add_assesment/on_examination/widgets/quick_tech_on_examination_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ReflexSelection extends StatelessWidget {
  ReflexSelection({Key? key}) : super(key: key);

  final RxBool isInfoExpanded = false.obs;

  @override
  Widget build(BuildContext context) {
    final themeController = locator.get<QuickTechThemeController>();
    final reflexController = locator.get<QuickTechReflexController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(() {
                final isDay = themeController.isDay.value;
                final bgColor = isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.bkdarktxtfld;
                final borderColor = isDay ? QuickTechAppColors.black.withValues(alpha:0.3) : QuickTechAppColors.grey.withValues(alpha:0.3);

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Builder(builder: (context) {
                    if (reflexController.isLoadingReflexes.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                      );
                    }
                    if (reflexController.reflexesError.isNotEmpty) {
                      return Text(reflexController.reflexesError.value, style: const TextStyle(color: Colors.red));
                    }

                    final displayValue = reflexController.selectedCategory.value;
                    final showHint = displayValue.isEmpty;
                    
                    return DropdownButton<String>(
                      dropdownColor: bgColor,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: showHint
                          ? Text(
                              "Select Reflex Category",
                              style: myStyle(
                                14,
                                isDay ? QuickTechAppColors.lightmaintextcolor.withValues(alpha:0.7) : QuickTechAppColors.darkmaintextcolor.withValues(alpha:0.7),
                              ),
                            )
                          : null,
                      value: showHint ? null : displayValue,
                      items: reflexController.reflexCategories
                          .where((category) => category.isNotEmpty)
                          .map((category) => DropdownMenuItem<String>(
                                value: category,
                                child: Text(
                                  category,
                                  style: myStyle(
                                    14,
                                    isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor,
                                    FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          reflexController.setCategory(value);
                        }
                      },
                    );
                  }),
                );
              }),
            ),
            Obx(() {
               final isDay = themeController.isDay.value;
               return IconButton(
                  onPressed: () async {
                    if (!isInfoExpanded.value) {
                      await reflexController.fetchReflexGrades();
                    }
                    isInfoExpanded.toggle();
                  },
                  icon: Icon(
                    FontAwesomeIcons.circleInfo.data,
                    size: 20,
                    color: isInfoExpanded.value 
                        ? (isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor) 
                        : (isDay ? QuickTechAppColors.lightmaintextcolor.withValues(alpha:0.7) : QuickTechAppColors.darkmaintextcolor.withValues(alpha:0.7)),
                  ),
                );
            }),
          ],
        ),

        // Info Card
        Obx(() => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isInfoExpanded.value
              ? OnExaminationInfoCard(
                  content: Builder(builder: (context) {
                    if (reflexController.isLoadingGrades.value) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (reflexController.gradesError.isNotEmpty) {
                      return Text(reflexController.gradesError.value, style: const TextStyle(color: Colors.red));
                    } else if (reflexController.reflexGrades.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Reflex Grading Scale:",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: themeController.isDay.value ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...reflexController.reflexGrades.map(
                            (grade) => OnExaminationInfoItem(
                              title: '${grade.numericValue ?? ''}:',
                              description: grade.textValue ?? '',
                            ),
                          ),
                          const Divider(),
                          const OnExaminationInfoItem(
                            title: "Note:",
                            description: "Reflexes should be compared bilaterally for symmetry in response.",
                          ),
                        ],
                      );
                    } else {
                      return const Text("No reflex grades available.", style: TextStyle(color: Colors.grey));
                    }
                  }),
                )
              : const SizedBox.shrink(),
        )),

        const SizedBox(height: 12),

        // Reflex Expansion List
        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reflexController.reflexList.length,
          itemBuilder: (context, index) {
            final reflex = reflexController.reflexList[index];
            final reflexName = reflex.name ?? '';
            final subcategories = reflex.reflexSubcategories ?? [];
            final isDay = themeController.isDay.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDay ? QuickTechAppColors.bktxtfld : QuickTechAppColors.bkdarktxtfld,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDay ? Colors.grey.shade300 : Colors.grey.shade800),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: false,
                  title: Text(
                    reflexName,
                    style: myStyle(14, isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor, FontWeight.bold),
                  ),
                  children: [
                    ...subcategories.map((option) {
                      final optionValue = option.numericValue ?? '';
                      return Obx(() => CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor,
                        title: Text(
                          optionValue,
                          style: myStyle(13, isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor),
                        ),
                        value: reflexController.isOptionSelected(reflexName, optionValue),
                        onChanged: (bool? selected) {
                          if (selected != null) {
                            reflexController.updateSelectedOption(reflexName, optionValue);
                          }
                        },
                      ));
                    }).toList(),
                    // Selected Chips at the bottom of expansion tile
                    Obx(() {
                      final selected = reflexController.selectedOptions[reflexName];
                      if (selected != null && selected.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: selected.map((option) {
                                return InputChip(
                                  label: Text(option),
                                  labelStyle: myStyle(12, Colors.white),
                                  backgroundColor: isDay ? QuickTechAppColors.lightmaincolor : QuickTechAppColors.darkmaincolor,
                                  deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white),
                                  onDeleted: () => reflexController.updateSelectedOption(reflexName, option),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            );
          },
        )),

        // Placeholder if nothing selected
        Obx(() {
          final allSelected = reflexController.selectedOptions.values.expand((options) => options).toList();
          if (allSelected.isEmpty && reflexController.reflexList.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: themeController.isDay.value ? Colors.blue.withValues(alpha:0.05) : Colors.blue.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha:0.2))
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: themeController.isDay.value ? Colors.blue.shade700 : Colors.blue.shade300, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "Expand a category above to score reflexes.",
                    style: myStyle(13, themeController.isDay.value ? Colors.blue.shade800 : Colors.blue.shade200),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}