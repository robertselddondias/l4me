import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/post_model.dart';
import 'package:look4me/app/modules/explore/controllers/explore_controller.dart';
import 'package:look4me/app/shared/components/loading_widget.dart';

class TrendingLooksSection extends GetView<ExploreController> {
  const TrendingLooksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Looks em Alta',
                style: TextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: controller.viewAllTrendingPosts,
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
        _buildTrendingPostsList(),
      ],
    );
  }

  Widget _buildTrendingPostsList() {
    return Obx(() {
      if (controller.isLoadingTrending.value) {
        return Container(
          height: 200.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: const LoadingWidget(showShimmer: false),
        );
      }

      if (controller.trendingPosts.isEmpty) {
        return SizedBox(
          height: 100.h,
          child: Center(
            child: Text(
              'Nenhum look em alta no momento',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }

      return SizedBox(
        height: 240.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: controller.trendingPosts.length,
          itemBuilder: (context, index) {
            final post = controller.trendingPosts[index];
            return Container(
              width: 160.w,
              margin: EdgeInsets.only(right: 12.w),
              child: _buildTrendingPostCard(post),
            );
          },
        ),
      );
    });
  }

  Widget _buildTrendingPostCard(PostModel post) {
    return GestureDetector(
      onTap: () => controller.viewPost(post),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostImages(post),
            _buildPostInfo(post),
          ],
        ),
      ),
    );
  }

  Widget _buildPostImages(PostModel post) {
    return Expanded(
      flex: 3,
      child: SizedBox(
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          child: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CachedNetworkImage(
                      imageUrl: post.imageOption1,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, color: AppColors.border),
                  Expanded(
                    child: CachedNetworkImage(
                      imageUrl: post.imageOption2,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // Vote count badge
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.how_to_vote_rounded,
                        color: Colors.white,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${post.totalVotes}',
                        style: TextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Occasion badge
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getOccasionColor(post.occasion).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    post.occasionDisplayName,
                    style: TextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostInfo(PostModel post) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.authorName,
              style: TextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            if (post.description.isNotEmpty) ...[
              Text(
                post.description,
                style: TextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6.h),
            ],
            const Spacer(),
            _buildResultInfo(post),
          ],
        ),
      ),
    );
  }

  Widget _buildResultInfo(PostModel post) {
    if (post.totalVotes == 0) {
      return Text(
        'Sem votos ainda',
        style: TextStyles.labelSmall.copyWith(
          color: AppColors.textTertiary,
        ),
      );
    }

    final winningOption = post.option1Votes > post.option2Votes ? 1 : 2;
    final winningPercentage = post.option1Votes > post.option2Votes
        ? post.option1Percentage
        : post.option2Percentage;

    return Row(
      children: [
        Container(
          width: 16.w,
          height: 16.h,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.emoji_events_rounded,
            color: Colors.white,
            size: 10.sp,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            'Opção $winningOption (${winningPercentage.toStringAsFixed(0)}%)',
            style: TextStyles.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getOccasionColor(PostOccasion occasion) {
    switch (occasion) {
      case PostOccasion.trabalho:
        return Colors.blue;
      case PostOccasion.festa:
        return Colors.purple;
      case PostOccasion.casual:
        return Colors.green;
      case PostOccasion.encontro:
        return Colors.pink;
      case PostOccasion.formatura:
        return Colors.indigo;
      case PostOccasion.casamento:
        return Colors.orange;
      case PostOccasion.academia:
        return Colors.red;
      case PostOccasion.viagem:
        return Colors.teal;
      case PostOccasion.balada:
        return Colors.deepPurple;
      case PostOccasion.praia:
        return Colors.cyan;
      case PostOccasion.shopping:
        return Colors.amber;
      default:
        return AppColors.primary;
    }
  }
}
