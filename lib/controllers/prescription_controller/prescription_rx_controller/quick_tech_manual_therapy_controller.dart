import 'dart:convert';
import 'package:e_prescription/controllers/prescription_controller/patient_info_controller/patient_info_controller.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/models/rx_models/therapy_model.dart';
import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

PatientInfoController patientInfoController = locator.get<PatientInfoController>();

class QuickTechManualTherapyController extends GetxController {
  // Search state
  final TextEditingController searchController = TextEditingController();
  var searchQuery = ''.obs;

  List<TherapyCategory> get filteredCategories {
    if (searchQuery.isEmpty) {
      return categories;
    }
    return categories.where((category) {
      return category.name.toLowerCase().contains(searchQuery.value) ||
          (category.subcategories?.any(
                (sub) => sub.name.toLowerCase().contains(searchQuery.value),
              ) ??
              false);
    }).toList();
  }

  void onSearchChanged() {
    searchQuery.value = searchController.text.toLowerCase();
  }

  @override
  void onInit() {
    super.onInit();
    fetchManualTherapies();
    searchController.addListener(onSearchChanged);
  }

  @override
  void onClose() {
    searchController.dispose();
    // ✅ NEW: Dispose custom therapy controllers
    customTherapyControllers.forEach((controller) => controller.dispose());
    tempControllers.forEach((controller) => controller.dispose());
    super.onClose();
  }

  /// ✅ Add a new custom therapy field
  void addCustomTherapy() {
    customTherapyControllers.add(TextEditingController());
    customTherapies.add('');
    print('[ManualController] Added new custom therapy field. Total: ${customTherapies.length}');
  }

  /// ✅ Remove custom therapy at index
  void removeCustomTherapy(int index) {
    if (index >= 0 && index < customTherapyControllers.length) {
      customTherapyControllers[index].dispose();
      customTherapyControllers.removeAt(index);
      customTherapies.removeAt(index);
      print('[ManualController] Removed custom therapy at index $index. Total: ${customTherapies.length}');
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

  var categories = <TherapyCategory>[].obs;
  var selectedTherapies = <String>[].obs;
  var isManualTherapyClicked = false.obs;
  
  // ✅ NEW: Support multiple custom therapies (like electrotherapy)
  final customTherapies = <String>[].obs;  // List of custom therapy names
  final customTherapyControllers = <TextEditingController>[].obs;  // Controllers for each field

  // Draft state for the "Extra Therapy" add form. Lives on the controller
  // (not as a local variable in the widget builder) so it survives rebuilds
  // triggered by unrelated reactive changes elsewhere in the Rx section.
  final RxInt activeInputIndex = (-1).obs;
  final RxList<TextEditingController> tempControllers = <TextEditingController>[].obs;

  Future<void> fetchManualTherapies() async {
    final url = Uri.parse('${Api.getManualTherapyPrescription}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> therapies = data['manual_therapies'];
        categories.assignAll(
          therapies.map((e) => TherapyCategory.fromApiJson(e)).toList(),
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load manual therapies: $e");
    }
  }

  void toggleCategorySelection(int index) {
    categories[index].isSelected = !categories[index].isSelected;

    // If category has no subcategories, add/remove it from selectedTherapies
    if (categories[index].subcategories == null) {
      if (categories[index].isSelected) {
        selectedTherapies.add(categories[index].name);
      } else {
        selectedTherapies.remove(categories[index].name);
      }
    }

    categories.refresh();
    selectedTherapies.refresh();
  }

  void toggleSubcategorySelection(int categoryIndex, int subcategoryIndex) {
    final category = categories[categoryIndex];

    if (category.subcategorySelections != null) {
      category.subcategorySelections![subcategoryIndex] = !category.subcategorySelections![subcategoryIndex];

      final fullCategoryName = category.name;

      List<String> selectedSubcategories = [];
      for (int i = 0; i < category.subcategorySelections!.length; i++) {
        if (category.subcategorySelections![i]) {
          selectedSubcategories.add(category.subcategories![i].name);
        }
      }

      final fullName = selectedSubcategories.isNotEmpty
          ? "$fullCategoryName: ${selectedSubcategories.join(', ')}"
          : fullCategoryName;

      selectedTherapies.removeWhere((item) => item.startsWith(fullCategoryName));

      if (selectedSubcategories.isNotEmpty || category.isSelected) {
        selectedTherapies.add(fullName);
      }

      bool anySubSelected = category.subcategorySelections!.any((selected) => selected);
      category.isSelected = anySubSelected;

      categories.refresh();
      selectedTherapies.refresh();
    }
  }

  void updateSubcategoryNote(
    int categoryIndex,
    int subcategoryIndex,
    String note,
  ) {
    categories[categoryIndex].subcategoryNotes?[subcategoryIndex] = note;
    categories.refresh();
  }

  void clearAllSelections() {
    for (var category in categories) {
      category.isSelected = false;
      if (category.subcategorySelections != null) {
        for (int i = 0; i < category.subcategorySelections!.length; i++) {
          category.subcategorySelections![i] = false;
        }
      }
      if (category.subcategoryNotes != null) {
        for (int i = 0; i < category.subcategoryNotes!.length; i++) {
          category.subcategoryNotes![i] = '';
        }
      }
    }
    selectedTherapies.clear();
    searchController.clear();
    searchQuery.value = '';
    // ✅ NEW: Clear custom therapies
    customTherapyControllers.forEach((controller) => controller.dispose());
    customTherapyControllers.clear();
    customTherapies.clear();
    tempControllers.forEach((controller) => controller.dispose());
    tempControllers.clear();
    activeInputIndex.value = -1;
    categories.refresh();
    selectedTherapies.refresh();
  }

  /// Check if any manual therapies are selected
  bool hasSelectedTherapies() {
    return selectedTherapies.isNotEmpty;
  }

  /// Get count of selected therapy categories
  int getSelectedCategoriesCount() {
    int count = 0;
    for (var category in categories) {
      if (category.isSelected && category.subcategories != null && category.subcategories!.isNotEmpty) {
        // Check if any subcategories are selected
        bool hasSelectedSubcategories = false;
        for (int i = 0; i < category.subcategories!.length; i++) {
          if (category.subcategorySelections![i]) {
            hasSelectedSubcategories = true;
            break;
          }
        }
        if (hasSelectedSubcategories) count++;
      } else if (category.isSelected && category.subcategories == null) {
        // Category without subcategories
        count++;
      }
    }
    return count;
  }

  /// Print selected therapies data for debugging
  void printSelectedTherapiesData() {
    print('Selected Manual Therapies Data:');
    
    List<Map<String, dynamic>> selectedData = [];
    
    for (var category in categories) {
      if (category.isSelected) {
        if (category.subcategories != null && category.subcategories!.isNotEmpty) {
          List<int?> therapySubcategoryIds = [];
          List<String?> notes = [];

          for (int i = 0; i < category.subcategories!.length; i++) {
            if (category.subcategorySelections![i]) {
              therapySubcategoryIds.add(category.subcategories![i].id); 
              notes.add(category.subcategoryNotes![i].isNotEmpty ? category.subcategoryNotes![i] : null);
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
        } else {
          // Category without subcategories
          Map<String, dynamic> categoryData = {
            "category_name": category.name,
            "category_id": category.id,
            "patient_id": patientInfoController.patientId.value,
            "manualSpeechIds": [category.id],
            "therapySubcategoryIds": [],
            "note": [],
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

  Future<void> submitSelectedTherapies() async {
   

    int successfulSubmissions = 0;
    List<String> errorMessages = [];

    for (var category in categories) {
      // Only process categories that are selected
      if (category.isSelected) {
        
        if (category.subcategories != null && category.subcategories!.isNotEmpty) {
          List<int?> therapySubcategoryIds = [];
          List<String?> notes = [];

          // Only include selected subcategories
          for (int i = 0; i < category.subcategories!.length; i++) {
            if (category.subcategorySelections![i]) {
              therapySubcategoryIds.add(category.subcategories![i].id); 
              notes.add(category.subcategoryNotes![i].isNotEmpty ? category.subcategoryNotes![i] : null);
            }
          }

          // Skip if no subcategories are selected
          if (therapySubcategoryIds.isEmpty) continue; 

          List<int?> manualSpeechIds = [category.id];

          Map<String, dynamic> payload = {
            "patient_id": patientInfoController.patientId.value,
            "manualSpeechIds": manualSpeechIds,
            "therapySubcategoryIds": therapySubcategoryIds,
            "note": notes,
          };

          await _submitCategory(category, payload, successfulSubmissions, errorMessages);
        } else {
          // Handle categories without subcategories
          List<int?> manualSpeechIds = [category.id];

          Map<String, dynamic> payload = {
            "patient_id": patientInfoController.patientId.value,
            "manualSpeechIds": manualSpeechIds,
            "therapySubcategoryIds": [],
            "note": [],
          };

          await _submitCategory(category, payload, successfulSubmissions, errorMessages);
        }
      }
    }

    // Show final result
    if (successfulSubmissions > 0) {
      // Individual success snackbar removed - handled by main prescription controller
      printSelectedTherapiesData();
    } 
    //  if (totalCategories == 0) {
    //   Get.snackbar("No Selection", "Please select subcategories for your selected therapies");
    // } else {
    //   Get.snackbar("Error", "Failed to store manual therapies${errorMessages.isNotEmpty ? ': ${errorMessages.first}' : ''}");
    // }
  }

  Future<void> _submitCategory(TherapyCategory category, Map<String, dynamic> payload, int successfulSubmissions, List<String> errorMessages) async {
    final url = Uri.parse(Api.updateotherallPresc);
    final token = QuickTechAuthStorageService.getFreshToken();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 401) {
        await QuickTechAuthStorageService.handleUnauthorized();
      } else if (response.statusCode == 200 || response.statusCode == 201) {
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