import 'package:e_prescription/const/const.dart';
import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/const/text_to_html.dart';
import 'package:e_prescription/controllers/prescription_controller/prescription_rx_controller/quick_tech_electrotherapy_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/models/rx_models/electrotherapy.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final electrotherapyController =
    locator.get<QuickTechElectrotherapyController>();
final themeController = locator.get<QuickTechThemeController>();

Widget customElectrothrerapy() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (electrotherapyController.electrotherapyCategories.isEmpty) {
      electrotherapyController.fetchElectroTherapies();
    }
  });
  return Card(
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
      shape: OutlineInputBorder(
        borderSide: BorderSide(
          width: 1.5,
          color:
              themeController.isDay.value
                  ? QuickTechAppColors.lightmaincolor
                  : QuickTechAppColors.darkmaincolor,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
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
      title: Text(
        'Electrotherapy',
        style: myStyle(
          16,
          themeController.isDay.value
              ? QuickTechAppColors.lightmaintextcolor
              : QuickTechAppColors.darkmaintextcolor,
          FontWeight.bold,
        ),
      ),
      initiallyExpanded: false,
      children:
          electrotherapyController.electrotherapyCategories.isEmpty
              ? [Center(child: CircularProgressIndicator())]
              : [
                ...electrotherapyController
                    .electrotherapyCategories
                    .first
                    .options
                    .map(ElectetherapiesExpandionTile)
                    .toList(),
                customElectroOthersCard(),
              ],
    ),
  );
}

Widget customElectroOthersCard() {
  // Draft state lives on the controller (not as a local variable here) so it
  // survives rebuilds triggered by unrelated reactive changes in this section.
  final activeInputIndex = electrotherapyController.activeInputIndex;
  final tempControllers = electrotherapyController.tempControllers;

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
                              : QuickTechAppColors.darkmaintextcolor.withValues(
                                alpha: 0.6,
                              ),
                          FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          themeController.isDay.value
                              ? QuickTechAppColors.lightmaincolor.withValues(
                                alpha: 0.1,
                              )
                              : QuickTechAppColors.darkmaincolor.withValues(
                                alpha: 0.2,
                              ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FloatingActionButton.small(
                      heroTag: 'addExtraElectro',
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
                              ? QuickTechAppColors.lightmaincolor.withValues(
                                alpha: 0.3,
                              )
                              : QuickTechAppColors.darkmaincolor.withValues(
                                alpha: 0.3,
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
                            // Horizontal layout for wide screens
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
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
                                          ? QuickTechAppColors
                                              .lightmaintextcolor
                                              .withValues(alpha: 0.7)
                                          : QuickTechAppColors.darkmaintextcolor
                                              .withValues(alpha: 0.7),
                                      FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.check_rounded, size: 18),
                                  label: Text('Save'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        themeController.isDay.value
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
                                    final plainText =
                                        tempControllers[idx].text.trim();
                                    if (plainText.isNotEmpty) {
                                      final htmlText = convertToHtmlParagraphs(
                                        plainText,
                                      );
                                      electrotherapyController
                                          .extraElectrotherapies
                                          .add(htmlText);
                                      electrotherapyController
                                          .extraTherapyControllers
                                          .add(
                                            TextEditingController(
                                              text: htmlText,
                                            ),
                                          );
                                    }
                                    tempControllers[idx].dispose();
                                    tempControllers.removeAt(idx);
                                    activeInputIndex.value = -1;
                                  },
                                ),
                              ],
                            );
                          } else {
                            // Vertical layout for narrow screens
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: Icon(Icons.check_rounded, size: 18),
                                    label: Text('Save'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          themeController.isDay.value
                                              ? QuickTechAppColors
                                                  .lightmaincolor
                                              : QuickTechAppColors
                                                  .darkmaincolor,
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
                                      final plainText =
                                          tempControllers[idx].text.trim();
                                      if (plainText.isNotEmpty) {
                                        final htmlText =
                                            convertToHtmlParagraphs(plainText);
                                        electrotherapyController
                                            .extraElectrotherapies
                                            .add(htmlText);
                                        electrotherapyController
                                            .extraTherapyControllers
                                            .add(
                                              TextEditingController(
                                                text: htmlText,
                                              ),
                                            );
                                      }
                                      tempControllers[idx].dispose();
                                      tempControllers.removeAt(idx);
                                      activeInputIndex.value = -1;
                                    },
                                  ),
                                ),
                                SizedBox(height: 8),
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
                                            ? QuickTechAppColors
                                                .lightmaintextcolor
                                                .withValues(alpha: 0.7)
                                            : QuickTechAppColors
                                                .darkmaintextcolor
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
                      ),
                    ],
                  ),
                ),

              // ═══════════════════════════════════════════════════════
              // SAVED ENTRIES SECTION
              // ═══════════════════════════════════════════════════════
              if (electrotherapyController.extraElectrotherapies.isNotEmpty)
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
                            '${electrotherapyController.extraElectrotherapies.length}',
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
                                  : QuickTechAppColors.darkmaincolor.withValues(
                                    alpha: 0.15,
                                  ),
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
                            electrotherapyController
                                .extraElectrotherapies
                                .length,
                            (index) {
                              final therapy =
                                  electrotherapyController
                                      .extraElectrotherapies[index];
                              if (therapy.trim().isEmpty)
                                return SizedBox.shrink();

                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color:
                                      themeController.isDay.value
                                          ? Colors.white.withValues(alpha: 0.6)
                                          : Colors.white.withValues(
                                            alpha: 0.05,
                                          ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.green.shade200.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
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
                                            electrotherapyController
                                                .removeExtraElectrotherapy(
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
              if (electrotherapyController.extraElectrotherapies.isEmpty &&
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

Widget ElectetherapiesExpandionTile(ElectrotherapyOption option) => Obx(() {
  final hasSelections =
      (electrotherapyController.selectedParameters[option.name] ?? {})
          .isNotEmpty;
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Card(
      color:
          themeController.isDay.value
              ? QuickTechAppColors.lightScaffoldColor
              : QuickTechAppColors.darkScaffoldColor,
      elevation: 2,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          ExpansionTile(
            title: Text(
              option.name,
              style: myStyle(
                14,
                themeController.isDay.value
                    ? QuickTechAppColors.lightmaintextcolor
                    : QuickTechAppColors.darkmaintextcolor,
              ),
            ),
            childrenPadding: EdgeInsets.symmetric(horizontal: 16),
            children:
                option.parameters
                    .map(
                      (param) => customElectrothreapyTypes(
                        option.name,
                        param,
                        param.name == 'Area'
                            ? TextInputType.text
                            : TextInputType.number,
                      ),
                    )
                    .toList(),
          ),
          if (hasSelections) selectedItems(option),
        ],
      ),
    ),
  );
});

Widget selectedItems(ElectrotherapyOption option) => Obx(() {
  final optionParams =
      electrotherapyController.selectedParameters[option.name] ?? {};
  return Container(
    padding: EdgeInsets.all(12),
    margin: EdgeInsets.only(bottom: 8, left: 8, right: 8),
    decoration: BoxDecoration(
      color:
          themeController.isDay.value
              ? QuickTechAppColors.greyOpacity2
              : QuickTechAppColors.bkdarktxtfld,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selected :',
              style: myStyle(
                12,
                themeController.isDay.value
                    ? QuickTechAppColors.lightmaincolor
                    : QuickTechAppColors.darkmaintextcolor,
                FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: electrotherapyController.clearAllSelections,
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
        SizedBox(height: 8),
        ...option.parameters
            .where((param) => optionParams.containsKey(param.name))
            .map(
              (param) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${param.name}:',
                        style: myStyle(
                          11,
                          themeController.isDay.value
                              ? QuickTechAppColors.lightmaintextcolor
                                  .withValues(alpha: 0.7)
                              : QuickTechAppColors.darkmaintextcolor,
                          FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          // For Area Options, prefer displaying the Area Names stored in the controller
                          String displayText;
                          if (param.name == 'Area Options') {
                            final names = optionParams['Area Names'];
                            if (names is List && names.isNotEmpty) {
                              displayText = names.join(', ');
                            } else if (optionParams[param.name] is List<int>) {
                              // Fallback: join numeric ids (shouldn't happen often)
                              displayText = (optionParams[param.name] as List)
                                  .join(', ');
                            } else {
                              displayText =
                                  optionParams[param.name]?.toString() ??
                                  'Not selected';
                            }
                          } else {
                            displayText = customselectedValue(
                              optionParams[param.name],
                              param.type,
                            );
                          }
                          return Text(
                            displayText,
                            style: myStyle(
                              10,
                              themeController.isDay.value
                                  ? QuickTechAppColors.lightmaintextcolor
                                  : QuickTechAppColors.darkmaintextcolor,
                              FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    ),
  );
});

String customselectedValue(dynamic value, ParameterType type) =>
    value == null
        ? 'Not selected'
        : (type == ParameterType.multiSelect && value is List
            ? value.join(', ')
            : value.toString());

Widget customElectrothreapyTypes(
  String optionName,
  ElectrotherapyPerameter param,
  TextInputType keyboard,
) {
  switch (param.type) {
    case ParameterType.textInput:
      return customTextField(optionName, param, keyboard);
    case ParameterType.singleSelect:
      return customSingleSelection(optionName, param);
    case ParameterType.multiSelect:
      return customMultiselections(optionName, param);
  }
}

Widget customTextField(
  String optionName,
  ElectrotherapyPerameter param,
  TextInputType keyboard,
) => Padding(
  padding: EdgeInsets.only(bottom: 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            '${param.name}  ',
            style: myStyle(
              13,
              themeController.isDay.value
                  ? QuickTechAppColors.lightmaintextcolor
                  : QuickTechAppColors.darkmaintextcolor,
              FontWeight.bold,
            ),
          ),
          Text(
            param.unit != null ? ' (${param.unit})' : '',
            style: myStyle(
              8,
              themeController.isDay.value
                  ? QuickTechAppColors.lightmaintextcolor
                  : QuickTechAppColors.darkmaintextcolor,
            ),
          ),
        ],
      ),
      SizedBox(height: 6),
      Obx(() {
        final controller =
            electrotherapyController.textControllers[optionName]?[param.name] ??
            TextEditingController();
        return TextField(
          keyboardType: keyboard,
          controller: controller,
          style: myStyle(
            12,
            themeController.isDay.value
                ? QuickTechAppColors.lightmaintextcolor
                : QuickTechAppColors.darkmaintextcolor,
          ),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor:
                themeController.isDay.value
                    ? QuickTechAppColors.bktxtfld
                    : QuickTechAppColors.bkdarktxtfld,
          ),
          onChanged:
              (value) => electrotherapyController.updateParameter(
                optionName,
                param.name,
                value,
              ),
        );
      }),
    ],
  ),
);

Widget customSingleSelection(
  String optionName,
  ElectrotherapyPerameter param,
) => Padding(
  padding: EdgeInsets.only(bottom: 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        param.name,
        style: myStyle(
          13,
          themeController.isDay.value
              ? QuickTechAppColors.lightmaintextcolor
              : QuickTechAppColors.darkmaintextcolor,
          FontWeight.bold,
        ),
      ),
      SizedBox(height: 6),
      Obx(() {
        final optionParams =
            electrotherapyController.selectedParameters[optionName] ?? {};
        return DropdownButtonFormField<String>(
          dropdownColor:
              themeController.isDay.value
                  ? QuickTechAppColors.lightScaffoldColor
                  : QuickTechAppColors.darkScaffoldColor,
          initialValue: optionParams[param.name]?.toString(),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor:
                themeController.isDay.value
                    ? QuickTechAppColors.bktxtfld
                    : QuickTechAppColors.bkdarktxtfld,
          ),
          items:
              param.options!
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        style: myStyle(
                          12,
                          themeController.isDay.value
                              ? QuickTechAppColors.lightmaintextcolor
                              : QuickTechAppColors.darkmaintextcolor,
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
          onChanged:
              (value) => electrotherapyController.updateParameter(
                optionName,
                param.name,
                value,
              ),
          hint: Text(
            'Select an option',
            style: myStyle(
              12,
              themeController.isDay.value
                  ? QuickTechAppColors.lightmaintextcolor
                  : QuickTechAppColors.darkmaintextcolor.withValues(alpha: 0.7),
            ),
          ),
        );
      }),
    ],
  ),
);
Widget customMultiselections(
  String optionName,
  ElectrotherapyPerameter param,
) => Padding(
  padding: EdgeInsets.only(bottom: 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        param.name,
        style: myStyle(
          13,
          themeController.isDay.value
              ? QuickTechAppColors.lightmaintextcolor
              : QuickTechAppColors.darkmaintextcolor,
          FontWeight.bold,
        ),
      ),
      SizedBox(height: 6),
      Obx(() {
        final optionParams =
            electrotherapyController.selectedParameters[optionName] ?? {};
        final currentSelection = List<int>.from(
          optionParams[param.name] is List<int> ? optionParams[param.name] : [],
        );
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              param.options!.asMap().entries.map((entry) {
                final optionIndex = entry.key;
                final option = entry.value;
                final selectedId =
                    param.areaIds != null && optionIndex < param.areaIds!.length
                        ? param.areaIds![optionIndex]
                        : -1;
                final isSelected =
                    selectedId >= 0 && currentSelection.contains(selectedId);
                return FilterChip(
                  backgroundColor:
                      themeController.isDay.value
                          ? QuickTechAppColors.lightScaffoldColor
                          : QuickTechAppColors.darkScaffoldColor,
                  label: Text(
                    option,
                    style: myStyle(
                      10,
                      themeController.isDay.value
                          ? QuickTechAppColors.lightmaintextcolor
                          : QuickTechAppColors.darkmaintextcolor,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newSelection = List<int>.from(currentSelection);

                    if (selectedId >= 0) {
                      selected
                          ? newSelection.add(selectedId)
                          : newSelection.remove(selectedId);
                      print(
                        'DEBUG UI: optionName=$optionName, paramName=${param.name}, selected area IDs=$newSelection',
                      );

                      if (newSelection.isEmpty) {
                        final paramsCopy = Map<String, dynamic>.from(
                          optionParams,
                        );
                        paramsCopy.remove(param.name);
                        electrotherapyController
                                .selectedParameters[optionName] =
                            paramsCopy;
                        print('DEBUG UI: Removed param ${param.name}');
                      } else {
                        electrotherapyController.updateParameter(
                          optionName,
                          param.name,
                          newSelection,
                        );
                        print(
                          'DEBUG UI: Updated param ${param.name} with area IDs: $newSelection',
                        );
                      }
                    }
                  },
                  selectedColor:
                      themeController.isDay.value
                          ? QuickTechAppColors.lightmaincolor
                          : QuickTechAppColors.darkmaincolor,
                  checkmarkColor:
                      themeController.isDay.value
                          ? QuickTechAppColors.black
                          : QuickTechAppColors.white,
                  labelStyle: TextStyle(
                    color:
                        isSelected
                            ? Colors.blue.shade800
                            : Colors.grey.shade800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
        );
      }),
    ],
  ),
);
