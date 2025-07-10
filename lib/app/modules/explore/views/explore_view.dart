import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/modules/explore/controllers/explore_controller.dart';
import 'package:look4me/app/modules/explore/widgets/categories_section.dart';
import 'package:look4me/app/modules/explore/widgets/trending_looks_section.dart';
import 'package:look4me/app/modules/explore/widgets/popular_users_section.dart';
import 'package:look4me/app/modules/stories/widgets/story_card.dart';
import 'package:look4me/app/shared/components/loading_widget.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshExploreContent,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStoriesSection(),
                    SizedBox(height: 24.h),
                    const CategoriesSection(),
                    SizedBox(height: 24.h),
                    const TrendingLooksSection(),
                    SizedBox(height: 24.h),
                    const PopularUsersSection(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      elevation: 0,
      backgroundColor: AppColors.surface,
      floating: true,
      snap: true,
      title: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.explore_rounded,
              color: AppColors.onPrimary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explorar',
                  style: TextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Descubra novos looks',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: controller.refreshExploreContent,
          icon: Icon(
            Icons.refresh_rounded,
            color: AppColors.primary,
            size: 24.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildStoriesSection() {
    return Obx(() {
      if (controller.isLoadingStories.value) {
        return Container(
          height: 120.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: const LoadingWidget(showShimmer: false),
        );
      }

      if (controller.trendingStories.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stories em Destaque',
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: controller.viewAllStories,
                  child: Text(
                    'Ver todos',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 200.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: controller.trendingStories.length,
              itemBuilder: (context, index) {
                final story = controller.trendingStories[index];
                return Container(
                  width: 280.w,
                  margin: EdgeInsets.only(right: 12.w),
                  child: StoryCard(
                    story: story,
                    onTap: () => controller.viewStory(story),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
