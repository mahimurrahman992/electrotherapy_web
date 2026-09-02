import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/controllers/prescription_controller/patient_info_controller/patient_info_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/cheif_complain_controller.dart';
import 'package:e_prescription/screens/add_prescription/widgets/quick_tech_prescription_widgets.dart';
import 'package:e_prescription/widgets/quick_tech_add_multiple_items_dialog.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';

final CheifComplainController prescrptionController = locator.get<CheifComplainController>();
final QuickTechThemeController themeController = locator.get<QuickTechThemeController>();
final PatientInfoController patientInfoController = locator.get<PatientInfoController>();

class ChiefComplaintSection extends StatelessWidget {
  const ChiefComplaintSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChiefComplaintsDropdown(),
        const SizedBox(height: 10),

        // Selected Chief Complaints Chips
        Obx(
          () => Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children:
                prescrptionController.selectedComplaints.map((complaint) {
                  return Chip(
                    deleteIconColor:
                        themeController.isDay.value
                            ? QuickTechAppColors.bkdarktxtfld
                            : QuickTechAppColors.whiteOpacity,
                    backgroundColor:
                        themeController.isDay.value
                            ? QuickTechAppColors.whiteOpacity
                            : QuickTechAppColors.darktxtfieldcolor,
                    label: Text(
                      complaint,
                      style: myStyle(
                        14,
                        themeController.isDay.value
                            ? QuickTechAppColors.lightmaintextcolor
                            : QuickTechAppColors.darkmaintextcolor,
                        FontWeight.bold,
                      ),
                    ),
                    onDeleted:
                        () => prescrptionController.removeComplaint(complaint),
                  );
                }).toList(),
          ),
        ),

        // Sub-complaints for each chief complaint
        Obx(() {
          return Column(
            children:
                prescrptionController.selectedComplaints.map((chiefComplaint) {
                  final subList = prescrptionController.getSubComplaints(
                    chiefComplaint,
                  );
                  if (subList.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sub-complaints for $chiefComplaint',
                          style: myStyle(
                            15,
                            themeController.isDay.value
                                ? QuickTechAppColors.lightmaintextcolor
                                : QuickTechAppColors.darkmaintextcolor,
                            FontWeight.w500,
                          ),
                        ),
                        Obx(
                          () => Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children:
                                subList.map((subComplaint) {
                                  return ChoiceChip(
                                    checkmarkColor:
                                        themeController.isDay.value
                                            ? QuickTechAppColors
                                                .lightmaintextcolor
                                                .withValues(alpha: 0.5)
                                            : QuickTechAppColors
                                                .darkmaintextcolor,
                                    side: BorderSide(
                                      color:
                                          prescrptionController
                                                      .selectedSubComplaints[chiefComplaint]
                                                      ?.contains(
                                                        subComplaint,
                                                      ) ??
                                                  false
                                              ? QuickTechAppColors
                                                  .lightmaincolor
                                              : QuickTechAppColors
                                                  .darkmaincolor,
                                      width:
                                          prescrptionController
                                                      .selectedSubComplaints[chiefComplaint]
                                                      ?.contains(
                                                        subComplaint,
                                                      ) ??
                                                  false
                                              ? 2
                                              : 0,
                                    ),
                                    selectedColor:
                                        themeController.isDay.value
                                            ? QuickTechAppColors.greyOpacity2
                                            : QuickTechAppColors.bkdarktxtfld
                                                .withValues(alpha: 0.9),
                                    backgroundColor:
                                        themeController.isDay.value
                                            ? QuickTechAppColors.whiteOpacity
                                            : QuickTechAppColors
                                                .darktxtfieldcolor,
                                    label: Text(
                                      subComplaint,
                                      style: myStyle(
                                        12,
                                        prescrptionController
                                                    .selectedSubComplaints[chiefComplaint]
                                                    ?.contains(subComplaint) ??
                                                false
                                            ? themeController.isDay.value
                                                ? QuickTechAppColors
                                                    .lightmaintextcolor
                                                : QuickTechAppColors
                                                    .darkmaintextcolor
                                            : themeController.isDay.value
                                            ? QuickTechAppColors
                                                .lightmaintextcolor
                                            : QuickTechAppColors
                                                .darkmaintextcolor,
                                      ),
                                    ),
                                    selected:
                                        prescrptionController
                                            .selectedSubComplaints[chiefComplaint]
                                            ?.contains(subComplaint) ??
                                        false,
                                    onSelected: (selected) {
                                      if (selected) {
                                        prescrptionController.addSubComplaint(
                                          chiefComplaint,
                                          subComplaint,
                                        );
                                      } else {
                                        prescrptionController
                                            .removeSubComplaint(
                                              chiefComplaint,
                                              subComplaint,
                                            );
                                      }
                                    },
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                }).toList(),
          );
        }),

        // Other complaint details field
        if (prescrptionController.selectedComplaints.contains('Other'))
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: customTextField(
              'Other Complaint Details',
              prescrptionController.otherComplaint,
            ),
          ),

  
      
      ],
    );
  }
}

// Chief Complaints Dropdown Widget
class ChiefComplaintsDropdown extends StatelessWidget {
  const ChiefComplaintsDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => prescrptionController.toggleComplaintDropdown(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    themeController.isDay.value
                        ? QuickTechAppColors.white
                        : QuickTechAppColors.darktxtfieldcolor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      themeController.isDay.value
                          ? QuickTechAppColors.lightmaincolor
                          : QuickTechAppColors.darkmaincolor,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chief Complaints',

                    style: myStyle(
                      14,
                      themeController.isDay.value
                          ? QuickTechAppColors.lightmaintextcolor
                          : QuickTechAppColors.darkmaintextcolor,
                      FontWeight.normal,
                    ),
                  ),
                  Icon(
                    prescrptionController.isComplaintDropdownOpen.value
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color:
                        themeController.isDay.value
                            ? QuickTechAppColors.lightmaincolor
                            : QuickTechAppColors.darkmaincolor,
                  ),
                ],
              ),
            ),
          ),
          if (prescrptionController.isComplaintDropdownOpen.value)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    themeController.isDay.value
                        ? QuickTechAppColors.white
                        : QuickTechAppColors.darktxtfieldcolor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      themeController.isDay.value
                          ? QuickTechAppColors.lightmaincolor
                          : QuickTechAppColors.darkmaincolor,
                ),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                children: [
                  // Search field
                  TextField(
                    style: myStyle(
                      14,
                      themeController.isDay.value
                          ? QuickTechAppColors.lightmaintextcolor
                          : QuickTechAppColors.darkmaintextcolor,
                      FontWeight.normal,
                    ),
                    controller:
                        prescrptionController.cheifComplainsearchController,
                    onChanged: (value) {
                      prescrptionController.complaintSearchText.value = value;
                      prescrptionController.searchChiefComplaints(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search complaints...',
                      hintStyle: myStyle(
                        14,
                        themeController.isDay.value
                            ? QuickTechAppColors.lightmaintextcolor.withValues(alpha:
                              0.5,
                            )
                            : QuickTechAppColors.darkmaintextcolor.withValues(alpha:
                              0.5,
                            ),
                        FontWeight.normal,
                      ),
                      border: InputBorder.none,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search,
                            color:
                                themeController.isDay.value
                                    ? QuickTechAppColors.lightmaincolor
                                    : QuickTechAppColors.darkmaincolor,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add,
                              color:
                                  themeController.isDay.value
                                      ? QuickTechAppColors.lightmaincolor
                                      : QuickTechAppColors.darkmaincolor,
                            ),
                            onPressed: () {
                              showAddMultipleItemsDialog(
                                context: context,
                                title: 'Add Multiple Chief Complaints',
                                hintText: 'Enter complaint name',
                                addButtonLabel: 'Add Complaint',
                                addAllButtonLabel: 'Add All Complaints',
                                onItemsAdded: (items) {
                                  for (var complaint in items) {
                                    prescrptionController.addComplaint(complaint);
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  // Complaints list
                  Obx(() {
                    if (prescrptionController.isLoadingChiefComplaints.value) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final searchText =
                        prescrptionController.complaintSearchText.value;
                    if (prescrptionController.filteredChiefComplaints.isEmpty) {
                      return Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: Text('No complaints found.')),
                          ),
                          if (searchText.isNotEmpty) 
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Add "${searchText}"',
                                      style: myStyle(
                                        12,
                                        themeController.isDay.value
                                            ? QuickTechAppColors
                                                .lightmaintextcolor
                                            : QuickTechAppColors
                                                .darkmaintextcolor,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      color:
                                          themeController.isDay.value
                                              ? QuickTechAppColors
                                                  .lightmaintextcolor
                                              : QuickTechAppColors
                                                  .darkmaintextcolor,
                                    ),
                                    onPressed: () {
                                      prescrptionController.addComplaint(
                                        searchText,
                                      );
                                      prescrptionController
                                          .cheifComplainsearchController
                                          .clear();
                                      prescrptionController
                                          .complaintSearchText
                                          .value = '';
                                    },
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount:
                                prescrptionController
                                    .filteredChiefComplaints
                                    .length,
                            itemBuilder: (context, index) {
                              final complaint =
                                  prescrptionController
                                      .filteredChiefComplaints[index];
                              return ListTile(
                                title: Text(
                                  complaint,
                                  style: myStyle(
                                    14,
                                    themeController.isDay.value
                                        ? QuickTechAppColors.lightmaintextcolor
                                        : QuickTechAppColors.darkmaintextcolor,
                                    FontWeight.normal,
                                  ),
                                ),
                                onTap: () {
                                  prescrptionController.addComplaint(complaint);
                                  prescrptionController
                                      .cheifComplainsearchController
                                      .clear();
                                  prescrptionController
                                      .complaintSearchText
                                      .value = '';
                                },
                              );
                            },
                          ),
                        ),
                        if (searchText.isNotEmpty &&
                            !prescrptionController.filteredChiefComplaints
                                .contains(searchText))
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Add "${searchText}"',
                                    style: myStyle(
                                      12,
                                      themeController.isDay.value
                                          ? QuickTechAppColors
                                              .lightmaintextcolor
                                          : QuickTechAppColors
                                              .darkmaintextcolor,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    color:
                                        themeController.isDay.value
                                            ? QuickTechAppColors
                                                .lightmaintextcolor
                                            : QuickTechAppColors
                                                .darkmaintextcolor,
                                  ),
                                  onPressed: () {
                                    prescrptionController.addComplaint(
                                      searchText,
                                    );
                                    prescrptionController
                                        .cheifComplainsearchController
                                        .clear();
                                    prescrptionController
                                        .complaintSearchText
                                        .value = '';
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
              ),
            ),
        ],
      );
    });
  }
}