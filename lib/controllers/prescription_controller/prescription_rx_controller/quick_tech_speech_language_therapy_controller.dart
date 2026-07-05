import 'dart:convert';
import 'package:e_prescription/controllers/prescription_controller/patient_info_controller/patient_info_controller.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/models/rx_models/speech_language_therapy.dart';
import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
PatientInfoController patientInfoController = locator.get<PatientInfoController>();
var token=QuickTechAuthStorageService.getToken();
class QuickTechSpeechLanguageTherapyController extends GetxController {
  var categories = <SpeechLanguageTherapy>[].obs;
  var selectedTherapies = <String>[].obs;
  
  // ✅ NEW: Support multiple custom therapies
  final customTherapies = <String>[].obs;
  final customTherapyControllers = <TextEditingController>[].obs;

  // Draft state for the "Extra Therapy" add form. Lives on the controller
  // (not as a local variable in the widget builder) so it survives rebuilds
  // triggered by unrelated reactive changes elsewhere in the Rx section.
  final RxInt activeInputIndex = (-1).obs;
  final RxList<TextEditingController> tempControllers = <TextEditingController>[].obs;

  /// Track expansion of Speech and Language Therapy panel
  var isMiscellaneousTherapyClicked = false.obs;

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
    print('[SpeechLanguageController] Added new custom therapy field. Total: ${customTherapies.length}');
  }

  /// ✅ Remove custom therapy at index
  void removeCustomTherapy(int index) {
    if (index >= 0 && index < customTherapyControllers.length) {
      customTherapyControllers[index].dispose();
      customTherapyControllers.removeAt(index);
      customTherapies.removeAt(index);
      print('[SpeechLanguageController] Removed custom therapy at index $index. Total: ${customTherapies.length}');
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
      final response = await http.get(Uri.parse('${Api.getSpeechLangTherapyPrescription}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List therapies = data['speech_and_language_therapies'];
        categories.assignAll(
          therapies.map((e) => SpeechLanguageTherapy.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      print("Error fetching therapies: $e");
    }
  }

  void toggleCategorySelection(int index) {
    final category = categories[index];
    category.isSelected = !category.isSelected;

    if (!category.isSelected && category.subcategories != null) {
      for (var sub in category.subcategories!) {
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
    final sub = category.subcategories![subcategoryIndex];
    sub.isSelected = !sub.isSelected;

    category.isSelected = category.subcategories!.any((s) => s.isSelected);

    _updateSelectedTherapies();
    categories.refresh();
    selectedTherapies.refresh();
  }

  void updateSubcategoryNote(int categoryIndex, int subcategoryIndex, String note) {
    final sub = categories[categoryIndex].subcategories![subcategoryIndex];
    sub.note = note;
    categories.refresh();
  }

  void _updateSelectedTherapies() {
    selectedTherapies.clear();
    for (var category in categories) {
      if (category.isSelected) {
        if (category.subcategories != null) {
          final selectedSubs = category.subcategories!.where((s) => s.isSelected).toList();
          if (selectedSubs.isNotEmpty) {
            for (var sub in selectedSubs) {
              if (sub.note != null && sub.note!.isNotEmpty) {
                selectedTherapies.add('${category.name}: ${sub.name} (Note: ${sub.note})');
              } else {
                selectedTherapies.add('${category.name}: ${sub.name}');
              }
            }
          } else {
            selectedTherapies.add(category.name);
          }
        } else {
          selectedTherapies.add(category.name);
        }
      }
    }
  }

  void clearAllSelections() {
    for (var category in categories) {
      category.isSelected = false;
      if (category.subcategories != null) {
        for (var sub in category.subcategories!) {
          sub.isSelected = false;
          sub.note = null;
        }
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

 
  bool hasSelectedTherapies() {
    return selectedTherapies.isNotEmpty;
  }


  int getSelectedCategoriesCount() {
    int count = 0;
    for (var category in categories) {
      if (category.isSelected) {
        if (category.subcategories != null && category.subcategories!.isNotEmpty) {
          // Check if any subcategories are selected
          bool hasSelectedSubcategories = category.subcategories!.any((s) => s.isSelected);
          if (hasSelectedSubcategories) count++;
        } else {
          // Category without subcategories
          count++;
        }
      }
    }
    return count;
  }

  /// Print selected therapies data for debugging
  void printSelectedTherapiesData() {
    print('Selected Speech & Language Therapies Data:');
    
    List<Map<String, dynamic>> selectedData = [];
    
    for (var category in categories) {
      if (category.isSelected) {
        List<int?> therapySubcategoryIds = [];
        List<String?> notes = [];

        if (category.subcategories != null && category.subcategories!.isNotEmpty) {
          for (var sub in category.subcategories!) {
            if (sub.isSelected) {
              therapySubcategoryIds.add(sub.id);
              notes.add(sub.note != null && sub.note!.isNotEmpty ? sub.note : null);
            }
          }
        }

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
    
    print('Total selected categories: ${selectedData.length}');
    for (var data in selectedData) {
      print(jsonEncode(data));
    }
  }

  /// ================= Submit Selected Therapies =================
  Future<void> submitSpeechLang() async {
  
    int successfulSubmissions = 0;
    List<String> errorMessages = [];

    for (var category in categories) {
      // Only process categories that are selected
      if (category.isSelected) {
        
        List<int?> therapySubcategoryIds = [];
        List<String?> notes = [];

        // Check if category has subcategories
        if (category.subcategories != null && category.subcategories!.isNotEmpty) {
          // Only include selected subcategories
          for (var sub in category.subcategories!) {
            if (sub.isSelected) {
              therapySubcategoryIds.add(sub.id);
              notes.add(sub.note != null && sub.note!.isNotEmpty ? sub.note : null);
            }
          }
          
          // Skip if category is selected but no subcategories are selected
          if (therapySubcategoryIds.isEmpty) continue;
        }

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
      Get.snackbar("Error", "Failed to store speech & language therapies$errorMsg");
    }
  }

  /// ================= Helpers =================
  bool isSpecialTherapy(String name) {
    // Define your special therapies here
    final specialList = [
      "Aphasia Therapy",
      "Dysarthria Therapy",
      "Voice Therapy",
      "Stuttering Therapy"
    ];
    return specialList.contains(name);
  }
}
