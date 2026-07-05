import 'package:e_prescription/const/const.dart';
import 'package:e_prescription/const/text_to_html.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/widgets/quick_tech_custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_prescription/controllers/prescription_controller/prescription_rx_controller/quick_tech_manual_therapy_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/models/rx_models/therapy_model.dart';

class CustomManualTherapyInfo extends StatefulWidget {
  @override
  _CustomManualTherapyInfoState createState() =>
      _CustomManualTherapyInfoState();
}

class _CustomManualTherapyInfoState extends State<CustomManualTherapyInfo> {
  final QuickTechManualTherapyController therapyController = locator.get<QuickTechManualTherapyController>();
  final QuickTechThemeController themeController = locator.get<QuickTechThemeController>();



  @override
  Widget build(BuildContext context) {
    return customExpansionTile('Manual Therapy');
  }

  Widget customSearchBar(TextEditingController? controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (therapyController.categories.isEmpty) {
        therapyController.fetchManualTherapies();
      }
    });
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: QuickTechCustomTextField(
        label: 'Search',
        controller: therapyController.searchController,
        height: 50,
        icon: Icons.search,
        iconcolor:
            themeController.isDay.value
                ? QuickTechAppColors.lightmaintextcolor
                : QuickTechAppColors.darkmaintextcolor,
        backcolor:
            themeController.isDay.value
                ? QuickTechAppColors.lightScaffoldColor
                : QuickTechAppColors.darkScaffoldColor,
      ),
    );
  }

  Widget customExpansionTile(String title) {
    return Obx(
      () => Card(
        color:
            themeController.isDay.value
                ? QuickTechAppColors.lightScaffoldColor
                : QuickTechAppColors.darkScaffoldColor,
        elevation: 5,
        shadowColor:
            themeController.isDay.value
                ? QuickTechAppColors.black.withValues(alpha: 0.5)
                : QuickTechAppColors.white.withValues(alpha: 0.3),

        child: ExpansionTile(
          collapsedShape: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1.5,
              color:
                  themeController.isDay.value
                      ? QuickTechAppColors.lightmaincolor
                      : QuickTechAppColors.darkmaincolor,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          iconColor: QuickTechAppColors.lightmaincolor,
          shape: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color:
                  themeController.isDay.value
                      ? QuickTechAppColors.lightmaincolor
                      : QuickTechAppColors.darkmaincolor,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            title,
            style: myStyle(
              16,
              themeController.isDay.value
                  ? QuickTechAppColors.lightmaintextcolor
                  : QuickTechAppColors.darkmaintextcolor,
              FontWeight.bold,
            ),
          ),
          onExpansionChanged: (expanded) {
            therapyController.isManualTherapyClicked.value = expanded;
          },
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: customSearchBar(therapyController.searchController)),
                    IconButton(
                      onPressed: therapyController.clearAllSelections,
                      icon: Icon(
                        Icons.clear_all,
                        color:
                            themeController.isDay.value
                                ? QuickTechAppColors.lightmaintextcolor
                                : QuickTechAppColors.darkmaintextcolor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                for (int i = 0; i < therapyController.filteredCategories.length; i++)
                  CustomCategoryCard(
                    therapyController.filteredCategories[i],
                    therapyController.categories.indexOf(therapyController.filteredCategories[i]),
                  ),
                SizedBox(height: 15),
                customManualOthersCard(),
                SizedBox(height: 20),
                customselectedPanel(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget customselectedPanel() {
    return Obx(
      () => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              themeController.isDay.value
                  ? QuickTechAppColors.lightScaffoldColor
                  : QuickTechAppColors.darkScaffoldColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selected Therapies:',
              style: myStyle(
                16,
                themeController.isDay.value
                    ? QuickTechAppColors.darkmaincolor
                    : QuickTechAppColors.white,
                FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            customSelectedTherapyList(),
          ],
        ),
      ),
    );
  }

  Widget customSelectedTherapyList() {
    return therapyController.selectedTherapies.isEmpty
        ? Text(
          'No therapies selected',
          style: myStyle(
            14,
            themeController.isDay.value
                ? QuickTechAppColors.darkmaincolor
                : QuickTechAppColors.white,
            FontWeight.normal,
          ),
        )
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              therapyController.selectedTherapies
                  .map(
                    (therapy) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '• $therapy',
                        style: myStyle(
                          14,
                          themeController.isDay.value
                              ? QuickTechAppColors.darkmaincolor
                              : QuickTechAppColors.white,
                          FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        );
  }

  Widget CustomCategoryCard(TherapyCategory category, int categoryIndex) {
    return Card(
      color:
          themeController.isDay.value
              ? QuickTechAppColors.white
              : QuickTechAppColors.black2,
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            title: Text(
              category.name,
              style: myStyle(
                14,
                themeController.isDay.value
                    ? QuickTechAppColors.lightmaintextcolor
                    : QuickTechAppColors.darkmaintextcolor,
                category.isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: Checkbox(
              value: category.isSelected,
              onChanged: (value) {
                therapyController.toggleCategorySelection(categoryIndex);
              },
            ),
            onTap: () {
              therapyController.toggleCategorySelection(categoryIndex);
            },
          ),
          if (category.subcategories != null && category.isSelected)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  for (int i = 0; i < category.subcategories!.length; i++)
                    customSubcategoryItem(category, categoryIndex, i),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget customSubcategoryItem(
    TherapyCategory category,
    int categoryIndex,
    int subcategoryIndex,
  ) {
    final sub = category.subcategories![subcategoryIndex];

    return Column(
      children: [
        CheckboxListTile(
          title: Text(
            sub.name,
            style: myStyle(
              12,
              themeController.isDay.value
                  ? QuickTechAppColors.lightmaintextcolor
                  : QuickTechAppColors.darkmaintextcolor,
            ),
          ),
          value: category.subcategorySelections![subcategoryIndex],
          onChanged: (value) {
            therapyController.toggleSubcategorySelection(
              categoryIndex,
              subcategoryIndex,
            );
          },
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          contentPadding: const EdgeInsets.only(left: 16),
        ),
        if (sub.valueType == "With note" &&
            category.subcategorySelections![subcategoryIndex])
          customNOtes(categoryIndex, subcategoryIndex),
      ],
    );
  }

  Widget customNOtes(int categoryIndex, int subcategoryIndex) {
    return Padding(
      padding: const EdgeInsets.only(left: 32.0, right: 16.0, bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color:
              themeController.isDay.value
                  ? QuickTechAppColors.bktxtfld
                  : QuickTechAppColors.bkdarktxtfld,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: QuickTechAppColors.lightmaincolor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes for this therapy:',
              style: myStyle(
                12,
                QuickTechAppColors.lightmaincolor,
                FontWeight.bold,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter details...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: myStyle(
                12,
                themeController.isDay.value
                    ? QuickTechAppColors.lightmaintextcolor
                    : QuickTechAppColors.darkmaintextcolor,
              ),
              maxLines: 1,
              onChanged: (value) {
                therapyController.updateSubcategoryNote(
                  categoryIndex,
                  subcategoryIndex,
                  value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget customManualOthersCard() {
    // Draft state lives on the controller (not as a local variable here) so it
    // survives rebuilds triggered by unrelated reactive changes in this section.
    final activeInputIndex = therapyController.activeInputIndex;
    final tempControllers = therapyController.tempControllers;

    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Card(
          color:
              themeController.isDay.value
                  ? QuickTechAppColors.lightScaffoldColor
                  : QuickTechAppColors.darkScaffoldColor,
          elevation: 2,
          margin: EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ═══════════════════════════════════════════════════════
                // HEADER SECTION
                // ═══════════════════════════════════════════════════════
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Extra Therapy',
                          style: myStyle(
                            15.sp,
                            themeController.isDay.value
                                ? QuickTechAppColors.lightmaintextcolor
                                : QuickTechAppColors.darkmaintextcolor,
                            FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                           'Add therapy options',
                        style: myStyle(
                          11.sp,
                            themeController.isDay.value
                                ? QuickTechAppColors.lightmaintextcolor
                                    .withValues(alpha: 0.6)
                                : QuickTechAppColors.darkmaintextcolor
                                    .withValues(alpha: 0.6),
                            FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color:
                            themeController.isDay.value
                                ? QuickTechAppColors.lightmaincolor.withValues(alpha:
                                  0.1,
                                )
                                : QuickTechAppColors.darkmaincolor.withValues(alpha:
                                  0.2,
                                ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FloatingActionButton.small(
                        heroTag: 'addExtraManual',
                        elevation: 0,
                        backgroundColor:
                            themeController.isDay.value
                                ? QuickTechAppColors.lightmaincolor
                                : QuickTechAppColors.darkmaincolor,
                        onPressed: () {
                          tempControllers.add(TextEditingController());
                          activeInputIndex.value = tempControllers.length - 1;
                        },
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // ═══════════════════════════════════════════════════════
                // INPUT FIELD SECTION (when active)
                // ═══════════════════════════════════════════════════════
                if (activeInputIndex.value >= 0 &&
                    activeInputIndex.value < tempControllers.length)
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            themeController.isDay.value
                                ? QuickTechAppColors.lightmaincolor.withValues(alpha:
                                  0.3,
                                )
                                : QuickTechAppColors.darkmaincolor.withValues(alpha:
                                  0.3,
                                ),
                        width: 1.5,
                      ),
                      color:
                          themeController.isDay.value
                              ? Colors.blue.shade50
                              : Colors.blue.shade900.withValues(alpha: 0.1),
                    ),
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              size: 18,
                              color:
                                  themeController.isDay.value
                                      ? QuickTechAppColors.lightmaincolor
                                      : QuickTechAppColors.darkmaincolor,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'New Entry',
                              style: myStyle(
                                12,
                                themeController.isDay.value
                                    ? QuickTechAppColors.lightmaincolor
                                    : QuickTechAppColors.darkmaincolor,
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        // Text field
                        TextField(
                          autofocus: true,
                          maxLength: 255,
                          maxLines: 8,
                          minLines: 6,
                          controller: tempControllers[activeInputIndex.value],
                          style: myStyle(
                            12,
                            themeController.isDay.value
                                ? QuickTechAppColors.lightmaintextcolor
                                : QuickTechAppColors.darkmaintextcolor,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color:
                                    themeController.isDay.value
                                        ? QuickTechAppColors.lightmaincolor
                                            .withValues(alpha: 0.2)
                                        : QuickTechAppColors.darkmaincolor
                                            .withValues(alpha: 0.2),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color:
                                    themeController.isDay.value
                                        ? QuickTechAppColors.lightmaincolor
                                            .withValues(alpha: 0.2)
                                        : QuickTechAppColors.darkmaincolor
                                            .withValues(alpha: 0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color:
                                    themeController.isDay.value
                                        ? QuickTechAppColors.lightmaincolor
                                        : QuickTechAppColors.darkmaincolor,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            filled: true,
                            fillColor:
                                themeController.isDay.value
                                    ? QuickTechAppColors.bktxtfld
                                    : QuickTechAppColors.bkdarktxtfld,
                            hintText:
                                'Enter therapy details (max 255 chars)\n\n(You can paste multiple lines)',
                            hintStyle: myStyle(
                              11,
                              themeController.isDay.value
                                  ? QuickTechAppColors.lightmaintextcolor
                                      .withValues(alpha: 0.5)
                                  : QuickTechAppColors.darkmaintextcolor
                                      .withValues(alpha: 0.5),
                              FontWeight.w400,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        // Action buttons
                       LayoutBuilder(
  builder: (context, constraints) {
    final hasEnoughSpace = constraints.maxWidth > 200;

    if (hasEnoughSpace) {
      // Wide screen - Horizontal layout
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Cancel button
          TextButton(
            onPressed: () {
              final idx = activeInputIndex.value;
              tempControllers[idx].dispose();
              tempControllers.removeAt(idx);
              activeInputIndex.value = -1;
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            child: Text(
              'Cancel',
              style: myStyle(
                12,
                themeController.isDay.value
                    ? QuickTechAppColors.lightmaintextcolor
                        .withValues(alpha: 0.7)
                    : QuickTechAppColors.darkmaintextcolor
                        .withValues(alpha: 0.7),
                FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8),
          // OK button
          ElevatedButton.icon(
            icon: Icon(Icons.check_rounded, size: 18),
            label: Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.isDay.value
                  ? QuickTechAppColors.lightmaincolor
                  : QuickTechAppColors.darkmaincolor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () {
              final idx = activeInputIndex.value;
              final plainText = tempControllers[idx].text.trim();
              if (plainText.isNotEmpty) {
                // Convert plain text to HTML format for mPDF
                final htmlText = convertToHtmlParagraphs(plainText);

                // Store HTML format in both lists
                therapyController.customTherapies.add(htmlText);
                therapyController.customTherapyControllers
                    .add(TextEditingController(text: htmlText));
              }
              tempControllers[idx].dispose();
              tempControllers.removeAt(idx);
              activeInputIndex.value = -1;
            },
          ),
        ],
      );
    } else {
      // Narrow screen - Vertical stacked layout
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // OK button (Save) - First on mobile
          ElevatedButton.icon(
            icon: Icon(Icons.check_rounded, size: 18),
            label: Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeController.isDay.value
                  ? QuickTechAppColors.lightmaincolor
                  : QuickTechAppColors.darkmaincolor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () {
              final idx = activeInputIndex.value;
              final plainText = tempControllers[idx].text.trim();
              if (plainText.isNotEmpty) {
                // Convert plain text to HTML format for mPDF
                final htmlText = convertToHtmlParagraphs(plainText);

                // Store HTML format in both lists
                therapyController.customTherapies.add(htmlText);
                therapyController.customTherapyControllers
                    .add(TextEditingController(text: htmlText));
              }
              tempControllers[idx].dispose();
              tempControllers.removeAt(idx);
              activeInputIndex.value = -1;
            },
          ),
          SizedBox(height: 8),
          // Cancel button - Second on mobile
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                final idx = activeInputIndex.value;
                tempControllers[idx].dispose();
                tempControllers.removeAt(idx);
                activeInputIndex.value = -1;
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: Text(
                'Cancel',
                style: myStyle(
                  12,
                  themeController.isDay.value
                      ? QuickTechAppColors.lightmaintextcolor
                          .withValues(alpha: 0.7)
                      : QuickTechAppColors.darkmaintextcolor
                          .withValues(alpha: 0.7),
                  FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    }
  },
)
                      ],
                    ),
                  ),

                // ═══════════════════════════════════════════════════════
                // SAVED ENTRIES SECTION
                // ═══════════════════════════════════════════════════════
                if (therapyController.customTherapies.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section title
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: Colors.green.shade600,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Saved Entries',
                            style: myStyle(
                              13,
                              Colors.green.shade600,
                              FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${therapyController.customTherapies.length}',
                              style: myStyle(
                                10,
                                Colors.green.shade700,
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Entries container
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                themeController.isDay.value
                                    ? QuickTechAppColors.lightmaincolor
                                        .withValues(alpha: 0.15)
                                    : QuickTechAppColors.darkmaincolor
                                        .withValues(alpha: 0.15),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color:
                              themeController.isDay.value
                                  ? Colors.green.shade50.withValues(alpha: 0.3)
                                  : Colors.green.shade900.withValues(alpha: 0.05),
                        ),
                        constraints: BoxConstraints(maxHeight: 300),
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              therapyController.customTherapies.length,
                              (index) {
                                final therapy = therapyController
                                    .customTherapies[index];
                                if (therapy.trim().isEmpty)
                                  return SizedBox.shrink();

                                return Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color:
                                        themeController.isDay.value
                                            ? Colors.white.withValues(alpha: 0.6)
                                            : Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.green.shade200.withValues(alpha:
                                        0.5,
                                      ),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Entry number and delete
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Entry #${index + 1}',
                                              style: myStyle(
                                                10,
                                                Colors.green.shade700,
                                                FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              therapyController
                                                  .removeCustomTherapy(
                                                    index,
                                                  );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Icon(
                                                Icons.close_rounded,
                                                size: 16,
                                                color: Colors.red.shade600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      // Therapy content
                                      Text(
                                         stripHtmlTags(therapy),
                                        style: myStyle(
                                          11,
                                          themeController.isDay.value
                                              ? QuickTechAppColors
                                                  .lightmaintextcolor
                                              : QuickTechAppColors
                                                  .darkmaintextcolor,
                                          FontWeight.w500,
                                        ),
                                        maxLines: 10,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                // ═══════════════════════════════════════════════════════
                // EMPTY STATE
                // ═══════════════════════════════════════════════════════
                if (therapyController.customTherapies.isEmpty &&
                    activeInputIndex.value < 0)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  themeController.isDay.value
                                      ? QuickTechAppColors.lightmaincolor
                                          .withValues(alpha: 0.1)
                                      : QuickTechAppColors.darkmaincolor
                                          .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.add_box_rounded,
                              size: 32,
                              color:
                                  themeController.isDay.value
                                      ? QuickTechAppColors.lightmaincolor
                                      : QuickTechAppColors.darkmaincolor,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No custom entries yet',
                            style: myStyle(
                              12,
                              themeController.isDay.value
                                  ? QuickTechAppColors.lightmaintextcolor
                                  : QuickTechAppColors.darkmaintextcolor,
                              FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Tap the + button to add custom therapy',
                            style: myStyle(
                              10,
                              themeController.isDay.value
                                  ? QuickTechAppColors.lightmaintextcolor
                                      .withValues(alpha: 0.6)
                                  : QuickTechAppColors.darkmaintextcolor
                                      .withValues(alpha: 0.6),
                              FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
