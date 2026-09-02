
import 'package:e_prescription/const/electro_param_keys.dart';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/assestive_device_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/cheif_complain_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/diagnosis_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/disability_types_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/drug_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/on_examination_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/optimized_advice_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/referred_to_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/primary_medical_history_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/radiological_findings_controller.dart';
import 'package:e_prescription/controllers/prescription_controller/diagnosis_controller/previous_therapy_Controller.dart';
import 'package:e_prescription/controllers/prescription_controller/patient_info_controller/patient_info_controller.dart';

import 'package:e_prescription/screens/prescription_templates/quick_tech_default_templates.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';


import 'package:e_prescription/controllers/prescription_controller/prescription_rx_controller/quick_tech_electrotherapy_controller.dart';

class QuickTechPdfController extends GetxController {
  /// Helper to format area display from stored area names
  String _formatAreaNames(List<dynamic>? areaNames) {
    if (areaNames == null || areaNames.isEmpty) return '';
    return areaNames.map((e) => e.toString()).join(', ');
  }

  List<pw.Widget> buildElectrotherapySection() {
    if (electrotherapyController.selectedParameters.values.every(
      (params) => params.isEmpty,
    ))
      return [];
    //if (electrotherapyController.selectedParameters.isEmpty) return [];
    return [
      pw.Text(
        'Electrotherapy:',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
      ...electrotherapyController.selectedParameters.entries
          .where((entry) => entry.value.isNotEmpty)
          .map((entry) {
            final option = entry.key;
            final params = entry.value;
            final areaDisplay = _formatAreaNames(params[ElectroParamKeys.kAreaNames]);
            switch (option) {
              case 'UST (Ultrasound Therapy)':
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (areaDisplay.isNotEmpty)
                      pw.Text(
                        'UST over $areaDisplay',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    pw.Text(
                      '${params[ElectroParamKeys.kFrequency] ?? ''}'
                      '/${params[ElectroParamKeys.kPulseDuration] ?? ''}'
                      '/${params[ElectroParamKeys.kIntensity] ?? ''}'
                      '/${params[ElectroParamKeys.kTherapyTime] ?? ''} min'
                      '/${params[ElectroParamKeys.kTotalTreatmentTime] ?? ''} days'
                      '/${params[ElectroParamKeys.kVisitingFrequency] ?? ''} days/week',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                );
              case 'SWD (Short Wave Diathermy)':
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (areaDisplay.isNotEmpty)
                      pw.Text(
                        'SWD over $areaDisplay',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    pw.Text(
                      '${params[ElectroParamKeys.kPulseWidth] ?? ''} µs'
                      '/${params[ElectroParamKeys.kPulseRate] ?? ''} pps'
                      '/${params[ElectroParamKeys.kAverageWatt] ?? ''} watt'
                      '/${params[ElectroParamKeys.kTherapyTime] ?? ''} min'
                      '/${params[ElectroParamKeys.kTotalTreatmentTime] ?? ''} days'
                      '/${params[ElectroParamKeys.kVisitingFrequency] ?? ''} days/week',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                );
              case 'TENS':
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (areaDisplay.isNotEmpty)
                      pw.Text(
                        'TENS over $areaDisplay',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    pw.Text(
                      '${params[ElectroParamKeys.kFrequency] ?? ''} Hz'
                      '/${params[ElectroParamKeys.kPulseDuration] ?? ''} µs'
                      '/${params[ElectroParamKeys.kTherapyTime] ?? ''} min'
                      '/${params[ElectroParamKeys.kTotalTreatmentTime] ?? ''} days'
                      '/${params[ElectroParamKeys.kVisitingFrequency] ?? ''} days/week',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                );
              case 'EMS':
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (areaDisplay.isNotEmpty)
                      pw.Text(
                        'EMS over $areaDisplay',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    pw.Text(
                      '${params[ElectroParamKeys.kFrequency] ?? ''} Hz'
                      '/${params[ElectroParamKeys.kPulseDuration] ?? ''} µs'
                      '/${params[ElectroParamKeys.kTherapyTime] ?? ''} min'
                      '/${params[ElectroParamKeys.kTotalTreatmentTime] ?? ''} days'
                      '/${params[ElectroParamKeys.kVisitingFrequency] ?? ''} days/week',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                );
              case 'Lumbar Traction':
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if ((params[ElectroParamKeys.kTractionWeight]?.toString() ?? '').isNotEmpty)
                      pw.Text(
                        'L.traction up to ${params[ElectroParamKeys.kTractionWeight]} kg',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    pw.Text(
                      'Hold-${params[ElectroParamKeys.kHoldTime] ?? ''} min'
                      '/Rest-${params[ElectroParamKeys.kRestTime] ?? ''} sec'
                      '/${params[ElectroParamKeys.kTherapyTime] ?? ''} min'
                      '/${params[ElectroParamKeys.kTotalTreatmentTime] ?? ''} days'
                      '/${params[ElectroParamKeys.kVisitingFrequency] ?? ''} days/week',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                );
              case 'Cervical Traction':
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if ((params[ElectroParamKeys.kTractionWeight]?.toString() ?? '').isNotEmpty)
                      pw.Text(
                        'C.traction up to ${params[ElectroParamKeys.kTractionWeight]} kg',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    pw.Text(
                      'Hold-${params[ElectroParamKeys.kHoldTime] ?? ''} min'
                      '/Rest-${params[ElectroParamKeys.kRestTime] ?? ''} sec'
                      '/${params[ElectroParamKeys.kTherapyTime] ?? ''} min'
                      '/${params[ElectroParamKeys.kTotalTreatmentTime] ?? ''} days'
                      '/${params[ElectroParamKeys.kVisitingFrequency] ?? ''} days/week',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                );
              case 'IRR (Infrared Radiation Therapy)':
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (areaDisplay.isNotEmpty)
                      pw.Text(
                        'IRR over $areaDisplay',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    pw.Text(
                      '${params[ElectroParamKeys.kTypeOfIrr] ?? ''}'
                      '/${params[ElectroParamKeys.kTherapyTime] ?? ''} min'
                      '/${params[ElectroParamKeys.kTotalTreatmentTime] ?? ''} days'
                      '/${params[ElectroParamKeys.kVisitingFrequency] ?? ''} days/week'
                      '/${params[ElectroParamKeys.kDistance] ?? ''} cm',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ],
                );
              default:
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children:
                      params.entries
                          .where(
                            (e) =>
                                e.value != null &&
                                e.value.toString().isNotEmpty,
                          )
                          .map(
                            (e) => pw.Text(
                              '${e.key}: ${e.value}',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                          )
                          .toList(),
                );
            }
          })
          .toList(),
    ];
  }


  final PatientInfoController patientInfoController = locator.get<PatientInfoController>();
  final CheifComplainController cheifComplainController = locator.get<CheifComplainController>();
  final OnExaminationController onExaminationController = locator.get<OnExaminationController>();
  final RadiologicalFindingsController radiologicalFindingsController = locator.get<RadiologicalFindingsController>();
  final PrimaryMedicalHistoryController primaryMedicalHistoryController = locator.get<PrimaryMedicalHistoryController>();
  final DrugHistoryController drugHistoryController = locator.get<DrugHistoryController>();
  final AssestiveDeviceController assestiveDeviceController = locator.get<AssestiveDeviceController>();
  final ReferredToController referredToController = locator.get<ReferredToController>();
  final DisabilityTypesController disabilityTypesController = locator.get<DisabilityTypesController>();
  final DiagnosisController diagnosisController = locator.get<DiagnosisController>();
  final PreviousTherapyHistoryController previousTherapyHistoryController = locator.get<PreviousTherapyHistoryController>();
  final OptimizedAdviceController optimizedAdviceController = locator.get<OptimizedAdviceController>();
  final QuickTechElectrotherapyController electrotherapyController = locator.get<QuickTechElectrotherapyController>();

  late pw.Font banglafont;
  Future<void> generatePdf({String? fileName}) async {
    final pdf = pw.Document();

    final ByteData fontData = await rootBundle.load('assets/fonts/Notosan.ttf');
    banglafont = pw.Font.ttf(fontData);

    pdf.addPage(defaultPrescription());

    await _savePdfToDevice(pdf, customFileName: fileName);
  }

  pw.Widget customItemswithSubitems(
    List<dynamic> items,
    RxMap<String, List<String>> subItems,
  ) {
    return items.isNotEmpty
        ? pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children:
              items.map<pw.Widget>((item) {
                // Find SubItems
                var subcategory = subItems[item] ?? [];

                return pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(item.toString(), style: pw.TextStyle(fontSize: 16)),
                    // Display subcategories
                    if (subcategory.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 16),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children:
                              subcategory.map<pw.Widget>((sub) {
                                return pw.Text(
                                  "> ${sub}",
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontStyle: pw.FontStyle.italic,
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                  ],
                );
              }).toList(),
        )
        : pw.SizedBox();
  }

  Future<void> _savePdfToDevice(
    pw.Document pdf, {
    String? customFileName,
  }) async {
    final pdfBytes = await pdf.save();
    final fileName = customFileName ??
        'Prescription_${patientInfoController.patientName.value}_'
            '${patientInfoController.date.value?.toLocal().toString().split(' ')[0] ?? DateTime.now().toString().split(' ')[0]}.pdf'
            .replaceAll(' ', '_')
            .replaceAll('/', '-');
    try {
      if (kIsWeb) {
        // On web: use the printing package to trigger browser print/save
        await Printing.sharePdf(bytes: Uint8List.fromList(pdfBytes), filename: fileName);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final prescDir = Directory('${directory.path}/prescriptions');
        if (!await prescDir.exists()) {
          await prescDir.create();
        }
        final filePath = '${prescDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);
        // OpenFile.open is guarded by !kIsWeb above; the stub is used on web
        await OpenFile.open(filePath);
      }
    } catch (e) {
      QuickTechSnackbar.error('Failed to save PDF: $e');
    }
  }
}
