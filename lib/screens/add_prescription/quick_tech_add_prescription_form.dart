

import 'package:e_prescription/screens/add_prescription/patient_info/quick_tech_custom_patient_info.dart';
import 'package:e_prescription/screens/add_prescription/rx_info/quick_tech_custom_RX_part.dart';
import '../../const/const.dart';
import '../../widgets/quick_tech_custom_drawer.dart';
import '../../widgets/quick_tech_snackbar.dart';
import 'diagnosis/quick_tech_custom_diagnosis_info.dart';

class QuickTechPrescriptionForm extends StatefulWidget {
  @override
  _QuickTechPrescriptionFormState createState() =>
      _QuickTechPrescriptionFormState();
}

class _QuickTechPrescriptionFormState extends State<QuickTechPrescriptionForm>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  final PatientInfoController patientInfoController =
      locator.get<PatientInfoController>();
  final QuickTechThemeController themeController =
      locator.get<QuickTechThemeController>();
  final MainDiagnosisController mainDiagnosisController =
      locator.get<MainDiagnosisController>();
  final QuicktechmainPrescriptionControllr prescrptionController =
      locator.get<QuicktechmainPrescriptionControllr>();
  late TabController _tabController;
  // Track completion state for each tab
  final RxList<bool> _tabCompleted = <bool>[false, false, false].obs;

  final RxBool _isSaving = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);

    // If user comes from assessment flow, prefill name/phone.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await patientInfoController.prefillFromAssessmentDraft();
      } catch (e) {
        print('Failed to prefill patient draft: $e');
      }
    });
  }

  @override
  void dispose() {
    try {
      _clearAllData();
    } catch (_) {}
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  void _clearAllData() {
    try {
      // Clear patient info
      patientInfoController.clearAllData();
      // Clear diagnosis data
      mainDiagnosisController.clearAllDiagnosisData();
      prescrptionController.clearAllRxData();
      _tabCompleted.value = [false, false, false];
      print('All form data cleared successfully when leaving page.');
    } catch (e) {
      print('Error clearing form data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            _clearAllData();
          }
        },
        child: Scaffold(
          backgroundColor:
              themeController.isDay.value
                  ? QuickTechAppColors.lightScaffoldColor
                  : QuickTechAppColors.darkScaffoldColor,
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(Icons.menu, color: Colors.white),
              ),
            ),
            backgroundColor:
                themeController.isDay.value
                    ? QuickTechAppColors.lightmaincolor
                    : QuickTechAppColors.darkmaincolor,
            elevation: 4,
            title: Text(
              'Add Prescription',
              style: myStyle(18, QuickTechAppColors.white, FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: QuickTechAppColors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Reset Form'),
                        content: Text(
                          'Are you sure you want to reset the entire form? All entered data will be lost.',
                        ),
                        actions: [
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Reset'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              _clearAllData();
                              Navigator.of(context).pop();
                              QuickTechSnackbar.success('Form reset successfully');
                              _tabController.animateTo(0);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.preview, color: QuickTechAppColors.white),
                onPressed: () async {
                  if (patientInfoController.patientId.value == 0) {
                    QuickTechSnackbar.error(
                      'Please save patient info first before previewing.',
                    );
                    _tabController.animateTo(0);
                    return;
                  }
                  await Get.toNamed('/preview');
                  try {
                    _clearAllData();
                    if (mounted) _tabController.animateTo(0);
                  } catch (e) {
                    print('Error clearing data after preview: $e');
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  themeController.isDay.value
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color:
                      themeController.isDay.value
                          ? Colors.yellow
                          : Colors.white,
                ),
                onPressed: themeController.toggleTheme,
              ),
            ],
          ),
          drawer: customDrawer(context),
          body: Padding(
            padding:  EdgeInsets.symmetric(horizontal: Responsive.isDesktop(context)?50.w:2.w),
            child: Column(
              children: [
                Obx(() => Container(
                  color:
                      themeController.isDay.value
                          ? QuickTechAppColors.lightmaincolor
                          : QuickTechAppColors.darkmaincolor,
                  child: TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(child: Text('Info', overflow: TextOverflow.ellipsis)),
                            SizedBox(width: 2),
                            if (_tabCompleted[0])
                              Icon(Icons.check_circle, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(child: Text('Diagnosis', overflow: TextOverflow.ellipsis)),
                            SizedBox(width: 2),
                            if (_tabCompleted[1])
                              Icon(Icons.check_circle, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(child: Text('Prescription', overflow: TextOverflow.ellipsis)),
                            SizedBox(width: 2),
                            if (_tabCompleted[2])
                              Icon(Icons.check_circle, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    ],
                    dividerColor:
                        themeController.isDay.value
                            ? QuickTechAppColors.lightmaincolor
                            : QuickTechAppColors.darkmaincolor,
                    indicatorColor: QuickTechAppColors.white,
                    labelStyle: myStyle(
                      14,
                      QuickTechAppColors.white,
                      FontWeight.bold,
                    ),
                    unselectedLabelStyle: myStyle(
                      14,
                      QuickTechAppColors.white.withValues(alpha: 0.6),
                      FontWeight.normal,
                    ),
                  ),
                )),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: customPatientInfo(context),
                      ),
                      SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: customDiagnosisInfo(context),
                      ),
                      SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                        child: customRxPart(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   heroTag: "next_tab",
          //   onPressed: () {
          //     if (mounted) {
          //       int nextIndex =
          //           (_tabController.index + 1) % _tabController.length;
          //       _tabController.animateTo(nextIndex);
          //     }
          //   },
          //   child: Icon(Icons.arrow_forward),
          // ),
          bottomNavigationBar: Padding(
            padding:  EdgeInsets.only(left: Responsive.isDesktop(context)?50.w: 15, right:Responsive.isDesktop(context)?50.w: 15, bottom: 20),
            child: Obx(
              () => QuickTechCustomButton(
                title: 'Save',
                onTab: (_isSaving.value || patientInfoController.isSaving.value)
                    ? null
                    : () async {
                        if (_isSaving.value) return;
                        _isSaving.value = true;
                        try {
                  if (_tabController.index == 0) {
                    try {
                      final userId = QuickTechAuthStorageService.getUser()?.id ?? 0;
                      final statusCode = await patientInfoController.updatePatientInfo(userId);

                      if (statusCode == 200) {
                        _tabCompleted[0] = true;
                        _showSavedDialog('Patient info', 1);
                      } else if (statusCode == 429) {
                        // Rate-limited: controller already showed a snackbar.
                        return;
                      } else {
                        print('Error saving patient info. Status code: $statusCode');
                        _showErrorDialog('Patient info', 'Failed with status code $statusCode. Please try again.');
                      }
                    } catch (e) {
                      print('Exception while saving patient info: $e');
                      _showErrorDialog('Patient info', 'Error: ${e.toString()}');
                    }
                  } else if (_tabController.index == 1) {
                    if (patientInfoController.patientId.value == 0) {
                      QuickTechSnackbar.error('Please save patient info first.');
                      _tabController.animateTo(0);
                      return;
                    }
                    try {
                      final isDiagnosisValid =
                          mainDiagnosisController.validateRequiredChildSelections();
                      if (!isDiagnosisValid) {
                        return;
                      }

                      final statusCode = await mainDiagnosisController.storeAllDiagnosisData();

                      if (statusCode == 200 || statusCode == 201) {
                        _tabCompleted[1] = true;
                        _showSavedDialog('Diagnosis info', 2);
                      } else {
                        print('Error storing diagnosis. Status code: $statusCode');
                        statusCode!=400?_showErrorDialog('Diagnosis info', 'Failed with status code $statusCode. Please try again.'):null;
                      }
                    } catch (e) {
                      print('Exception while storing diagnosis data: $e');
                      _showErrorDialog('Diagnosis info', 'Error: ${e.toString()}');
                    }
                  } else if (_tabController.index == 2) {
                    if (patientInfoController.patientId.value == 0) {
                      QuickTechSnackbar.error('Please save patient info first.');
                      _tabController.animateTo(0);
                      return;
                    }
                    try {
                      final statusCode = await prescrptionController.storeSelectedRxData();

                      if (statusCode == 200 || statusCode == 201) {
                        _tabCompleted[2] = true;
                        _showPrescriptionCompleteDialog();
                      } else {
                        print('Error storing prescription. Status code: $statusCode');
                        _showErrorDialog('Prescription info', 'Failed with status code $statusCode. Please try again.');
                      }
                    } catch (e) {
                      print('Exception while storing prescription data: $e');
                      _showErrorDialog('Prescription info', 'Error: ${e.toString()}');
                    }
                  }
                        } finally {
                          _isSaving.value = false;
                        }
                      },
                color:
                    themeController.isDay.value
                        ? QuickTechAppColors.lightmaincolor
                        : QuickTechAppColors.darkmaincolor,
                height: 50,
                width: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }void _showSavedDialog(String partName, int nextTabIndex) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Saved!'),
            ],
          ),
          content: Text('$partName has been saved successfully.'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: QuickTechAppColors.lightmaincolor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Go to Next'),
              onPressed: () {
                Navigator.of(context).pop();
                _tabController.animateTo(nextTabIndex);
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String partName, String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$partName failed to save.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                errorMessage,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Try Again'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Show completion dialog after successful prescription generation
  void _showPrescriptionCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Expanded(child: Text('Prescription Generated!')),
            ],
          ),
          content: Text(
            'Prescription has been generated and saved successfully.\n\nWould you like to start a new prescription?',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Back to Home'),
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllData();
                Get.offAll(()=>QuickTechMainHome());
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: QuickTechAppColors.lightmaincolor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('New Prescription'),
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllData();
                _tabController.animateTo(0);
              },
            ),
          ],
        );
      },
    );
  }
}
