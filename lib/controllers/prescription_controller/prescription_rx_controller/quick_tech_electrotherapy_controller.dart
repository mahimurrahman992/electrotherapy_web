import 'dart:convert';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';

import 'package:e_prescription/controllers/prescription_controller/patient_info_controller/patient_info_controller.dart';
import 'package:e_prescription/locator.dart';

import 'package:e_prescription/const/electro_param_keys.dart';
import 'package:e_prescription/models/rx_models/electrotherapy.dart';

import 'package:e_prescription/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

PatientInfoController patientInfoController = locator.get<PatientInfoController>();

class QuickTechElectrotherapyController extends GetxController {
  final prescriptions = <ElectrotherapyPrescription>[].obs;
  final selectedParameters = <String, Map<String, dynamic>>{}.obs;
  final textControllers = <String, Map<String, TextEditingController>>{}.obs;
  final electrotherapyCategories = <ElectrotherapyCategory>[].obs;
  
  // Support multiple custom electrotherapies
  final extraElectrotherapies = <String>[].obs;  // List of custom therapy names
  final extraTherapyControllers = <TextEditingController>[].obs;  // Controllers for each field

  // Draft state for the "Extra Therapy" add form. Lives on the controller
  // (not as a local variable in the widget builder) so it survives rebuilds
  // triggered by unrelated reactive changes elsewhere in the Rx section.
  final RxInt activeInputIndex = (-1).obs;
  final RxList<TextEditingController> tempControllers = <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchElectroTherapies();
  }

  /// ✅ সিলেক্টেড ডেটা এবং রিকোয়েস্ট বডি প্রিন্ট করার মেথড
  void printElectrotherapyData() {
    print('\n=================== SELECTED ELECTROTHERAPY DATA ===================');
    
    List<int> electroTherapyIds = [];
    List<String> therapyTime = [];
    List<String> totalTreatmentTime = [];
    List<String> visitingFrequency = [];
    List<String> frequency = [];
    List<String?> areaMulti = [];
    List<String?> pulseDuration = [];
    List<String?> tractionWeight = [];
    List<String?> holdTime = [];
    List<String?> restTime = [];

    String? areaSingle;
    String? pulseRatio;
    String? intensity;
    String? pulseWidth;
    String? pulseRate;
    String? averageWatt;
    String? typeOfIrr;
    String? distance;

    // ১. ইউজার স্ক্রিনে কী কী সিলেক্ট করেছেন তা দেখাচ্ছে
    for (var category in electrotherapyCategories) {
      for (var option in category.options) {
        final params = selectedParameters[option.name] ?? {};
        
        if (params.isNotEmpty) {
          print('Therapy Selected: ${option.name} (ID: ${option.id})');
          print('--- Parameters: $params');

          electroTherapyIds.add(option.id);
          therapyTime.add(params['therapy_time']?.toString() ?? 'none');
          totalTreatmentTime.add(params['total_treatment_time']?.toString() ?? 'none');
          visitingFrequency.add(params['visiting_frequency']?.toString() ?? 'none');
          frequency.add(params['Frequency']?.toString() ?? 'none');
          areaMulti.add(params['Area Options'] is List ? (params['Area Options'] as List).join(', ') : null);
          pulseDuration.add(params['Pulse Duration/Ratio']?.toString());
          tractionWeight.add(params['Traction Weight']?.toString());
          holdTime.add(params['Hold Time']?.toString());
          restTime.add(params['Rest Time']?.toString());

          areaSingle ??= params['Area Options'] is String ? params['Area Options'] : null;
          pulseRatio ??= params['Pulse Duration/Ratio']?.toString();
          intensity ??= params['Intensity']?.toString();
          pulseWidth ??= params['Pulse Width']?.toString();
          pulseRate ??= params['Pulse Rate']?.toString();
          averageWatt ??= params['Average Watt']?.toString();
          typeOfIrr ??= params['Type of IRR']?.toString();
          distance ??= params['Distance']?.toString();
        }
      }
    }

    // এক্সট্রা বা কাস্টম থেরাপিগুলো প্রিন্ট করা
    final extraTherapies = getFilledExtraElectrotherapies();
    if (extraTherapies.isNotEmpty) {
      print('Custom/Extra Therapies: $extraTherapies');
    }

    // ২. সার্ভারে যে JSON রিকোয়েস্ট বডি পাঠানো হচ্ছে তা তৈরি ও প্রিন্ট করা
    final requestBody = {
      "patient_id": patientInfoController.patientId.value,
      "electroTherapyIds": electroTherapyIds,
      "therapy_time": therapyTime,
      "total_treatment_time": totalTreatmentTime,
      "visiting_frequency": visitingFrequency,
      "frequency": frequency,
      "area_multi": areaMulti,
      "pulse_duration": pulseDuration,
      "traction_weight": tractionWeight,
      "hold_time": holdTime,
      "rest_time": restTime,
      "area_single": areaSingle,
      "pulse_ratio": pulseRatio,
      "intensity": intensity,
      "pulse_width": pulseWidth,
      "pulse_rate": pulseRate,
      "average_watt": averageWatt,
      "type_of_irr": typeOfIrr,
      "distance": distance,
      "extra_electrotherapies": extraTherapies, // যদি ব্যাকএন্ড সাপোর্ট করে
    };

    print('\n=================== API REQUEST PAYLOAD (BODY) ===================');
    print(jsonEncode(requestBody));
    print('==================================================================\n');
  }

  /// ✅ Add a new custom electrotherapy field
  void addExtraElectrotherapy() {
    extraTherapyControllers.add(TextEditingController());
    extraElectrotherapies.add('');
  }

  /// ✅ Remove custom electrotherapy at index
  void removeExtraElectrotherapy(int index) {
    if (index >= 0 && index < extraTherapyControllers.length) {
      extraTherapyControllers[index].dispose();
      extraTherapyControllers.removeAt(index);
      extraElectrotherapies.removeAt(index);
    }
  }

  /// ✅ Update custom electrotherapy value
  void updateExtraElectrotherapy(int index, String value) {
    if (index >= 0 && index < extraElectrotherapies.length) {
      extraElectrotherapies[index] = value;
    }
  }

  /// ✅ Get all non-empty extra therapies
  List<String> getFilledExtraElectrotherapies() {
    return extraElectrotherapies.where((e) => e.trim().isNotEmpty).toList();
  }

  /// ✅ API থেকে ডেটা ফেস করা এবং রেসপন্স প্রিন্ট করা
  Future<void> fetchElectroTherapies() async {
    try {
      final response = await http.get(
        Uri.parse(Api.getElectrotherapyPrescription),
      );

      print('\n=== FETCH ELECTROTHERAPIES RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}\n');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final therapies = (data['electro_therapies'] as List)
            .map((e) => ElectroTherapy.fromJson(e))
            .toList();
            
        electrotherapyCategories.assignAll([
          ElectrotherapyCategory(
            name: "Electrotherapy",
            options: therapies.map((therapy) => ElectrotherapyOption(
              id: therapy.id,
              name: therapy.name,
              parameters: _mapTherapyToParameters(therapy),
            )).toList(),
          ),
        ]);

        // Init selections and controllers
        for (var category in electrotherapyCategories) {
          for (var option in category.options) {
            selectedParameters[option.name] = {};
            textControllers[option.name] = {
              for (var param in option.parameters)
                if (param.type == ParameterType.textInput)
                  param.name: TextEditingController(),
            };
          }
        }
      } else {
        QuickTechSnackbar.error("Failed to fetch therapies: ${response.statusCode}");
      }
    } catch (e) {
      QuickTechSnackbar.error("Something went wrong: $e");
    }
  }

  void clearAllSelections() {
    for (var key in selectedParameters.keys) {
      selectedParameters[key] = {};
    }
    for (var controller in extraTherapyControllers) {
      controller.dispose();
    }
    extraTherapyControllers.clear();
    extraElectrotherapies.clear();
    for (var controller in tempControllers) {
      controller.dispose();
    }
    tempControllers.clear();
    activeInputIndex.value = -1;
    update();
  }

  void updateParameter(String optionName, String paramName, dynamic value) {
    final params = Map<String, dynamic>.from(
      selectedParameters[optionName] ?? {},
    );
    
    if (paramName == ElectroParamKeys.kAreaOptions) {
      final paramType = _getParameterType(optionName, paramName);

      if (_isNumericId(value)) {
        final receivedIds = _extractNumericIds(value);
        final areaNames = _getAreaNamesForIds(optionName, receivedIds);

        params[ElectroParamKeys.kAreaNames] = areaNames;
        params[ElectroParamKeys.kAreaIds]   = receivedIds;
        if (paramType == ParameterType.singleSelect) {
          params[paramName] = areaNames.isNotEmpty ? areaNames.first : null;
        } else {
          params[paramName] = receivedIds;
        }
      } else {
        final areaNames = _extractAreaNamesList(value);
        final areaIds = _getAreaIdsForNames(optionName, areaNames);

        params[ElectroParamKeys.kAreaNames] = areaNames;
        params[ElectroParamKeys.kAreaIds]   = areaIds;
        if (paramType == ParameterType.singleSelect) {
          params[paramName] = areaNames.isNotEmpty ? areaNames.first : null;
        } else {
          params[paramName] = areaIds;
        }
      }
    } else {
      params[paramName] = value;
    }

    selectedParameters[optionName] = params;
    update();
  }
  
  bool _isNumericId(dynamic value) {
    if (value is int) return true;
    if (value is List) {
      return value.isNotEmpty && value.every((e) => e is int);
    }
    if (value is String) {
      return int.tryParse(value) != null;
    }
    return false;
  }

  List<int> _extractNumericIds(dynamic value) {
    if (value is int) return [value];
    if (value is List) {
      return value.whereType<int>().toList();
    }
    if (value is String) {
      return [int.tryParse(value) ?? 0];
    }
    return [];
  }

  ParameterType _getParameterType(String optionName, String paramName) {
    for (var category in electrotherapyCategories) {
      for (var option in category.options) {
        if (option.name == optionName) {
          for (var param in option.parameters) {
            if (param.name == paramName) return param.type;
          }
        }
      }
    }
    return ParameterType.multiSelect;
  }

  List<String> _getAreaNamesForIds(String optionName, List<int> areaIds) {
    final List<String> names = [];
    for (var category in electrotherapyCategories) {
      for (var option in category.options) {
        if (option.name == optionName) {
          for (var param in option.parameters) {
            if (param.name == ElectroParamKeys.kAreaOptions && param.areaIds != null) {
              for (final selectedId in areaIds) {
                final idIndex = param.areaIds!.indexOf(selectedId);
                if (idIndex >= 0 && idIndex < param.options!.length) {
                  names.add(param.options![idIndex]);
                }
              }
              return names;
            }
          }
          return names;
        }
      }
    }
    return names;
  }
  
  List<String> _extractAreaNamesList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    if (value is String) return [value];
    return [value.toString()];
  }
  
  List<int> _getAreaIdsForNames(String optionName, List<String> areaNames) {
    final List<int> ids = [];
    for (var category in electrotherapyCategories) {
      for (var option in category.options) {
        if (option.name == optionName) {
          for (var param in option.parameters) {
            if (param.name == ElectroParamKeys.kAreaOptions && param.areaIds != null) {
              for (final selectedName in areaNames) {
                final nameIndex = param.options!.indexOf(selectedName);
                if (nameIndex >= 0 && nameIndex < param.areaIds!.length) {
                  ids.add(param.areaIds![nameIndex]);
                }
              }
              return ids;
            }
          }
          return ids;
        }
      }
    }
    return ids;
  }

  List<ElectrotherapyPerameter> _mapTherapyToParameters(ElectroTherapy therapy) {
    final params = <ElectrotherapyPerameter>[];
    final areaNames = therapy.therapyAreas.map((e) => e.name).toList();
    
    final hasAreaSingle = therapy.type.contains('area-single') || therapy.type.contains('area_single');
    final hasAreaMulti = therapy.type.contains('area-multi') || therapy.type.contains('area_multi');
    
    if (hasAreaSingle && areaNames.isNotEmpty) {
      final areaIds = therapy.therapyAreas.map((e) => e.id).toList();
      params.add(
        ElectrotherapyPerameter(
          name: ElectroParamKeys.kAreaOptions,
          type: ParameterType.singleSelect,
          options: areaNames,
          areaIds: areaIds,
        ),
      );
    } else if (hasAreaMulti && areaNames.isNotEmpty) {
      final areaIds = therapy.therapyAreas.map((e) => e.id).toList();
      params.add(
        ElectrotherapyPerameter(
          name: ElectroParamKeys.kAreaOptions,
          type: ParameterType.multiSelect,
          options: areaNames,
          areaIds: areaIds,
        ),
      );
    }

    final paramMap = {
      "frequency":       [ElectroParamKeys.kFrequency,      "Hz"],
      "pulse-ratio":    [ElectroParamKeys.kPulseDuration,  "µs"],
      "pulse-duration": [ElectroParamKeys.kPulseDuration,  "µs"],
      "pulse-width":    [ElectroParamKeys.kPulseWidth,     "µs"],
      "pulse-rate":     [ElectroParamKeys.kPulseRate,      "pps"],
      "average-watt":   [ElectroParamKeys.kAverageWatt,    "watt"],
      "traction-weight":[ElectroParamKeys.kTractionWeight, "Kg"],
      "hold-time":      [ElectroParamKeys.kHoldTime,       "minutes"],
      "rest-time":      [ElectroParamKeys.kRestTime,       "seconds"],
      "distance":       [ElectroParamKeys.kDistance,       "cm"],
      "intensity":      [ElectroParamKeys.kIntensity,      null],
    };

    paramMap.forEach((key, value) {
      if (therapy.type.contains(key)) {
        params.add(
          ElectrotherapyPerameter(
            name: value[0] ?? '',
            type: ParameterType.textInput,
            unit: value[1],
          ),
        );
      }
    });

    if (therapy.type.contains("type-of-irr")) {
      params.add(
        ElectrotherapyPerameter(
          name: ElectroParamKeys.kTypeOfIrr,
          type: ParameterType.singleSelect,
          options: ["Luminous", "Non-luminous"],
        ),
      );
    }
    return params;
  }

  bool hasSelectedElectrotherapies() {
    for (var category in electrotherapyCategories) {
      for (var option in category.options) {
        final params = selectedParameters[option.name] ?? {};
        if (params.isNotEmpty) return true;
      }
    }
    return false;
  }

  int getSelectedElectrotherapiesCount() {
    int count = 0;
    for (var category in electrotherapyCategories) {
      for (var option in category.options) {
        final params = selectedParameters[option.name] ?? {};
        if (params.isNotEmpty) count++;
      }
    }
    return count;
  }
}