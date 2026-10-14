import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_prescription/const/quick_tech_app_colors.dart';
import 'package:e_prescription/const/web_image.dart';
import 'package:e_prescription/controllers/theme_controller/quick_tech_theme_controller.dart';
import 'package:e_prescription/locator.dart';
import 'package:e_prescription/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String blogImageUrl(String path) {
  final p = path.trim();
  if (p.isEmpty) return '';
  if (p.startsWith('http://') || p.startsWith('https://')) return p;
  if (p.startsWith('/')) return '${Api.baseUrl}$p';
  return '${Api.baseUrl}/$p';
}

class QuickTechBlogImage extends StatelessWidget {
  final String url;
  final double? height;

  const QuickTechBlogImage({super.key, required this.url, this.height});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: Colors.grey.withValues(alpha: 0.15),
      child: const Center(
        child: Icon(Icons.article_outlined, size: 48, color: Colors.grey),
      ),
    );

    return SizedBox(
      height: height,
      width: double.infinity,
      child: url.isEmpty
          ? placeholder
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              memCacheWidth: 800,
              placeholder: (context, url) => placeholder,
              errorWidget: (context, url, error) =>
                  WebImage(imageUrl: url, fit: BoxFit.cover),
            ),
    );
  }
}

class customBlogCard extends StatelessWidget {
  final int id;
  final String title;
  final String content;
  final String imagePath;
  final String time;
  final bool featured;

  const customBlogCard({
    super.key,
    required this.id,
    required this.title,
    required this.content,
    required this.imagePath,
    required this.time,
    this.featured = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = locator.get<QuickTechThemeController>();

    return Obx(() {
      final isDay = themeController.isDay.value;

      return Container(
        decoration: BoxDecoration(
          color: isDay ? Colors.white : const Color(0xFF1E2230),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDay ? 0.08 : 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Get.toNamed('/blogdetails', arguments: id),
            child: featured
                ? LayoutBuilder(builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      return _buildFeaturedWide(isDay);
                    }
                    return _buildVertical(isDay);
                  })
                : _buildVertical(isDay),
          ),
        ),
      );
    });
  }

  Widget _buildFeaturedWide(bool isDay) {
    return SizedBox(
      height: 300,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: QuickTechBlogImage(
              url: blogImageUrl(imagePath),
              height: double.infinity,
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: _buildText(isDay, isFeatured: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVertical(bool isDay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuickTechBlogImage(url: blogImageUrl(imagePath), height: 180),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildText(isDay, isFeatured: false),
        ),
      ],
    );
  }

  Widget _buildText(bool isDay, {required bool isFeatured}) {
    final mainColor = isDay
        ? QuickTechAppColors.lightmaintextcolor
        : QuickTechAppColors.darkmaintextcolor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFeatured) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: QuickTechAppColors.lightmaincolor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'FEATURED',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: QuickTechAppColors.lightmaincolor,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: isFeatured ? 22 : 16,
            fontWeight: FontWeight.bold,
            color: mainColor,
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            color: mainColor.withValues(alpha: 0.6),
            height: 1.5,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            if (time.trim().isNotEmpty) ...[
              Icon(Icons.access_time, size: 13, color: Colors.grey[500]),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else
              const Spacer(),
            if (isFeatured)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: QuickTechAppColors.lightmaincolor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Read More →',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}