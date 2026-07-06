import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/quick_tech_styles.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickTechPdfPrescription extends StatefulWidget {
  final Uint8List pdfBytes;
  const QuickTechPdfPrescription({required this.pdfBytes});

  @override
  _QuickTechPdfPrescriptionState createState() =>
      _QuickTechPdfPrescriptionState();
}

class _QuickTechPdfPrescriptionState extends State<QuickTechPdfPrescription> {
  final QuickTechThemeController themeController =
      locator.get<QuickTechThemeController>();

  String? _blobUrl;
  String? _viewType;

  @override
  void initState() {
    super.initState();
    debugPrint('PdfViewScreen: ${widget.pdfBytes.length} bytes');
    debugPrint('First 4 bytes: ${widget.pdfBytes.take(4).toList()}');

    if (widget.pdfBytes.isNotEmpty) {
      _blobUrl = _createBlobUrl(widget.pdfBytes);
      _viewType =
          'pdf-viewer-${DateTime.now().microsecondsSinceEpoch}';

      // Register the iframe as a Flutter Web platform view
      ui_web.platformViewRegistry.registerViewFactory(_viewType!, (
        int viewId,
      ) {
        final iframe =
            html.IFrameElement()
              ..src = _blobUrl
              ..style.border = 'none'
              ..style.width = '100%'
              ..style.height = '100%'
              ..style.backgroundColor = '#525659';
        return iframe;
      });
    }
  }

  String _createBlobUrl(Uint8List bytes) {
    final blob = html.Blob([bytes], 'application/pdf');
    return html.Url.createObjectUrlFromBlob(blob);
  }

  void _openInNewTab() {
    if (_blobUrl != null) {
      html.window.open(_blobUrl!, '_blank');
    }
  }

  void _downloadPdf() {
    if (_blobUrl == null) return;
    final anchor =
        html.AnchorElement(href: _blobUrl)
          ..setAttribute('download', 'prescription.pdf')
          ..click();
  }

  @override
  void dispose() {
    if (_blobUrl != null) {
      html.Url.revokeObjectUrl(_blobUrl!);
    }
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
          title: Text(
            'Prescription',
            style: myStyle(isDesktop ? 18 : 16, Colors.white, FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              tooltip: 'Open in new tab',
              onPressed: widget.pdfBytes.isEmpty ? null : _openInNewTab,
            ),
            IconButton(
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              tooltip: 'Download',
              onPressed: widget.pdfBytes.isEmpty ? null : _downloadPdf,
            ),
            SizedBox(width: 8.w),
          ],
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
                : Column(
                  children: [
                    Expanded(
                      child: _viewType == null
                          ? const Center(child: CircularProgressIndicator())
                          : HtmlElementView(viewType: _viewType!),
                    ),
                    _BottomActionBar(
                      isDesktop: isDesktop,
                      mainColor: mainColor,
                      isDark: !isDay,
                      onOpenNewTab: _openInNewTab,
                      onDownload: _downloadPdf,
                    ),
                  ],
                ),
      );
    });
  }
}

class _BottomActionBar extends StatelessWidget {
  final bool isDesktop;
  final Color mainColor;
  final bool isDark;
  final VoidCallback onOpenNewTab;
  final VoidCallback onDownload;

  const _BottomActionBar({
    required this.isDesktop,
    required this.mainColor,
    required this.isDark,
    required this.onOpenNewTab,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2230) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 14.h : 10.h,
        horizontal: isDesktop ? 40.w : 16.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onOpenNewTab,
              icon: Icon(Icons.open_in_new, color: mainColor, size: 18.sp),
              label: Text(
                'Open in New Tab',
                style: TextStyle(
                  color: mainColor,
                  fontSize: isDesktop ? 14.sp : 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: mainColor.withValues(alpha: 0.4)),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onDownload,
              icon: Icon(Icons.download_rounded, size: 18.sp),
              label: Text(
                'Download',
                style: TextStyle(
                  fontSize: isDesktop ? 14.sp : 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}