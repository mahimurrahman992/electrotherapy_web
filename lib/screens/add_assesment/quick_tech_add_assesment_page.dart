import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/widgets/quick_tech_snackbar.dart';
import 'package:e_prescription/controllers/assessment_controller/assestive_device/quick_tech_assestive_device_controller.dart';
import 'package:e_prescription/controllers/assessment_controller/birth_history/quick_tech_birth_history_controller.dart';
import 'package:e_prescription/controllers/assessment_controller/differential_diagnosis/quick_tech_differential_diagnosis_controller.dart';
import 'package:e_prescription/controllers/assessment_controller/family_history/quick_tech_family_history_controller.dart';
import 'package:e_prescription/controllers/assessment_controller/home_advice/quick_tech_home_advice_controller.dart';
import 'package:e_prescription/controllers/assessment_controller/mother_health_condition_during_pregnancy/quick_tech_mother_health_controller.dart';
import 'package:e_prescription/controllers/assessment_controller/muscle_power/quick_tech_muscle_power_controller.dart';
import 'package:e_prescription/controllers/assessment_controller/occupation_history/quick_tech_occupation_history_controller.dart';
import 'package:e_prescription/controllers/assessment_controller/on_examination/quick_tech_on_examination_controller.dart';
import 'package:e_prescription/controllers/assessment_controller/past_medical_history/quick_tech_past_medical_history_controller.dart';
import 'package:e_prescription/controllers/assessment_controller/patient_info/quick_tech_patient_info_controlle.dart';
import 'package:e_prescription/controllers/assessment_controller/problem_summary/quick_tech_problem_summary_controller.dart';
import 'package:e_prescription/controllers/assessment_controller/range_of_motion/quick_tech_range0f_motion_controller.dart';
import 'package:e_prescription/controllers/assessment_controller/referred_to/quick_tech_referred_to_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/responsive.dart';
import 'package:e_prescription/screens/add_assesment/assestive_device/quick_tech_assestive_device.dart';
import 'package:e_prescription/screens/add_assesment/birth_history/quick_tech_birth_history.dart';
import 'package:e_prescription/screens/add_assesment/differential_diagnosis/quick_tech_differential_diagnosis.dart';
import 'package:e_prescription/screens/add_assesment/family_history/quick_tech_family_history.dart';
import 'package:e_prescription/screens/add_assesment/home_advice/quick_tech_home_advice.dart';
import 'package:e_prescription/screens/add_assesment/mother_health_condition_during_pregnancy/quick_tech_mother_health.dart';
import 'package:e_prescription/screens/add_assesment/muscle_power/quick_tech_muscle_power.dart';
import 'package:e_prescription/screens/add_assesment/occupation_history/quick_tech_occupation_history.dart';
import 'package:e_prescription/screens/add_assesment/on_examination/quick_tech_on_examintion.dart';
import 'package:e_prescription/screens/add_assesment/past_medical_historu/quick_tech_past_medical_history.dart';
import 'package:e_prescription/screens/add_assesment/patient_info/quick_tech_patient_info.dart';
import 'package:e_prescription/screens/add_assesment/problem_summary_goal/quick_tech_problem_summary.dart';
import 'package:e_prescription/screens/add_assesment/range_of_motion/quick_tech_range_of_motion.dart';
import 'package:e_prescription/screens/add_assesment/referred_to/quick_tech_referred_to.dart';
import 'package:e_prescription/widgets/quick_tech_custom_button.dart';
import 'package:e_prescription/widgets/quick_tech_custom_drawer.dart';
import 'package:e_prescription/services/quick_tech_patient_draft_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_prescription/locator.dart';

class QuickTechAddAssesmentPage extends StatefulWidget {
  @override
  _QuickTechAddAssesmentPageState createState() =>
      _QuickTechAddAssesmentPageState();
}

class _QuickTechAddAssesmentPageState extends State<QuickTechAddAssesmentPage>
    with TickerProviderStateMixin {
  final QuickTechThemeController themeController =
      locator.get<QuickTechThemeController>();
  final RxList<bool> _tabCompleted =
      <bool>[
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
      ].obs;

  final QuickTechPatientInfoController patientInfoController =
      locator.get<QuickTechPatientInfoController>();
  final QuickTechOccupationHistoryController occupationHistoryController =
      locator.get<QuickTechOccupationHistoryController>();
  final QuickTechFamilyHistoryController familyHistoryController =
      locator.get<QuickTechFamilyHistoryController>();
  final QuickTechBirthHistoryController birthHistoryController =
      locator.get<QuickTechBirthHistoryController>();
  final QuickTechMotherHealthController motherHealthController =
      locator.get<QuickTechMotherHealthController>();
  final QuickTechPastMedicalHistoryController pastMedicalHistoryController =
      locator.get<QuickTechPastMedicalHistoryController>();
  final QuickTechOnExaminationController onExaminationController =
      locator.get<QuickTechOnExaminationController>();
  final QuickTechMusclePowerController musclePowerController =
      locator.get<QuickTechMusclePowerController>();
  final QuickTechRange0fMotionController range0fMotionController =
      locator.get<QuickTechRange0fMotionController>();
  final QuickTechProblemSummaryController problemSummaryController =
      locator.get<QuickTechProblemSummaryController>();
  final QuickTechHomeAdviceController homeAdviceController =
      locator.get<QuickTechHomeAdviceController>();
  final QuickTechDifferentialDiagnosisController
  differentialDiagnosisController =
      locator.get<QuickTechDifferentialDiagnosisController>();
  final QuickTechAssestiveDeviceController assestiveDeviceController =
      locator.get<QuickTechAssestiveDeviceController>();
  final QuickTechReferredToController referredToController =
      locator.get<QuickTechReferredToController>();

  late TabController _tabController;
  DateTime _lastSaveTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const int _saveDebounceMs = 2000;
  final RxBool _isSaving = false.obs;

  static const List<String> _tabNames = [
    'Patient Info',
    'Occupation History',
    'Family History',
    'Birth History',
    'Mother Health',
    'Past Medical History',
    'On Examination',
    'Muscle Power',
    'Range of Motion',
    'Problem Summary',
    'Home Advice',
    'Differential Diagnosis',
    'Assistive Device',
    'Referred To',
  ];

  static const List<IconData> _tabIcons = [
    Icons.person,
    Icons.work,
    Icons.family_restroom,
    Icons.child_care,
    Icons.pregnant_woman,
    Icons.history,
    Icons.medical_services,
    Icons.fitness_center,
    Icons.accessibility_new,
    Icons.summarize,
    Icons.home,
    Icons.biotech,
    Icons.devices,
    Icons.forward,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 14, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _clearAllAssessmentData() {
    patientInfoController.clearPatientInfo();
    occupationHistoryController.clearOccupationHistory();
    familyHistoryController.clearFamilyHistory();
    birthHistoryController.clearBirthHistory();
    motherHealthController.clearMotherHealth();
    pastMedicalHistoryController.clearPastMedicalHistory();
    onExaminationController.clearForm();
    musclePowerController.clearMusclePower();
    range0fMotionController.clearRangeOfMotion();
    problemSummaryController.clearProblemSummary();
    homeAdviceController.clearHomeAdvice();
    differentialDiagnosisController.clearDifferentialDiagnosis();
    assestiveDeviceController.clearAssestiveDevice();
    referredToController.clearReferredTo();
  }

  Future<void> _handleSaveAction() async {
    if (_isSaving.value) return;

    final now = DateTime.now();
    if (now.difference(_lastSaveTime).inMilliseconds < _saveDebounceMs) {
      QuickTechSnackbar.warning('Please wait before saving again');
      return;
    }
    _lastSaveTime = now;

    final currentIndex = _tabController.index;
    int status = 500;
    final sectionName = _tabNames[currentIndex];
    final nextTabIndex = currentIndex < 13 ? currentIndex + 1 : 13;

    if (currentIndex > 0 && !_validatePatientId()) return;

    if (currentIndex > 0) {
      final bool hasData = switch (currentIndex) {
        1 => occupationHistoryController.hasData(),
        2 => familyHistoryController.hasData(),
        3 => birthHistoryController.hasData(),
        4 => motherHealthController.hasData(),
        5 => pastMedicalHistoryController.hasData(),
        6 => onExaminationController.hasData(),
        7 => musclePowerController.hasData(),
        8 => range0fMotionController.hasData(),
        9 => problemSummaryController.hasData(),
        10 => homeAdviceController.hasData(),
        11 => differentialDiagnosisController.hasData(),
        12 => assestiveDeviceController.hasData(),
        13 => referredToController.hasData(),
        _ => false,
      };
      if (!hasData) {
        _showValidationErrorDialog(sectionName);
        return;
      }
    }

    _isSaving.value = true;
    try {
      const timeout = Duration(seconds: 20);
      final pid = patientInfoController.currentPatientId;
      status = await switch (currentIndex) {
        0 => patientInfoController.postPatientInfo().timeout(
          timeout,
          onTimeout: () => 408,
        ),
        1 => occupationHistoryController
            .storeOccupationHistory(patientId: pid!)
            .timeout(timeout, onTimeout: () => 408),
        2 => familyHistoryController
            .storeFamilyHistory(patientId: pid!)
            .timeout(timeout, onTimeout: () => 408),
        3 => birthHistoryController
            .storeBirthHistory(patientId: pid!)
            .timeout(timeout, onTimeout: () => 408),
        4 => motherHealthController
            .storeMotherHealthCondition(patientId: pid!)
            .timeout(timeout, onTimeout: () => 408),
        5 => pastMedicalHistoryController
            .storePastMedicalHistory(patientId: pid!)
            .timeout(timeout, onTimeout: () => 408),
        6 => onExaminationController
            .storeOnExamination(
              date: DateTime.now().toString(),
              patientId: pid!,
            )
            .timeout(timeout, onTimeout: () => 408),
        7 => musclePowerController
            .submitMusclePowerData(patientId: pid!)
            .timeout(timeout, onTimeout: () => 408),
        8 => range0fMotionController
            .submitRangeOfMotionData(patientId: pid!)
            .timeout(timeout, onTimeout: () => 408),
        9 => problemSummaryController
            .storeSummaryAdvice(pid!)
            .timeout(timeout, onTimeout: () => 408),
        10 => homeAdviceController
            .storeHomeAdvice(patientId: pid!)
            .timeout(timeout, onTimeout: () => 408),
        11 => differentialDiagnosisController
            .storeAssessmentDiagnosis()
            .timeout(timeout, onTimeout: () => 408),
        12 => assestiveDeviceController.storeAssestiveDeviceData().timeout(
          timeout,
          onTimeout: () => 408,
        ),
        13 => referredToController
            .storeReferredTo(pid!)
            .timeout(timeout, onTimeout: () => 408),
        _ => Future.value(500),
      };

      if (currentIndex == 0 && (status == 200 || status == 201)) {
        await QuickTechPatientDraftStorageService.saveDraft(
          name: patientInfoController.patientNameController.text,
          phone: patientInfoController.phoneController.text,
          age: patientInfoController.ageController.text,
          gender: patientInfoController.sex.value ?? '',
        );
      }
    } catch (e, stack) {
      debugPrint('[$sectionName] Save error: $e\n$stack');
      status = 500;
    } finally {
      _isSaving.value = false;
    }

    if (status == 200 || status == 201) {
      _tabCompleted[currentIndex] = true;
      if (currentIndex == 13)
        _showPrescriptionConfirmDialog();
      else
        _showSavedDialog(sectionName, nextTabIndex);
    } else {
      _showErrorDialog(sectionName, status);
    }
  }

  bool _validatePatientId() {
    if (patientInfoController.currentPatientId == null) {
      QuickTechSnackbar.error('Please save patient info first.');
      _tabController.animateTo(0);
      return false;
    }
    return true;
  }

  // ── Tab content pages ──────────────────────────────────────────────────────
  static final List<Widget> _tabViews = [
    generalInfoPage(),
    OccupationHistory(),
    FamilyHistory(),
    BirthHistory(),
    MotherHealthCondition(),
    PastMedicalHistory(),
    OnExamination(),
    MusclePower(),
    RangeofMotion(),
    ProblemSummary(),
    HomeAdvice(),
    DifferentialDiagnosis(),
    AssestiveDevice(),
    ReferredTo(),
  ];

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDay = themeController.isDay.value;
      final mainColor =
          isDay
              ? QuickTechAppColors.lightmaincolor
              : QuickTechAppColors.darkmaincolor;
      final scaffoldColor =
          isDay
              ? QuickTechAppColors.lightScaffoldColor
              : QuickTechAppColors.darkScaffoldColor;

      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) _clearAllAssessmentData();
        },
        child: Scaffold(
          backgroundColor: scaffoldColor,
          appBar: _buildAppBar(isDay, mainColor),
          drawer: customDrawer(context),
          body: Responsive(
            mobile: _buildMobileLayout(mainColor),
            tablet: _buildTabletLayout(mainColor),
            desktop: _buildDesktopLayout(mainColor, scaffoldColor),
          ),
          bottomNavigationBar: Responsive(
            mobile: _buildBottomBar(mainColor),
            desktop: const SizedBox.shrink(), // desktop uses side panel buttons
          ),
          floatingActionButton:
              Responsive.isDesktop(context)
                  ? null
                  : FloatingActionButton(
                    backgroundColor: mainColor,
                    onPressed: () {
                      int next =
                          (_tabController.index + 1) % _tabController.length;
                      _tabController.animateTo(next);
                    },
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(bool isDay, Color mainColor) {
    return AppBar(
      leading: Builder(
        builder:
            (ctx) => IconButton(
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              icon: const Icon(Icons.menu, color: Colors.white),
            ),
      ),
      backgroundColor: mainColor,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.assignment, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'Add Assessment',
            style: myStyle(18, QuickTechAppColors.white, FontWeight.bold),
          ),
        ],
      ),
      actions: [
        _appBarBtn(Icons.preview, () => Get.toNamed('/assessmentpreview')),
        _appBarBtn(
          isDay ? Icons.light_mode : Icons.dark_mode,
          themeController.toggleTheme,
          color: isDay ? Colors.yellow : Colors.white,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _appBarBtn(
    IconData icon,
    VoidCallback onTap, {
    Color color = Colors.white,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onTap,
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }

  // ── Mobile layout: scrollable top TabBar ──────────────────────────────────
  Widget _buildMobileLayout(Color mainColor) {
    return Column(
      children: [
        _buildTopTabBar(mainColor),
        Expanded(child: _buildTabContent()),
      ],
    );
  }

  // ── Tablet layout: same as mobile but slightly wider tabs ──────────────────
  Widget _buildTabletLayout(Color mainColor) => _buildMobileLayout(mainColor);

  // ── Desktop layout: fixed left rail + content, bottom action bar ─────────
  Widget _buildDesktopLayout(Color mainColor, Color scaffoldColor) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // Left navigation rail
              Container(
                width: 220,
                color: mainColor,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: 14,
                  itemBuilder: (_, i) => _buildRailItem(i, mainColor),
                ),
              ),
              // Main content
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),

        // Bottom action bar (desktop)
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: scaffoldColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Progress indicator
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.assignment_turned_in_rounded,
                        color: mainColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: _tabCompleted.where((b) => b).length / 14,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(mainColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_tabCompleted.where((b) => b).length} / 14',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Next Tab button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: mainColor,
                    side: BorderSide(color: mainColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    int next =
                        (_tabController.index + 1) % _tabController.length;
                    _tabController.animateTo(next);
                  },
                  icon: const Icon(Icons.navigate_next_rounded, size: 18),
                  label: const Text(
                    'Next Tab',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(width: 12),

                // Save button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: _isSaving.value ? 0 : 2,
                  ),
                  onPressed: _isSaving.value ? null : _handleSaveAction,
                  icon:
                      _isSaving.value
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.save_rounded, size: 18),
                  label: Text(
                    _isSaving.value ? 'Saving...' : 'Save',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Proceed button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed:
                      _isSaving.value ? null : _showPrescriptionConfirmDialog,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'Proceed',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRailItem(int i, Color mainColor) {
    return Obx(() {
      final isSelected = _tabController.index == i;
      final isDone = _tabCompleted[i];
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withValues(alpha:0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border:
              isSelected
                  ? Border.all(color: Colors.white.withValues(alpha:0.4))
                  : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: ListTile(
            dense: true,
            leading: Icon(
              isDone ? Icons.check_circle_rounded : _tabIcons[i],
              color:
                  isDone
                      ? Colors.greenAccent
                      : Colors.white.withValues(alpha:isSelected ? 1 : 0.7),
              size: 20,
            ),
            title: Text(
              _tabNames[i],
              style: TextStyle(
                color: Colors.white.withValues(alpha:isSelected ? 1 : 0.75),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _tabController.animateTo(i),
          ),
        ),
      );
    });
  }



  // ── Shared tab bar (mobile/tablet) ─────────────────────────────────────────
  Widget _buildTopTabBar(Color mainColor) {
    return Container(
      color: mainColor,
      child: TabBar(
        physics: const BouncingScrollPhysics(),
        tabAlignment: TabAlignment.start,
        isScrollable: true,
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: mainColor,
        labelStyle: myStyle(13, QuickTechAppColors.white, FontWeight.bold),
        unselectedLabelStyle: myStyle(
          13,
          QuickTechAppColors.white.withValues(alpha:0.6),
          FontWeight.normal,
        ),
        tabs: List.generate(
          14,
          (i) => Tab(
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _tabCompleted[i]
                        ? Icons.check_circle_rounded
                        : _tabIcons[i],
                    size: 16,
                    color: _tabCompleted[i] ? Colors.greenAccent : Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _tabNames[i],
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab content ────────────────────────────────────────────────────────────
  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children:
          _tabViews
              .map(
                (w) => SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: w,
                ),
              )
              .toList(),
    );
  }

  // ── Bottom bar (mobile/tablet only) ───────────────────────────────────────
  Widget _buildBottomBar(Color mainColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: QuickTechCustomButton(
                title: 'Save',
                onTab: _isSaving.value ? null : () => _handleSaveAction(),
                color: mainColor,
                height: 48,
                width: double.infinity,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed:
                    _isSaving.value ? null : _showPrescriptionConfirmDialog,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(
                  'Proceed',
                  style: myStyle(14, Colors.white, FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialogs (unchanged logic) ──────────────────────────────────────────────
  void _showErrorDialog(String sectionName, int statusCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 28),
                const SizedBox(width: 8),
                const Expanded(child: Text('Save Failed')),
              ],
            ),
            content: Text('Failed to save $sectionName.\nStatus: $statusCode'),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showSavedDialog(String sectionName, int nextTabIndex) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                const Text('Saved!'),
              ],
            ),
            content: Text('$sectionName saved successfully.'),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: QuickTechAppColors.lightmaincolor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _tabController.animateTo(nextTabIndex);
                },
                child: const Text('Go to Next'),
              ),
            ],
          ),
    );
  }

  void _showValidationErrorDialog(String sectionName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 8),
                const Expanded(child: Text('No Data')),
              ],
            ),
            content: Text(
              'Please enter at least 1 item for $sectionName before saving.',
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showPrescriptionConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
                const SizedBox(width: 8),
                const Expanded(child: Text('Assessment Complete!')),
              ],
            ),
            content: const Text(
              'All assessment data saved.\n\nProceed to generate a prescription?',
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Stay'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: QuickTechAppColors.lightmaincolor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _clearAllAssessmentData();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Get.toNamed('/prescriptionform');
                
                  });
                },
                child: const Text('Continue to Prescription'),
              ),
            ],
          ),
    );
  }
}