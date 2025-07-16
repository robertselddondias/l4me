import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/story_model.dart';
import 'package:url_launcher/url_launcher.dart';

class StoryCard extends StatelessWidget {
  final StoryModel story;
  final VoidCallback? onTap;

  const StoryCard({
    super.key,
    required this.story,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (story.imageUrl != null) _buildImage(),
          _buildContent(),
          if (story.linkUrl != null) _buildLinkButton(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: story.authorProfileImage != null
                ? CachedNetworkImageProvider(story.authorProfileImage!)
                : null,
            child: story.authorProfileImage == null
                ? Icon(
              Icons.person,
              color: AppColors.primary,
              size: 20.sp,
            )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.authorName,
                  style: TextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatTimeAgo(story.createdAt),
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _getTypeColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTypeIcon(),
                  color: _getTypeColor(),
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  story.typeDisplayName,
                  style: TextStyles.labelSmall.copyWith(
                    color: _getTypeColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 200.h,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: CachedNetworkImage(
          imageUrl: story.imageUrl!,
          fit: BoxFit.cover,
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
            child: Icon(
              Icons.broken_image_outlined,
              color: AppColors.textTertiary,
              size: 40.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(16.w).copyWith(
        top: story.imageUrl != null ? 16.h : 0,
      ),
      child: Text(
        story.content,
        style: TextStyles.bodyMedium.copyWith(
          color: AppColors.text,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildLinkButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: _launchURL,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.link_rounded,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Ver mais',
                style: TextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.all(16.w).copyWith(top: 8.h),
      child: Row(
        children: [
          Icon(
            Icons.visibility_outlined,
            size: 16.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(width: 4.w),
          Text(
            '${story.viewsCount} visualizações',
            style: TextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const Spacer(),
          if (story.tags.isNotEmpty)
            Wrap(
              spacing: 4.w,
              children: story.tags.take(2).map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (story.type) {
      case StoryType.tip:
        return AppColors.primary;
      case StoryType.outfit:
        return AppColors.secondary;
      case StoryType.accessory:
        return AppColors.accent;
      case StoryType.trend:
        return Colors.orange;
      case StoryType.discount:
        return Colors.green;
      case StoryType.tutorial:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon() {
    switch (story.type) {
      case StoryType.tip:
        return Icons.lightbulb_outline;
      case StoryType.outfit:
        return Icons.checkroom_outlined;
      case StoryType.accessory:
        return Icons.watch_outlined;
      case StoryType.trend:
        return Icons.trending_up_outlined;
      case StoryType.discount:
        return Icons.local_offer_outlined;
      case StoryType.tutorial:
        return Icons.play_circle_outline;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  Future<void> _launchURL() async {
    if (story.linkUrl != null) {
      final uri = Uri.parse(story.linkUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
}
