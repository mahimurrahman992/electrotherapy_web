import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/locator.dart';
import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import 'package:e_prescription/controllers/patient_controller/quick_tech_patient_controller.dart';
import 'package:e_prescription/services/auth_services/quick_tech_auth_storage_service.dart';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
// dart:io, path_provider and permission_handler are mobile/desktop only
import 'dart:io' if (dart.library.html) 'package:e_prescription/utils/stub_io.dart';
import 'package:path_provider/path_provider.dart'
    if (dart.library.html) 'package:e_prescription/utils/stub_path_provider.dart';

class QuicktechAssessmentPdfView extends StatelessWidget {
  final int assessmentId;
  const QuicktechAssessmentPdfView({Key? key, required this.assessmentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final QuickTechPatientController patientController = locator.get<QuickTechPatientController>();
    final String? token = QuickTechAuthStorageService.getToken();
    final QuickTechThemeController themeController = locator.get<QuickTechThemeController>();
    return Scaffold(
      appBar: AppBar(backgroundColor: themeController.isDay.value?QuickTechAppColors.lightmaincolor:QuickTechAppColors.darkmaincolor,
      foregroundColor: QuickTechAppColors.white,
        title: const Text('Assessment PDF'),
        actions: [
          Obx(() {
            final pdfBytes = patientController.assessmentPdfBytes.value;
            if (pdfBytes == null) return SizedBox.shrink();
            return Row(
              children: [
                IconButton(
                  icon: Icon(Icons.download),
                  tooltip: 'Download',
                  onPressed: () async {
                    final fileName = 'assessment_${assessmentId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
                    try {
                      if (kIsWeb) {
                        // On web: trigger browser print/save dialog
                        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
                      } else if (Platform.isAndroid) {
                        // Android: save directly to the public Downloads folder
                        const androidDownloads = '/storage/emulated/0/Download';
                        final file = File('$androidDownloads/$fileName');
                        await file.writeAsBytes(pdfBytes);
                        QuickTechSnackbar.success('Downloaded to $androidDownloads/$fileName');
                      } else {
                        // iOS / desktop: use the platform Downloads / documents dir
                        final dir = Platform.isIOS
                            ? await getApplicationDocumentsDirectory()
                            : await getDownloadsDirectory();
                        if (dir == null) {
                          QuickTechSnackbar.error('Could not find Downloads folder.');
                          return;
                        }
                        final file = File('${dir.path}/$fileName');
                        await file.writeAsBytes(pdfBytes);
                        QuickTechSnackbar.success('Downloaded to ${dir.path}/$fileName');
                      }
                    } catch (e) {
                      QuickTechSnackbar.error('Download failed: $e');
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.print),
                  tooltip: 'Print',
                  onPressed: () async {
                    try {
                      await Printing.layoutPdf(
                        onLayout: (format) async => pdfBytes,
                      );
                    } catch (e) {
                      QuickTechSnackbar.error('Print failed: $e');
                    }
                  },
                ),
              ],
            );
          }),
        ],
      ),
      body: FutureBuilder<String?>(
        future: patientController.fetchAssessmentPdf(assessmentId, token ?? ''),
        builder: (context, snapshot) {
          if (patientController.isAssessmentPdfLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (patientController.assessmentPdfError.isNotEmpty) {
            return Center(
              child: Text(
                'Error: ${patientController.assessmentPdfError.value}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (patientController.assessmentPdfBytes.value != null) {
            return SfPdfViewer.memory(patientController.assessmentPdfBytes.value!);
          } else {
            return const Center(child: Text('No PDF data available.'));
          }
        },
      ),
    );
  }
}
