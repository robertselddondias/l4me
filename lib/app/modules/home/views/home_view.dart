import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/modules/home/controllers/home_controller.dart';
import 'package:look4me/app/modules/home/widgets/category_filter.dart';
import 'package:look4me/app/modules/home/widgets/post_card.dart';
import 'package:look4me/app/shared/components/empty_state.dart';
import 'package:look4me/app/shared/components/loading_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildCategoryFilter(),
            Expanded(child: _buildPostsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.favorite_rounded,
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
                  'Look4Me',
                  style: TextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  'Descubra o look perfeito',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.refreshPosts,
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

  Widget _buildCategoryFilter() {
    return Container(
      height: 60.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: CategoryFilter(
        categories: controller.occasions,
        selectedCategory: controller.selectedOccasion,
        onCategorySelected: controller.filterByOccasion,
      ),
    );
  }

  Widget _buildPostsList() {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredPosts.isEmpty) {
        return const LoadingWidget();
      }

      if (controller.filteredPosts.isEmpty) {
        return EmptyState(
          icon: Icons.style_outlined,
          title: 'Nenhum look encontrado',
          subtitle: 'Seja a primeira a compartilhar um look nesta categoria!',
          actionText: 'Atualizar',
          onAction: controller.refreshPosts,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshPosts,
        color: AppColors.primary,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          itemCount: controller.filteredPosts.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.filteredPosts.length) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final post = controller.filteredPosts[index];

            if (index == controller.filteredPosts.length - 3) {
              controller.loadMorePosts();
            }

            return PostCard(
              post: post,
              hasUserVoted: controller.hasUserVoted(post.id),
              userVote: controller.getUserVote(post.id),
              onVote: (option) => controller.voteOnPost(post.id, option),
            );
          },
        ),
      );
    });
  }
}
