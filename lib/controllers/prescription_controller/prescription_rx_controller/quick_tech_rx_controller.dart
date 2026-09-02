import 'dart:convert';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/const/electro_param_keys.dart';
import 'package:e_prescription/controllers/prescription_controller/patient_info_controller/patient_info_controller.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/controllers/prescription_controller/prescription_rx_controller/quick_tech_electrotherapy_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/prescription_rx_controller/quick_tech_manual_therapy_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/prescription_rx_controller/quick_tech_miscellaneous_therapy_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/prescription_rx_controller/quick_tech_speech_language_therapy_controller.dart';
import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

final electrotherapyController = locator.get<QuickTechElectrotherapyController>();
final manualTherapyController = locator.get<QuickTechManualTherapyController>();
final miscellaneousTherapyController = locator.get<QuickTechMiscellaneousTherapyController>();
final speechLanguageTherapyController = locator.get<QuickTechSpeechLanguageTherapyController>();
final patientInfoController = locator.get<PatientInfoController>();

class QuicktechmainPrescriptionControllr extends GetxController {
  
  Future<int> storeSelectedRxData() async {
    List<String> storedTherapies = [];
    List<String> errorMessages = [];
    final token = QuickTechAuthStorageService.getFreshToken();

    // =========================================================================
    // 1. STORE ELECTROTHERAPY DATA + EXTRA THERAPIES
    // =========================================================================
    final hasElectroSelection = electrotherapyController.selectedParameters.values.any((m) => m.isNotEmpty);
    final hasExtraTherapies = electrotherapyController.getFilledExtraElectrotherapies().isNotEmpty;

    if (hasElectroSelection || hasExtraTherapies) {
      try {
        final selectedElectroOptions = <Map<String, dynamic>>[];
        List<int> electroTherapyIds = [];
        List<String> therapyTime = [];
        List<String> totalTreatmentTime = [];
        List<String> visitingFrequency = [];
        List<String> frequency = [];
        List<String?> areaMulti = []; // ✅ Changed to String for comma-separated area IDs
        List<String?> areaSingleList = [];

        List<String> pulseDuration = [];
        List<String> tractionWeight = [];
        List<String> holdTime = [];
        List<String> restTime = [];
        List<String?> pulseRatioList = [];
        List<String?> intensityList = [];
        List<String> pulseWidthList = [];
        List<String> pulseRateList = [];
        List<String> averageWattList = [];
        List<String?> typeOfIrrList = [];
        List<String?> distanceList = [];

        for (var category in electrotherapyController.electrotherapyCategories) {
          for (var option in category.options) {
            final params = electrotherapyController.selectedParameters[option.name] ?? {};
            if (params.isNotEmpty) {
              selectedElectroOptions.add({
                'id': option.id,
                'name': option.name,
                'params': Map<String, dynamic>.from(params),
              });

              electroTherapyIds.add(option.id);
              therapyTime.add(params[ElectroParamKeys.kTherapyTime]?.toString() ?? 'none');
              totalTreatmentTime.add(params[ElectroParamKeys.kTotalTreatmentTime]?.toString() ?? 'none');
              visitingFrequency.add(params[ElectroParamKeys.kVisitingFrequency]?.toString() ?? 'none');
              frequency.add(params[ElectroParamKeys.kFrequency]?.toString() ?? 'none');

              // Area - backend expects area IDs (not names), comma-separated or empty
              final areaIds = params[ElectroParamKeys.kAreaIds];
              
              String areaValue = '';
              if (areaIds is List && areaIds.isNotEmpty) {
                areaValue = areaIds.map((id) => id.toString()).join(', ');
              }
              
              areaMulti.add(areaValue); // ✅ One area value per therapy (as area IDs)
              areaSingleList.add(null);

              // Optional fields fallback to 'none' if empty
              final pd = params[ElectroParamKeys.kPulseDuration]?.toString();
              pulseDuration.add((pd != null && pd.isNotEmpty) ? pd : 'none');

              final tw = params[ElectroParamKeys.kTractionWeight]?.toString();
              tractionWeight.add((tw != null && tw.isNotEmpty) ? tw : 'none');

              final ht = params[ElectroParamKeys.kHoldTime]?.toString();
              holdTime.add((ht != null && ht.isNotEmpty) ? ht : 'none');

              final rt = params[ElectroParamKeys.kRestTime]?.toString();
              restTime.add((rt != null && rt.isNotEmpty) ? rt : 'none');

              final pr_val = params[ElectroParamKeys.kPulseDuration]?.toString();
              pulseRatioList.add((pr_val != null && pr_val.isNotEmpty) ? pr_val : null);
              
              final int_val = params[ElectroParamKeys.kIntensity]?.toString();
              intensityList.add((int_val != null && int_val.isNotEmpty) ? int_val : null);

              final pw = params[ElectroParamKeys.kPulseWidth]?.toString();
              pulseWidthList.add((pw != null && pw.isNotEmpty) ? pw : 'none');

              final pr = params[ElectroParamKeys.kPulseRate]?.toString();
              pulseRateList.add((pr != null && pr.isNotEmpty) ? pr : 'none');

              final aw = params[ElectroParamKeys.kAverageWatt]?.toString();
              averageWattList.add((aw != null && aw.isNotEmpty) ? aw : 'none');

              final toi = params[ElectroParamKeys.kTypeOfIrr]?.toString();
              typeOfIrrList.add((toi != null && toi.isNotEmpty) ? toi : null);
              
              final dist = params[ElectroParamKeys.kDistance]?.toString();
              distanceList.add((dist != null && dist.isNotEmpty) ? dist : null);
            }
          }
        }

        String? firstNonNull(List values) => values
            .firstWhere((value) => value != null && value.toString().isNotEmpty, orElse: () => null)
            ?.toString();

        if (electroTherapyIds.isNotEmpty || hasExtraTherapies) {
          final bodyParts = <String>[];

          // Scalar Fields
          bodyParts.add('patient_id=${Uri.encodeQueryComponent(patientInfoController.patientId.value.toString())}');
          bodyParts.add('area_single=${Uri.encodeQueryComponent(firstNonNull(areaSingleList) ?? '')}');
          bodyParts.add('pulse_ratio=${Uri.encodeQueryComponent(firstNonNull(pulseRatioList) ?? '')}');
          bodyParts.add('intensity=${Uri.encodeQueryComponent(firstNonNull(intensityList) ?? '')}');
          bodyParts.add('pulse_width=');
          bodyParts.add('pulse_rate=');
          bodyParts.add('average_watt=');
          bodyParts.add('type_of_irr=${Uri.encodeQueryComponent(firstNonNull(typeOfIrrList) ?? '')}');
          bodyParts.add('distance=${Uri.encodeQueryComponent(firstNonNull(distanceList) ?? '')}');

          if (electroTherapyIds.isNotEmpty) {
            // Required arrays
            for (var id in electroTherapyIds) {
              bodyParts.add('electroTherapyIds[]=${Uri.encodeQueryComponent(id.toString())}');
            }
            for (var time in therapyTime) {
              bodyParts.add('therapy_time[]=${Uri.encodeQueryComponent(time)}');
            }
            for (var total in totalTreatmentTime) {
              bodyParts.add('total_treatment_time[]=${Uri.encodeQueryComponent(total)}');
            }
            for (var freq in visitingFrequency) {
              bodyParts.add('visiting_frequency[]=${Uri.encodeQueryComponent(freq)}');
            }
            for (var f in frequency) {
              bodyParts.add('frequency[]=${Uri.encodeQueryComponent(f)}');
            }
            
            // ✅ Area multi - one value per therapy (as comma-separated string or empty)
            for (var area in areaMulti) {
              bodyParts.add('area_multi[]=${Uri.encodeQueryComponent(area ?? '')}');
            }

            // Optional arrays
            for (var pd in pulseDuration) bodyParts.add('pulse_duration[]=${Uri.encodeQueryComponent(pd)}');
            for (var tw in tractionWeight) bodyParts.add('traction_weight[]=${Uri.encodeQueryComponent(tw)}');
            for (var ht in holdTime) bodyParts.add('hold_time[]=${Uri.encodeQueryComponent(ht)}');
            for (var rt in restTime) bodyParts.add('rest_time[]=${Uri.encodeQueryComponent(rt)}');
            for (var pw in pulseWidthList) bodyParts.add('pulse_width[]=${Uri.encodeQueryComponent(pw)}');
            for (var pr in pulseRateList) bodyParts.add('pulse_rate[]=${Uri.encodeQueryComponent(pr)}');
            for (var aw in averageWattList) bodyParts.add('average_watt[]=${Uri.encodeQueryComponent(aw)}');
          }

          // Custom Electrotherapies
          final extraTherapies = electrotherapyController.getFilledExtraElectrotherapies();
          if (extraTherapies.isNotEmpty) {
            for (var therapy in extraTherapies) {
              bodyParts.add('newElectroTherapy[]=${Uri.encodeQueryComponent(therapy)}');
            }
          } else {
            bodyParts.add('newElectroTherapy[]=');
          }

          // Clean Debug Print For Electrotherapy Payload
          _printCleanPayload(
            title: "ELECTROTHERAPY",
            snapshot: {
              'patient_id': patientInfoController.patientId.value,
              'selected': selectedElectroOptions,
              'newElectroTherapy': extraTherapies,
            },
            rawBody: bodyParts.join('&'),
          );

          final body = bodyParts.join('&');
          final response = await http.post(
            Uri.parse(Api.updateElectroPresc),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: body,
          );

          debugPrint('==> ELECTROTHERAPY RESPONSE [${response.statusCode}]: ${response.body}\n');

          if (response.statusCode == 200 || response.statusCode == 201) {
            storedTherapies.add("Electrotherapy");
          } else {
            errorMessages.add("Electrotherapy: ${response.body}");
          }
        }
      } catch (e) {
        errorMessages.add("Electrotherapy Error: $e");
      }
    }

    // =========================================================================
    // 2. STORE MANUAL, MISCELLANEOUS, AND SPEECH LANGUAGE THERAPY
    // =========================================================================
    List<int> manualSpeechIds = [];
    List<int?> therapySubcategoryIds = [];
    List<String?> notes = [];

    // Manual Therapy Selections
    if (manualTherapyController.selectedTherapies.isNotEmpty) {
      for (var category in manualTherapyController.categories) {
        if (category.isSelected) {
          if (category.subcategories != null && category.subcategories!.isNotEmpty) {
            for (int i = 0; i < category.subcategories!.length; i++) {
              if (category.subcategorySelections![i]) {
                therapySubcategoryIds.add(category.subcategories![i].id);
                notes.add(category.subcategoryNotes![i].isNotEmpty ? category.subcategoryNotes![i] : null);
              }
            }
          } else {
            manualSpeechIds.add(category.id ?? 0);
            notes.add(null);
          }
        }
      }
    }

    // Miscellaneous Therapy Selections
    if (miscellaneousTherapyController.selectedTherapies.isNotEmpty) {
      for (var category in miscellaneousTherapyController.categories) {
        if (category.isSelected && category.subcategories.isNotEmpty) {
          for (var sub in category.subcategories) {
            if (sub.isSelected) {
              therapySubcategoryIds.add(sub.id);
              notes.add(sub.note != null && sub.note!.isNotEmpty ? sub.note : null);
            }
          }
        }
      }
    }

    // Speech Language Therapy Selections
    if (speechLanguageTherapyController.selectedTherapies.isNotEmpty) {
      for (var category in speechLanguageTherapyController.categories) {
        if (category.isSelected) {
          if (category.subcategories != null && category.subcategories!.isNotEmpty) {
            for (var sub in category.subcategories!) {
              if (sub.isSelected) {
                therapySubcategoryIds.add(sub.id);
                notes.add(sub.note != null && sub.note!.isNotEmpty ? sub.note : null);
              }
            }
          } else {
            manualSpeechIds.add(category.id ?? 0);
            notes.add(null);
          }
        }
      }
    }

    // Custom Therapies Setup
    final manualCustom = manualTherapyController.getFilledCustomTherapies();
    final miscCustom = miscellaneousTherapyController.getFilledCustomTherapies();
    final speechCustom = speechLanguageTherapyController.getFilledCustomTherapies();
    final hasCustomTherapies = manualCustom.isNotEmpty || miscCustom.isNotEmpty || speechCustom.isNotEmpty;

    if (manualSpeechIds.isNotEmpty || therapySubcategoryIds.isNotEmpty || hasCustomTherapies) {
      final patientId = patientInfoController.patientId.value;
      if (patientId == 0) {
        errorMessages.add("Invalid patient ID. Cannot submit other therapies.");
      } else {
        try {
          final bodyParts = <String>[];
          bodyParts.add('patient_id=${Uri.encodeQueryComponent(patientId.toString())}');

          for (var id in manualSpeechIds) {
            bodyParts.add('manualSpeechIds[]=${Uri.encodeQueryComponent(id.toString())}');
          }
          for (var id in therapySubcategoryIds) {
            bodyParts.add('therapySubcategoryIds[]=${Uri.encodeQueryComponent(id?.toString() ?? '')}');
          }
          for (var note in notes) {
            if (note != null && note.isNotEmpty) {
              bodyParts.add('note[]=${Uri.encodeQueryComponent(note)}');
            }
          }

          // Indexed Other Therapy Custom Names
          int customTherapyIndex = 0;
          for (var therapy in manualCustom) {
            bodyParts.add('otherTherapy[$customTherapyIndex][new_manual_speech_name]=${Uri.encodeQueryComponent(therapy)}');
            bodyParts.add('otherTherapy[$customTherapyIndex][new_manual_speech_type]=${Uri.encodeQueryComponent('Manual Therapy')}');
            customTherapyIndex++;
          }
          for (var therapy in miscCustom) {
            bodyParts.add('otherTherapy[$customTherapyIndex][new_manual_speech_name]=${Uri.encodeQueryComponent(therapy)}');
            bodyParts.add('otherTherapy[$customTherapyIndex][new_manual_speech_type]=${Uri.encodeQueryComponent('Miscellaneous Therapy')}');
            customTherapyIndex++;
          }
          for (var therapy in speechCustom) {
            bodyParts.add('otherTherapy[$customTherapyIndex][new_manual_speech_name]=${Uri.encodeQueryComponent(therapy)}');
            bodyParts.add('otherTherapy[$customTherapyIndex][new_manual_speech_type]=${Uri.encodeQueryComponent('Speech and Language Therapy')}');
            customTherapyIndex++;
          }

          // Clean Debug Print For Other Therapies Payload
          _printCleanPayload(
            title: "MANUAL/MISC/SPEECH THERAPIES",
            snapshot: {
              'patient_id': patientId,
              'manualSpeechIds': manualSpeechIds,
              'therapySubcategoryIds': therapySubcategoryIds,
              'notes': notes,
              'customTherapiesCount': customTherapyIndex,
            },
            rawBody: bodyParts.join('&'),
          );

          final body = bodyParts.join('&');
          final response = await http.post(
            Uri.parse(Api.updateotherallPresc),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: body,
          );

          debugPrint('==> OTHER THERAPIES RESPONSE [${response.statusCode}]: ${response.body}\n');

          if (response.statusCode == 200 || response.statusCode == 201) {
            if (manualTherapyController.selectedTherapies.isNotEmpty || manualCustom.isNotEmpty) {
              storedTherapies.add("Manual Therapy");
            }
            if (miscellaneousTherapyController.selectedTherapies.isNotEmpty || miscCustom.isNotEmpty) {
              storedTherapies.add("Miscellaneous Therapy");
            }
            if (speechLanguageTherapyController.selectedTherapies.isNotEmpty || speechCustom.isNotEmpty) {
              storedTherapies.add("Speech Language Therapy");
            }
          } else {
            errorMessages.add("Other therapy submission failed: ${response.body}");
          }
        } catch (e) {
          errorMessages.add("Other therapy error: $e");
        }
      }
    }

    // =========================================================================
    // 3. SHOW NOTIFICATION RESULT
    // =========================================================================
    if (storedTherapies.isNotEmpty) {
      final successMessage = storedTherapies.length == 1
          ? "${storedTherapies.first} stored successfully"
          : "${storedTherapies.join(', ')} stored successfully";

      QuickTechSnackbar.success(successMessage, title: "Prescription Stored");
      return 200;
    } else if (errorMessages.isNotEmpty) {
      QuickTechSnackbar.error(errorMessages.first);
      return 400;
    }
    return 500;
  }

  /// Clean logger to trace selected data vs request payload
  void _printCleanPayload({required String title, required Map<String, dynamic> snapshot, required String rawBody}) {
    print('\n=================== [$title] SELECTED SNAPSHOT ===================');
    print(const JsonEncoder.withIndent('  ').convert(snapshot));
    print('\n=================== [$title] RAW ENCODED BODY ===================');
    print(rawBody);
    print('==========================================================================\n');
  }

  void clearAllRxData() {
    try {
      electrotherapyController.clearAllSelections();
      electrotherapyController.textControllers.forEach((_, tcMap) {
        tcMap.forEach((_, controller) => controller.clear());
      });
      manualTherapyController.clearAllSelections();
      miscellaneousTherapyController.clearAllSelections();
      speechLanguageTherapyController.clearAllSelections();
    } catch (_) {}
  }
}