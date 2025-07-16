import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/modules/stories/controllers/stories_controller.dart';
import 'package:look4me/app/modules/stories/widgets/story_card.dart';
import 'package:look4me/app/shared/components/empty_state.dart';
import 'package:look4me/app/shared/components/loading_widget.dart';

class StoriesView extends GetView<StoriesController> {
  const StoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildStoriesList()),
          ],
        ),
      ),
      floatingActionButton: _buildCreateStoryButton(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
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
                  'Stories',
                  style: TextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Dicas rápidas e tendências',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.refreshStories,
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.primary,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesList() {
    return Obx(() {
      if (controller.isLoading.value && controller.stories.isEmpty) {
        return const LoadingWidget();
      }

      if (controller.stories.isEmpty) {
        return EmptyState(
          icon: Icons.auto_stories_outlined,
          title: 'Nenhum story ainda',
          subtitle: 'Seja a primeira a compartilhar dicas e tendências com a comunidade!',
          actionText: 'Criar Story',
          onAction: controller.goToCreateStory,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshStories,
        color: AppColors.primary,
        child: ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.stories.length,
          itemBuilder: (context, index) {
            final story = controller.stories[index];
            return StoryCard(
              story: story,
              onTap: () => controller.markAsViewed(story.id),
            );
          },
        ),
      );
    });
  }

  Widget _buildCreateStoryButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: controller.goToCreateStory,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          Icons.add_rounded,
          color: AppColors.onPrimary,
          size: 28.sp,
        ),
      ),
    );
  }
}
