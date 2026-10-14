import 'dart:math';
import 'package:e_prescription/const/const.dart';
import 'package:e_prescription/controllers/blog_controller/quick_tech_blog_controller.dart';
import 'package:e_prescription/screens/blogs/widgets/quick_tech_blog_widgets.dart';

class QuickTechBlogs extends StatefulWidget {
  const QuickTechBlogs({super.key});

  @override
  State<QuickTechBlogs> createState() => _QuickTechBlogsState();
}

class _QuickTechBlogsState extends State<QuickTechBlogs> {
  final QuickTechThemeController themeController =
      locator.get<QuickTechThemeController>();
  final QuickTechBlogController blogController =
      locator.get<QuickTechBlogController>();

  @override
  void initState() {
    super.initState();
    // Already loaded thakle abar fetch korbe na
    if (blogController.blogs.isEmpty) {
      blogController.fetchBlogs();
    }
  }

  Widget _buildBody(bool isDay) {
    final textColor = isDay
        ? QuickTechAppColors.lightmaintextcolor
        : QuickTechAppColors.darkmaintextcolor;

    return Obx(() {
      final blogs = blogController.blogs;

      if (blogController.isLoading.value && blogs.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (blogController.errorMessage.value.isNotEmpty && blogs.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  blogController.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: blogController.fetchBlogs,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (blogs.isEmpty) {
        return Center(
          child: Text('No blogs found', style: TextStyle(color: textColor)),
        );
      }

      return LayoutBuilder(builder: (context, constraints) {
        final sidePadding = max(16.0, (constraints.maxWidth - 1100) / 2);

        return RefreshIndicator(
          onRefresh: blogController.fetchBlogs,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(sidePadding, 32, sidePadding, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latest Articles',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 48,
                              height: 4,
                              decoration: BoxDecoration(
                                color: QuickTechAppColors.lightmaincolor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      customBlogCard(
                        id: blogs[0].id,
                        title: blogs[0].title,
                        content: blogs[0].shortDescription,
                        imagePath: blogs[0].image,
                        time: blogs[0].createdAt,
                        featured: true,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(sidePadding, 0, sidePadding, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 340,
                    mainAxisExtent: 370,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final blog = blogs[index + 1];
                      return customBlogCard(
                        id: blog.id,
                        title: blog.title,
                        content: blog.shortDescription,
                        imagePath: blog.image,
                        time: blog.createdAt,
                      );
                    },
                    childCount: blogs.length - 1,
                  ),
                ),
              ),
            ],
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDay = themeController.isDay.value;

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
          title: Text('Blogs',
              style: myStyle(18, QuickTechAppColors.white, FontWeight.bold)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                onPressed: themeController.toggleTheme,
                icon: Icon(
                  isDay ? Icons.light_mode : Icons.dark_mode,
                  color: isDay ? Colors.yellow : Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: _buildBody(isDay),
      );
    });
  }
}