class Api {
  static String baseUrl = 'https://app.mostaq.com';

  static String register = '$baseUrl/api/register';
  static String login = '$baseUrl/api/login';
  static String verify = '$baseUrl/api/verify';
  static String forgetPassword = '$baseUrl/api/forget/password';
  static String resetPassword = '$baseUrl/api/reset/password';
  static String logout = '$baseUrl/api/logout';
  static String resend = '$baseUrl/api/resend';
  static String getProfile = '$baseUrl/api/user/profile';
static String updateProfile = '$baseUrl/api/user/profile/store';
static String sliderApi='$baseUrl/api/slider-list';

  ///Prescription-GetAPI

  static String getDiagnosis =
      '$baseUrl/api/diagnosis/categories/with/all'; //Prescription
  static String searchDiagnosis(int id, String name) =>
      '$baseUrl/api/search/subcategory/of/category/$id?name=$name'; // Prescription
  static String getElectrotherapyPrescription =
      '$baseUrl/api/electro-therapies/all'; //Prescription
  static String getManualTherapyPrescription =
      '$baseUrl/api/manual-therapies/with/sub'; //Prescription
  static String getMiscellaneousPrescription =
      '$baseUrl/api/miscellaneous-therapies/with/sub'; //Prescription
  static String getSpeechLangTherapyPrescription =
      '$baseUrl/api/speech-and-language-therapies'; //Prescription
  static String searchPrescription(String categoryName, String name) =>
      '$baseUrl/api/search/therapies/of/$categoryName?name=$name'; //Prescription

///Prescription-PostAPI
  static String updatePrescriptionPatientInfo =
      '$baseUrl/api/prescribe/patient/update'; //Prescription
  static String updateDiagnosis="$baseUrl/api/prescription/diagnosis/store";//Prescription_diagnosis
  static String updateElectroPresc =
      '$baseUrl/api/electro-therapy/store'; //Prescription_Electrothreapy
  static String updateotherallPresc =
      '$baseUrl/api/other-therapy/store'; //Prescription_othersall Therapy




  ///Assessment-GetAPI
  static String getMedicalHistoryAsses =
      "$baseUrl/api/medical-history/all"; //Assessment_PastMedicalHistory
  static String getBodyTypeAsses =
      "$baseUrl/api/body-type/options"; //Assessment_OnExamination
  static String getPostureAsses = "$baseUrl/api/posture/all"; //Assessment_OnExamination
  static String getGaitAsses = "$baseUrl/api/gait/all"; //Assessment_OnExamination
  static String getReflexAsses = "$baseUrl/api/reflex/grades"; //Assessment_OnExamination
  static String getSensoryAsses = "$baseUrl/api/sensory/grades"; //Assessment_OnExamination
  static String getMotorAsses = "$baseUrl/api/motor/grades"; //Assessment_OnExamination
  static String getMuscleToneAsses =
      "$baseUrl/api/muscle-tone/grades"; //Assessment_OnExamination
  static String getSpasticityAsses =
      "$baseUrl/api/spasticity/grades"; //Assessment_OnExamination
  static String getBowelBladderAsses =
      "$baseUrl/api/bowel-bladder-control/grades"; //Assessment_OnExamination
      static String getOxfordMuscleAsses =
      "$baseUrl/api/oxford-muscle/grades"; //Assessment_MusclePower

      static String getReflexAll="$baseUrl/api/reflex/all"; //Assessment_Reflex
  static String getPercussionOptions="$baseUrl/api/percussion/options"; //Assessment_percussion
  static String getPulseOptions="$baseUrl/api/pulse/options"; //Assessment_pulse
  static String getInflammatorySignOptions="$baseUrl/api/inflammatory-sign/all"; //Assessment_InflammatorySign

///Assessment-PostAPI

static String updateAssessmentPatientInfo="$baseUrl/api/assessment/patient/update";//Assessment_patientInfo
static String updateOccupationHistory="$baseUrl/api/occupation/history/update"; //Assessment_occupationHistory
static String updateFamilyHistory="$baseUrl/api/family/history/update"; //Assessment_familyHistory
static String updateBirthHHistory="$baseUrl/api/birth/history/update"; //Assessment_birthHistory
static String updateMotherHealthHistory="$baseUrl/api/mother-pregnancy/health/update"; //Assessment_motherPregnancyHistory
///package
static String getPackage="$baseUrl/api/package/all"; //package
static String getMyPackage="$baseUrl/api/user/package"; //package
static String subscribePackage="$baseUrl/api/subscribe/package"; //package

}


