import 'dart:typed_data';
import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class QuickTechPdfPrescription extends StatefulWidget {
  final Uint8List pdfBytes;
  const QuickTechPdfPrescription({required this.pdfBytes});

  @override
  _QuickTechPdfPrescriptionState createState() =>
      _QuickTechPdfPrescriptionState();
}

class _QuickTechPdfPrescriptionState extends State<QuickTechPdfPrescription> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  final QuickTechThemeController themeController =
      locator.get<QuickTechThemeController>();

  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('PdfViewScreen: ${widget.pdfBytes.length} bytes');
    debugPrint('First 4 bytes: ${widget.pdfBytes.take(4).toList()}');
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDay = themeController.isDay.value;
      final mainColor =
          isDay
              ? QuickTechAppColors.lightmaincolor
              : QuickTechAppColors.darkmaincolor;
      final isDesktop = Responsive.isDesktop(context);
      return Scaffold(
        backgroundColor:
            isDay
                ? const Color(0xFFF4F6FA)
                : QuickTechAppColors.darkScaffoldColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: mainColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.white,
            ),
            onPressed: () => Get.back(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prescription',
                style: myStyle(
                  isDesktop ? 18 : 16,
                  Colors.white,
                  FontWeight.bold,
                ),
              ),
              if (_totalPages > 0)
                Text(
                  'Page $_currentPage of $_totalPages',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
            ],
          ),
        ),
        body:
            widget.pdfBytes.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.picture_as_pdf_outlined,
                        size: 64.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No PDF data received',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Please go back and try again',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                )
                : Responsive(
                  mobile: _MobileLayout(),
                  tablet: _TabletLayout(),
                  desktop: _DesktopLayout(),
                ),
      );
    });
  }

  // ===== RESPONSIVE LAYOUTS =====

  Widget _MobileLayout() {
    return Column(
      children: [Expanded(child: PdfViewer()), MobileNavBar()],
    );
  }

  Widget _TabletLayout() {
    return Column(
      children: [Expanded(child: PdfViewer()), TabletNavBar()],
    );
  }

  Widget _DesktopLayout() {
    return Column(
      children: [Expanded(child: PdfViewer()), DesktopNavBar()],
    );
  }

  // ===== PDF VIEWER BUILDER =====

  Widget PdfViewer() {
    return SfPdfViewer.memory(
      widget.pdfBytes,
      controller: _pdfViewerController,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      pageLayoutMode: PdfPageLayoutMode.single,
      scrollDirection: PdfScrollDirection.vertical,
      onPageChanged: (d) {
        if (mounted) setState(() => _currentPage = d.newPageNumber);
      },
      onDocumentLoaded: (d) {
        if (mounted)
          setState(() {
            _totalPages = d.document.pages.count;
            _currentPage = 1;
          });
      },
      onDocumentLoadFailed: (d) {
        debugPrint('PDF load failed: ${d.error} — ${d.description}');
        Get.snackbar(
          'Load Failed',
          d.description,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }



  // ===== RESPONSIVE NAVIGATION BARS =====

  Widget MobileNavBar() {
    final mainColor =
        themeController.isDay.value
            ? QuickTechAppColors.lightmaincolor
            : QuickTechAppColors.darkmaincolor;

    return Container(
      decoration: BoxDecoration(
        color:
            themeController.isDay.value
                ? Colors.white
                : const Color(0xFF1E2230),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MobileNavBtn(
            Icons.first_page,
            'First',
            mainColor,
            () => _pdfViewerController.firstPage(),
          ),
          MobileNavBtn(
            Icons.navigate_before,
            'Prev',
            mainColor,
            () => _pdfViewerController.previousPage(),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              _totalPages > 0 ? '$_currentPage / $_totalPages' : '— / —',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
          ),
          MobileNavBtn(
            Icons.navigate_next,
            'Next',
            mainColor,
            () => _pdfViewerController.nextPage(),
          ),
          MobileNavBtn(
            Icons.last_page,
            'Last',
            mainColor,
            () => _pdfViewerController.lastPage(),
          ),
        ],
      ),
    );
  }

  Widget TabletNavBar() {
    final mainColor =
        themeController.isDay.value
            ? QuickTechAppColors.lightmaincolor
            : QuickTechAppColors.darkmaincolor;

    return Container(
      decoration: BoxDecoration(
        color:
            themeController.isDay.value
                ? Colors.white
                : const Color(0xFF1E2230),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TabletNavBtn(
            Icons.first_page,
            'First Page',
            mainColor,
            () => _pdfViewerController.firstPage(),
          ),
          TabletNavBtn(
            Icons.navigate_before,
            'Previous',
            mainColor,
            () => _pdfViewerController.previousPage(),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              _totalPages > 0 ? '$_currentPage / $_totalPages' : '— / —',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
          ),
          TabletNavBtn(
            Icons.navigate_next,
            'Next',
            mainColor,
            () => _pdfViewerController.nextPage(),
          ),
          TabletNavBtn(
            Icons.last_page,
            'Last Page',
            mainColor,
            () => _pdfViewerController.lastPage(),
          ),
        ],
      ),
    );
  }

  Widget DesktopNavBar() {
    final mainColor =
        themeController.isDay.value
            ? QuickTechAppColors.lightmaincolor
            : QuickTechAppColors.darkmaincolor;

    return Container(
      decoration: BoxDecoration(
        color:
            themeController.isDay.value
                ? Colors.white
                : const Color(0xFF1E2230),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DesktopNavBtn(
            Icons.first_page,
            'First Page',
            mainColor,
            () => _pdfViewerController.firstPage(),
          ),
          SizedBox(width: 20.w),
          DesktopNavBtn(
            Icons.navigate_before,
            'Previous',
            mainColor,
            () => _pdfViewerController.previousPage(),
          ),
          SizedBox(width: 32.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: mainColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Text(
              _totalPages > 0 ? '$_currentPage of $_totalPages' : '— of —',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
          ),
          SizedBox(width: 32.w),
          DesktopNavBtn(
            Icons.navigate_next,
            'Next',
            mainColor,
            () => _pdfViewerController.nextPage(),
          ),
          SizedBox(width: 20.w),
          DesktopNavBtn(
            Icons.last_page,
            'Last Page',
            mainColor,
            () => _pdfViewerController.lastPage(),
          ),
        ],
      ),
    );
  }

  // ===== BUTTON BUILDERS (Per Breakpoint) =====

  Widget MobileNavBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: label,
      child: IconButton(
        icon: Icon(icon, color: color, size: 20.sp),
        onPressed: onPressed,
        splashRadius: 24.r,
      ),
    );
  }

  Widget TabletNavBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: label,
      child: IconButton(
        icon: Icon(icon, color: color, size: 24.sp),
        onPressed: onPressed,
        splashRadius: 28.r,
      ),
    );
  }

  Widget DesktopNavBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: label,
      child: SizedBox(
        width: 48.w,
        height: 48.h,
        child: IconButton(
          icon: Icon(icon, color: color, size: 28.sp),
          onPressed: onPressed,
          splashRadius: 32.r,
        ),
      ),
    );
  }
}
