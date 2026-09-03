import 'dart:io' as io;

import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/const/web_image.dart';
import 'package:e_prescription/controllers/profile_controller/quick_tech_profile_controller.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:e_prescription/widgets/quick_tech_custom_button.dart';
import 'package:e_prescription/widgets/quick_tech_custom_drawer.dart';
import 'package:e_prescription/widgets/quick_tech_custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class QuickTechProfileUpdatePage extends StatefulWidget {
  const QuickTechProfileUpdatePage({super.key});

  @override
  State<QuickTechProfileUpdatePage> createState() => _QuickTechProfileUpdatePageState();
}

class _QuickTechProfileUpdatePageState extends State<QuickTechProfileUpdatePage> {
  final themeController = locator.get<QuickTechThemeController>();
  final profileController = locator.get<QuickTechProfileController>();

  final TextEditingController centerNameController = TextEditingController();
  final TextEditingController centerAddressController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController therapyCenterController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController bnFirstNameController = TextEditingController();
  final TextEditingController bnTherapyCenterController = TextEditingController();
  final TextEditingController bnDesignationController = TextEditingController();
  final TextEditingController bnClinicAddressController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  bool _isNewImageSelected = false;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      centerNameController.text = profileController.centerName.value;
      centerAddressController.text = profileController.centerAddress.value;
      nameController.text = profileController.name.value;
      therapyCenterController.text = profileController.therapyCenter.value;
      designationController.text = profileController.designation.value;
      addressController.text = profileController.address.value;
      bnFirstNameController.text = profileController.bnFirstName.value;
      bnTherapyCenterController.text = profileController.bnTherapyCenter.value;
      bnDesignationController.text = profileController.bnDesignation.value;
      bnClinicAddressController.text = profileController.bnClinicAddress.value;
    });
  }

  @override
  void dispose() {
    centerNameController.dispose();
    centerAddressController.dispose();
    nameController.dispose();
    therapyCenterController.dispose();
    designationController.dispose();
    addressController.dispose();
    bnFirstNameController.dispose();
    bnTherapyCenterController.dispose();
    bnDesignationController.dispose();
    bnClinicAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: themeController.isDay.value
            ? const Color(0xFFF4F6FA)
            : QuickTechAppColors.darkScaffoldColor,
        drawer: customDrawer(context),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: themeController.isDay.value
              ? QuickTechAppColors.lightmaincolor
              : QuickTechAppColors.darkmaincolor,
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu, color: Colors.white),
            ),
          ),
          title: Text(
            'Update Profile',
            style: myStyle(18, QuickTechAppColors.white, FontWeight.bold),
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: themeController.isDay.value ? Colors.white : QuickTechAppColors.darkScaffoldColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Obx(() => SizedBox(
            height: 50,
            child: QuickTechCustomButton(
              onTab: () => profileController.saveProfile(
                isNewImage: _isNewImageSelected,
                localImagePath: _localImagePath,
              ),
              color: themeController.isDay.value
                  ? QuickTechAppColors.lightmaincolor
                  : QuickTechAppColors.darkmaincolor,
              title: profileController.isLoading.value ? 'Updating...' : 'Update Profile',
              height: 50,
              width: double.infinity,
            ),
          )),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width > 1200 ? 900 : 
                          MediaQuery.of(context).size.width > 600 ? 800 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo Card
                  _buildCard(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: QuickTechAppColors.lightmaincolor, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: QuickTechAppColors.lightmaincolor.withValues(alpha: 0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipOval(child: _buildProfileImage()),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: QuickTechAppColors.lightmaincolor,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Click to change photo',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeController.isDay.value ? Colors.grey[500] : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // English Info Card
                  _buildFormCard(
                    title: 'English Information',
                    icon: FontAwesomeIcons.globe.data,
                    fields: [
                      _FieldConfig('Clinic Name', centerNameController, FontAwesomeIcons.building.data,
                          (v) => profileController.centerName.value = v),
                      _FieldConfig('Clinic Address', centerAddressController, FontAwesomeIcons.mapLocationDot.data,
                          (v) => profileController.centerAddress.value = v),
                      _FieldConfig('Doctor Name', nameController, FontAwesomeIcons.user.data,
                          (v) => profileController.name.value = v),
                      _FieldConfig('Designation', therapyCenterController, FontAwesomeIcons.scaleBalanced.data,
                          (v) => profileController.therapyCenter.value = v),
                      _FieldConfig('Degree', designationController, FontAwesomeIcons.userDoctor.data,
                          (v) => profileController.designation.value = v),
                      _FieldConfig('Institute Address', addressController, FontAwesomeIcons.locationArrow.data,
                          (v) => profileController.address.value = v),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Bengali Info Card
                  _buildFormCard(
                    title: 'বাংলা তথ্য',
                    icon: FontAwesomeIcons.language.data,
                    fields: [
                      _FieldConfig('ডাক্তারের নাম (Doctor Name in Bengali)', bnFirstNameController, FontAwesomeIcons.user.data,
                          (v) => profileController.bnFirstName.value = v),
                      _FieldConfig('পদবী (Designation in Bengali)', bnTherapyCenterController, FontAwesomeIcons.houseChimneyMedical.data,
                          (v) => profileController.bnTherapyCenter.value = v),
                      _FieldConfig('ডিগ্রি (Degree in Bengali)', bnDesignationController, FontAwesomeIcons.userDoctor.data,
                          (v) => profileController.bnDesignation.value = v),
                      _FieldConfig('ইন্সিটিউট ঠিকানা (Institute Address in Bengali)', bnClinicAddressController, FontAwesomeIcons.locationArrow.data,
                          (v) => profileController.bnClinicAddress.value = v),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _isNewImageSelected = true;
        _localImagePath = pickedFile.path;
      });
    }
  }

  Widget _buildCard({required Widget child}) {
    final isDay = themeController.isDay.value;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDay ? Colors.white : QuickTechAppColors.darkScaffoldColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDay ? 0.07 : 0.25),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<_FieldConfig> fields,
  }) {
    final isDay = themeController.isDay.value;
    return Container(
      decoration: BoxDecoration(
        color: isDay ? Colors.white : QuickTechAppColors.darkScaffoldColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDay ? 0.07 : 0.25),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: QuickTechAppColors.lightmaincolor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 16, color: QuickTechAppColors.lightmaincolor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: myStyle(
                    15,
                    isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor,
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildResponsiveGrid(fields),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(List<_FieldConfig> fields) {
    return LayoutBuilder(builder: (context, constraints) {
      final crossAxisCount = constraints.maxWidth > 500 ? 2 : 1;
      final rows = <Widget>[];
      for (int i = 0; i < fields.length; i += crossAxisCount) {
        final rowFields = fields.sublist(i, (i + crossAxisCount).clamp(0, fields.length));
        rows.add(
          Row(
            children: rowFields
                .map((f) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: rowFields.last != f ? 12 : 0,
                        ),
                        child: _buildTextField(f),
                      ),
                    ))
                .toList(),
          ),
        );
        if (i + crossAxisCount < fields.length) rows.add(const SizedBox(height: 14));
      }
      return Column(children: rows);
    });
  }

  Widget _buildTextField(_FieldConfig f) {
    final isDay = themeController.isDay.value;
    return Padding(
      padding: EdgeInsets.zero,
      child: QuickTechCustomTextField(
        label: f.label,
        controller: f.controller,
        onchanged: f.onChanged,
        keyboardType: TextInputType.text,
        icon: f.icon,
        backcolor: isDay ? const Color(0xFFF8F9FC) : Colors.white.withValues(alpha: 0.05),
        height: 50,
        iconcolor: isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor,
        txtcolor: isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor,
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_localImagePath != null) {
      if (kIsWeb) {
        // On web, we can't use Image.file(), use WebImage or display placeholder
        if (profileController.profilePhoto.value.isNotEmpty) {
          final imageUrl = profileController.profilePhoto.value;
          final url = imageUrl.startsWith('http')
              ? imageUrl
              : '${Api.baseUrl}/${imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl}';
          return WebImage(imageUrl: url, fit: BoxFit.cover);
        }
      } else {
        // On mobile/desktop, use Image.file()
        if (io.File(_localImagePath!).existsSync()) {
          return Image.file(io.File(_localImagePath!), fit: BoxFit.cover);
        }
      }
    }
    if (profileController.profilePhoto.value.isNotEmpty) {
      final imageUrl = profileController.profilePhoto.value;
      final url = imageUrl.startsWith('http')
          ? imageUrl
          : '${Api.baseUrl}/${imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl}';
      return WebImage(imageUrl: url, fit: BoxFit.cover);
    }
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.person, size: 56, color: Colors.grey[500]),
    );
  }
}

class _FieldConfig {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Function(String) onChanged;
  const _FieldConfig(this.label, this.controller, this.icon, this.onChanged);
}