import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_prescription/const/const.dart';

import 'package:e_prescription/const/web_image.dart';

import 'package:e_prescription/screens/profile/profile_update/quick_tech_profile_update.dart';
import 'package:e_prescription/utils/api.dart';


import 'package:flutter/foundation.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:e_prescription/controllers/profile_controller/quick_tech_profile_controller.dart';

class QuickTechProfilePage extends StatefulWidget {
  final bool isAppBarVisible;
  const QuickTechProfilePage({super.key, required this.isAppBarVisible});

  @override
  State<QuickTechProfilePage> createState() => _QuickTechProfilePageState();
}

class _QuickTechProfilePageState extends State<QuickTechProfilePage> {
  final themeController = locator.get<QuickTechThemeController>();
  final profileController = locator.get<QuickTechProfileController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: themeController.isDay.value
            ? const Color(0xFFF4F6FA)
            : QuickTechAppColors.darkScaffoldColor,
        appBar: widget.isAppBarVisible
            ? AppBar(
                elevation: 0,
                backgroundColor: themeController.isDay.value
                    ? QuickTechAppColors.lightmaincolor
                    : QuickTechAppColors.darkmaincolor,
                leading: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
                ),
                title: Text(
                  'Profile',
                  style: myStyle(18, QuickTechAppColors.white, FontWeight.bold),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: TextButton.icon(
                      onPressed: () => Get.toNamed('/profileupdate'),
                      icon: Icon(FontAwesomeIcons.penToSquare.data, color: Colors.white, size: 16),
                      label: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                    ),
                  ),
                ],
              )
            : null,
        body: Obx(() {
          if (profileController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (profileController.error.isNotEmpty) {
            return Center(child: Text(profileController.error.value));
          }
          return Center(
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
                    // Hero Card
                    _buildHeroCard(),
                    const SizedBox(height: 24),
                    // English Info Card
                    _buildSectionCard(
                      title: 'English Information',
                      icon: FontAwesomeIcons.globe.data,
                      tiles: [
                        _tileData(FontAwesomeIcons.building.data, 'Clinic Name', profileController.centerName.value, 'No Clinic Name'),
                        _tileData(FontAwesomeIcons.mapLocationDot.data, 'Clinic Address', profileController.centerAddress.value, 'No Clinic Address'),
                        _tileData(FontAwesomeIcons.user.data, 'Doctor Name', profileController.name.value, 'No Name'),
                        _tileData(FontAwesomeIcons.scaleBalanced.data, 'Designation', profileController.therapyCenter.value, 'No Therapy Center'),
                        _tileData(FontAwesomeIcons.userDoctor.data, 'Degree', profileController.designation.value, 'No Designation'),
                        _tileData(FontAwesomeIcons.locationArrow.data, 'Institute Address', profileController.address.value, 'No Institute Address'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Bengali Info Card
                    _buildSectionCard(
                      title: 'বাংলা তথ্য ',
                      icon: FontAwesomeIcons.language.data,
                      tiles: [
                        _tileData(FontAwesomeIcons.user.data, 'ডাক্তারের নাম', profileController.bnFirstName.value, 'নাম নেই'),
                        _tileData(FontAwesomeIcons.houseChimneyMedical.data, 'পদবী', profileController.bnTherapyCenter.value, 'থেরাপি সেন্টার নেই'),
                        _tileData(FontAwesomeIcons.userDoctor.data, 'ডিগ্রি', profileController.bnDesignation.value, 'ডিগ্রি নেই'),
                        _tileData(FontAwesomeIcons.locationArrow.data, 'ইন্সিটিউট ঠিকানা', profileController.bnClinicAddress.value, 'ইন্সিটিউট নেই'),
                      ],
                    ),
                    if (!widget.isAppBarVisible) ...[
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 50,
                        child: QuickTechCustomButton(
                          onTab: () => Get.to(() => QuickTechProfileUpdatePage()),
                          color: themeController.isDay.value
                              ? QuickTechAppColors.lightmaincolor
                              : QuickTechAppColors.darkmaincolor,
                          title: 'Update Profile',
                          height: 50,
                          width: double.infinity,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Map<String, dynamic> _tileData(IconData icon, String label, String value, String fallback) {
    return {'icon': icon, 'label': label, 'value': value, 'fallback': fallback};
  }

  Widget _buildHeroCard() {
    final isDay = themeController.isDay.value;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 500;
        final imageSize = isMobile ? 80.0 : 100.0;

        final padding = isMobile ? 20.0 : 28.0;
        
        return Container(
          padding: EdgeInsets.all(padding),
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
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: imageSize,
                      height: imageSize,
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
                      child: ClipOval(
                        child: kIsWeb
                            ? WebImage(
                                imageUrl: "${Api.baseUrl}/${profileController.profilePhoto.value}",
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: "${Api.baseUrl}/${profileController.profilePhoto.value}",
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          profileController.name.value.isNotEmpty
                              ? profileController.name.value
                              : 'No Name',
                          style: myStyle(
                            14.sp,
                            isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor,
                            FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (profileController.designation.value.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            profileController.designation.value,
                            style: myStyle(12.sp, QuickTechAppColors.lightmaincolor, FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        if (profileController.centerName.value.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FontAwesomeIcons.building.data, size: 12,
                                  color: isDay ? Colors.grey[500] : Colors.grey[400]),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  profileController.centerName.value,
                                  style: TextStyle(fontSize: 12, color: isDay ? Colors.grey[600] : Colors.grey[400]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: imageSize,
                      height: imageSize,
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
                      child: ClipOval(
                        child: kIsWeb
                            ? WebImage(
                                imageUrl: "${Api.baseUrl}/${profileController.profilePhoto.value}",
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: "${Api.baseUrl}/${profileController.profilePhoto.value}",
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    SizedBox(width: padding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profileController.name.value.isNotEmpty
                                ? profileController.name.value
                                : 'No Name',
                            style: myStyle(
                              16.sp,
                              isDay ? QuickTechAppColors.lightmaintextcolor : QuickTechAppColors.darkmaintextcolor,
                              FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (profileController.designation.value.isNotEmpty)
                            Text(
                              profileController.designation.value,
                              style: myStyle(12.sp, QuickTechAppColors.lightmaincolor, FontWeight.w600),
                            ),
                          if (profileController.centerName.value.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(FontAwesomeIcons.building.data, size: 12,
                                    color: isDay ? Colors.grey[500] : Colors.grey[400]),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    profileController.centerName.value,
                                    style: TextStyle(fontSize: 13, color: isDay ? Colors.grey[600] : Colors.grey[400]),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> tiles,
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
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
          LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth > 600 ? 2 : 1,
                  mainAxisExtent: 76,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: tiles.length,
                itemBuilder: (context, index) {
                  final t = tiles[index];
                  final value = (t['value'] as String).isNotEmpty ? t['value'] as String : t['fallback'] as String;
                  final isEmpty = (t['value'] as String).isEmpty;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDay ? const Color(0xFFF8F9FC) : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDay ? const Color(0xFFE8EAF0) : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          t['icon'] as IconData,
                          size: 16,
                          color: isEmpty
                              ? Colors.grey[400]
                              : QuickTechAppColors.lightmaincolor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                t['label'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDay ? Colors.grey[500] : Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                value,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isEmpty
                                      ? (isDay ? Colors.grey[400] : Colors.grey[600])
                                      : (isDay
                                          ? QuickTechAppColors.lightmaintextcolor
                                          : QuickTechAppColors.darkmaintextcolor),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}