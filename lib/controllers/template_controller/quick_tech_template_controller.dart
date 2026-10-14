import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:e_prescription/widgets/quick_tech_custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:e_prescription/services/template_services/quick_tech_template_storage_service.dart';


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:e_prescription/models/template_model.dart';
export 'package:e_prescription/models/template_model.dart';

class QuickTechTemplateController extends GetxController {
  final selectedTemplate = RxInt(-1);
  final templates = <Templates>[].obs;
  final packageTemplates = <Templates>[].obs;

  Future<void> fetchTemplates() async {
    final url = '${Api.baseUrl}/api/templates/all';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final templetesModel = templetes.fromJson(data);
        templates.value = templetesModel.templates ?? [];
      }
    } catch (e) {
      // handle error
    }
  }

  Future<void> fetchUserPackageTemplates(String token) async {
    final url = '${Api.baseUrl}/api/user/package';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final templetesModel = templetes.fromJson(data);
        templates.value = templetesModel.templates ?? [];
      }
    } catch (e) {
      // handle error
    }
  }

  void filterTemplatesByPackage(int packageId) {
    packageTemplates.value = templates
        .where((t) => int.tryParse(t.packageId ?? '') == packageId)
        .toList();
  }

  void selectTemplate(int index) {
    selectedTemplate.value = index;
  }

  void showDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Selected Template'),
        content: Text('You selected template \\${selectedTemplate.value + 1}'),
        actions: [
          TextButton(onPressed: () {
            Get.offNamed('/mainhome');
          }, child: const Text('OK')),
        ],
      ),
    );
  }

  void showprescription() {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Selected template \\${selectedTemplate.value + 1}',
          style: myStyle(
            18,
            themeController.isDay.value
                ? QuickTechAppColors.lightmaintextcolor
                : QuickTechAppColors.darkmaintextcolor,
            FontWeight.bold,
          ),
        ),
        content: FittedBox(
          child: Image.asset('assets/images/prescription.png'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'OK',
              style: myStyle(
                12,
                themeController.isDay.value
                    ? QuickTechAppColors.lightmaintextcolor
                    : QuickTechAppColors.darkmaintextcolor,
              ),
            ),
          ),
        ],
      ),
    );
  }
  


  void loadSavedTemplate() {
    final dynamic raw = QuickTechTemplateStorageService.getSelectedTemplateId();
    if (raw == null) return;
    final String savedId = raw.toString();
    final int index = templates.indexWhere(
      (t) => t.templateValue == savedId,
    );
    if (index != -1) {
      selectedTemplate.value = index;
    }
  }


 Future<void> saveTemplate() async {
  if (selectedTemplate.value == -1) return;

  String templateId = templates[selectedTemplate.value].templateValue!;

  QuickTechTemplateStorageService.clearSelectedTemplateId();
  QuickTechTemplateStorageService.saveSelectedTemplateId(templateId);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (Get.context != null) {
      QuickTechSnackbar.success("Template ID $templateId saved successfully!");
    }
  });
}

}


