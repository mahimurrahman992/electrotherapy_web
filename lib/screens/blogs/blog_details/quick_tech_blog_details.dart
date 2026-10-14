import 'package:e_prescription/const/const.dart';
import 'package:e_prescription/controllers/blog_controller/quick_tech_blog_controller.dart';
import 'package:e_prescription/models/blogs.dart';
import 'package:e_prescription/screens/blogs/widgets/quick_tech_blog_widgets.dart';
import 'package:flutter_html/flutter_html.dart';

class QuickTechBlogDetails extends StatefulWidget {
  final int id;
  const QuickTechBlogDetails({super.key, required this.id});

  @override
  State<QuickTechBlogDetails> createState() => _QuickTechBlogDetailsState();
}

class _QuickTechBlogDetailsState extends State<QuickTechBlogDetails> {
  final themeController = locator.get<QuickTechThemeController>();
  final blogController = locator.get<QuickTechBlogController>();

  bool isLoading = true;
  Blog? blog;

  @override
  void initState() {
    super.initState();
    loadBlog();
  }

  Future<void> loadBlog() async {
    // List theke already data thakle sathe sathe dekhabe
    final cached =
        blogController.blogs.firstWhereOrNull((b) => b.id == widget.id);
    if (cached != null) {
      blog = cached;
      isLoading = false;
    }

    final fresh = await blogController.fetchBlogDetails(widget.id);
    if (!mounted) return;
    setState(() {
      blog = fresh ?? blog;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDay = themeController.isDay.value;
      final textColor = isDay
          ? QuickTechAppColors.lightmaintextcolor
          : QuickTechAppColors.darkmaintextcolor;

      return Scaffold(
        backgroundColor:
            isDay ? const Color(0xFFF4F6FA) : QuickTechAppColors.darkScaffoldColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDay
              ? QuickTechAppColors.lightmaincolor
              : QuickTechAppColors.darkmaincolor,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.white),
          ),
          title: Text('Blog Details',
              style: myStyle(18, QuickTechAppColors.white, FontWeight.bold)),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : blog == null
                ? Center(
                    child: Text('Blog not found',
                        style: TextStyle(color: textColor)))
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 780),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDay ? Colors.white : const Color(0xFF1E2230),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDay ? 0.08 : 0.3),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              QuickTechBlogImage(
                                url: blogImageUrl(blog!.image),
                                height: 300,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      blog!.title,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                        height: 1.35,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: QuickTechAppColors.lightmaincolor,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    if (blog!.shortDescription.isNotEmpty) ...[
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: QuickTechAppColors
                                              .lightmaincolor
                                              .withValues(alpha: 0.07),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: QuickTechAppColors
                                                .lightmaincolor
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Text(
                                          blog!.shortDescription,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontStyle: FontStyle.italic,
                                            color: textColor.withValues(
                                                alpha: 0.75),
                                            height: 1.6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                    Html(
                                      data: blog!.longDescription,
                                      style: {
                                        'body': Style(
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                          fontSize: FontSize(15.5),
                                          lineHeight: const LineHeight(1.75),
                                          color: textColor,
                                        ),
                                        'p': Style(
                                            margin: Margins.only(bottom: 16)),
                                        'a': Style(
                                          color:
                                              QuickTechAppColors.lightmaincolor,
                                          textDecoration: TextDecoration.none,
                                        ),
                                      },
                                    ),
                                    if (blog!.createdAt.trim().isNotEmpty) ...[
                                      const Divider(height: 32),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time,
                                              size: 14,
                                              color: Colors.grey[500]),
                                          const SizedBox(width: 6),
                                          Text(
                                            blog!.createdAt,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[500]),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      );
    });
  }
}