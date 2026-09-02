
import 'dart:convert';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/controllers/prescription_controller/patient_info_controller/patient_info_controller.dart';
import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:e_prescription/models/rx_models/miscellaneous_therapy.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';

final PatientInfoController patientInfoController = locator.get<PatientInfoController>();
var token=QuickTechAuthStorageService.getToken();
class QuickTechMiscellaneousTherapyController extends GetxController {
  var categories = <MiscellaneousTherapy>[].obs;
  var selectedTherapies = <String>[].obs;
  var isMiscellaneousTherapyClicked = false.obs;
  
  // ✅ NEW: Support multiple custom therapies
  final customTherapies = <String>[].obs;
  final customTherapyControllers = <TextEditingController>[].obs;

  // Draft state for the "Extra Therapy" add form. Lives on the controller
  // (not as a local variable in the widget builder) so it survives rebuilds
  // triggered by unrelated reactive changes elsewhere in the Rx section.
  final RxInt activeInputIndex = (-1).obs;
  final RxList<TextEditingController> tempControllers = <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTherapies();
  }

  @override
  void onClose() {
    customTherapyControllers.forEach((controller) => controller.dispose());
    tempControllers.forEach((controller) => controller.dispose());
    super.onClose();
  }

  /// ✅ Add a new custom therapy field
  void addCustomTherapy() {
    customTherapyControllers.add(TextEditingController());
    customTherapies.add('');
    print('[MiscellaneousController] Added new custom therapy field. Total: ${customTherapies.length}');
  }

  /// ✅ Remove custom therapy at index
  void removeCustomTherapy(int index) {
    if (index >= 0 && index < customTherapyControllers.length) {
      customTherapyControllers[index].dispose();
      customTherapyControllers.removeAt(index);
      customTherapies.removeAt(index);
      print('[MiscellaneousController] Removed custom therapy at index $index. Total: ${customTherapies.length}');
    }
  }

  /// ✅ Update custom therapy value
  void updateCustomTherapy(int index, String value) {
    if (index >= 0 && index < customTherapies.length) {
      customTherapies[index] = value;
    }
  }

  /// ✅ Get all non-empty custom therapies
  List<String> getFilledCustomTherapies() {
    return customTherapies.where((e) => e.trim().isNotEmpty).toList();
  }

  Future<void> fetchTherapies() async {
    try {
      final response = await http.get(Uri.parse('${Api.getMiscellaneousPrescription}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List therapies = data['miscellaneous_therapies'];
        categories.assignAll(therapies.map((e) => MiscellaneousTherapy.fromJson(e)).toList());
      }
    } catch (e) {
      // handle error
    }
  }

  void toggleCategorySelection(int index) {
    final category = categories[index];
    category.isSelected = !category.isSelected;
    // If deselecting, also deselect all subcategories
    if (!category.isSelected) {
      for (var sub in category.subcategories) {
        sub.isSelected = false;
        sub.note = null;
      }
    }
    _updateSelectedTherapies();
    categories.refresh();
    selectedTherapies.refresh();
  }

  void toggleSubcategorySelection(int categoryIndex, int subcategoryIndex) {
    final category = categories[categoryIndex];
    final sub = category.subcategories[subcategoryIndex];
    sub.isSelected = !sub.isSelected;
    // If any subcategory is selected, mark category as selected
    category.isSelected = category.subcategories.any((s) => s.isSelected);
    _updateSelectedTherapies();
    categories.refresh();
    selectedTherapies.refresh();
  }

  void updateSubcategoryNote(int categoryIndex, int subcategoryIndex, String note) {
    final category = categories[categoryIndex];
    final sub = category.subcategories[subcategoryIndex];
    sub.note = note;
    _updateSelectedTherapies();
    categories.refresh();
    selectedTherapies.refresh();
  }

  void _updateSelectedTherapies() {
    selectedTherapies.clear();
    for (var category in categories) {
      if (category.isSelected) {
        final selectedSubs = category.subcategories.where((s) => s.isSelected).toList();
        if (selectedSubs.isNotEmpty) {
          for (var sub in selectedSubs) {
            if (sub.valueType == 'With note' && (sub.note != null && sub.note!.isNotEmpty)) {
              selectedTherapies.add('${category.name}: ${sub.name} (Note: ${sub.note})');
            } else {
              selectedTherapies.add('${category.name}: ${sub.name}');
            }
          }
        } else {
          selectedTherapies.add(category.name);
        }
      }
    }
  }

  bool isSubcategoryWithNote(int categoryIndex, int subcategoryIndex) {
    final sub = categories[categoryIndex].subcategories[subcategoryIndex];
    return sub.valueType == 'With note';
  }

  void clearAllSelections() {
    for (var category in categories) {
      category.isSelected = false;
      for (var sub in category.subcategories) {
        sub.isSelected = false;
        sub.note = null;
      }
    }
    selectedTherapies.clear();    // ✅ NEW: Clear custom therapies
    customTherapyControllers.forEach((controller) => controller.dispose());
    customTherapyControllers.clear();
    customTherapies.clear();
    tempControllers.forEach((controller) => controller.dispose());
    tempControllers.clear();
    activeInputIndex.value = -1;
    categories.refresh();
    selectedTherapies.refresh();
  }

  /// Check if any miscellaneous therapies are selected
  bool hasSelectedTherapies() {
    return selectedTherapies.isNotEmpty;
  }

  /// Get count of selected therapy categories
  int getSelectedCategoriesCount() {
    int count = 0;
    for (var category in categories) {
      if (category.isSelected && category.subcategories.any((s) => s.isSelected)) {
        count++;
      }
    }
    return count;
  }

  /// Print selected therapies data for debugging
  void printSelectedTherapiesData() {
    print('Selected Miscellaneous Therapies Data:');
    
    List<Map<String, dynamic>> selectedData = [];
    
    for (var category in categories) {
      if (category.isSelected && category.subcategories.isNotEmpty) {
        List<int?> therapySubcategoryIds = [];
        List<String?> notes = [];

        for (var sub in category.subcategories) {
          if (sub.isSelected) {
            therapySubcategoryIds.add(sub.id);
            notes.add(sub.note != null && sub.note!.isNotEmpty ? sub.note : null);
          }
        }

        if (therapySubcategoryIds.isNotEmpty) {
          Map<String, dynamic> categoryData = {
            "category_name": category.name,
            "category_id": category.id,
            "patient_id": patientInfoController.patientId.value,
            "manualSpeechIds": [category.id],
            "therapySubcategoryIds": therapySubcategoryIds,
            "note": notes,
          };
          selectedData.add(categoryData);
        }
      }
    }
    
    print('Total selected categories: ${selectedData.length}');
    for (var data in selectedData) {
      print(jsonEncode(data));
    }
  }
  Future<void> submitMiscellaneous() async {
    // If no therapies are selected, show info message (since it's optional)
    if (!hasSelectedTherapies()) {
      QuickTechSnackbar.info("No miscellaneous therapies selected - skipping this section");
      return;
    }

    int successfulSubmissions = 0;
    List<String> errorMessages = [];

    for (var category in categories) {
      // Only process categories that are selected AND have selected subcategories
      if (category.isSelected && category.subcategories.isNotEmpty) {
        
        List<int?> therapySubcategoryIds = [];
        List<String?> notes = [];

        // Only include selected subcategories
        for (var sub in category.subcategories) {
          if (sub.isSelected) {
            therapySubcategoryIds.add(sub.id);
            notes.add(sub.note != null && sub.note!.isNotEmpty ? sub.note : null);
          }
        }

        // Skip if no subcategories are selected
        if (therapySubcategoryIds.isEmpty) continue;

        Map<String, dynamic> payload = {
          "patient_id": patientInfoController.patientId.value,
          "manualSpeechIds": [category.id],
          "therapySubcategoryIds": therapySubcategoryIds,
          "note": notes,
        };

        final url = Uri.parse(Api.updateotherallPresc);

        try {
          final response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            successfulSubmissions++;
            print("Category '${category.name}' submitted successfully");
          } else {
            errorMessages.add("${category.name}: ${response.body}");
            print("Failed to submit category '${category.name}': ${response.statusCode} - ${response.body}");
          }
        } catch (e) {
          errorMessages.add("${category.name}: $e");
          print("Error submitting category '${category.name}': $e");
        }
      }
    }

    // Show result based on what happened
    if (successfulSubmissions > 0) {
      // Individual success snackbar removed - handled by main prescription controller
      printSelectedTherapiesData();
    } else {
      String errorMsg = errorMessages.isNotEmpty ? ': ${errorMessages.first}' : '';
      QuickTechSnackbar.error("Failed to store miscellaneous therapies$errorMsg");
    }
  }
}
