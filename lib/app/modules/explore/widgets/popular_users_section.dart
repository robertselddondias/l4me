import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/user_model.dart';
import 'package:look4me/app/modules/explore/controllers/explore_controller.dart';
import 'package:look4me/app/shared/components/loading_widget.dart';

class PopularUsersSection extends GetView<ExploreController> {
  const PopularUsersSection({Key? key}) : super(key: key);

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
                'Usuárias em Destaque',
                style: TextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: controller.viewAllPopularUsers,
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
        _buildPopularUsersList(),
      ],
    );
  }

  Widget _buildPopularUsersList() {
    return Obx(() {
      if (controller.isLoadingUsers.value) {
        return Container(
          height: 120.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: const LoadingWidget(showShimmer: false),
        );
      }

      if (controller.popularUsers.isEmpty) {
        return Container(
          height: 100.h,
          child: Center(
            child: Text(
              'Nenhuma usuária em destaque no momento',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      }

      return SizedBox(
        height: 140.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: controller.popularUsers.length,
          itemBuilder: (context, index) {
            final user = controller.popularUsers[index];
            return Container(
              width: 100.w,
              margin: EdgeInsets.only(right: 12.w),
              child: _buildPopularUserCard(user, index),
            );
          },
        ),
      );
    });
  }

  Widget _buildPopularUserCard(UserModel user, int index) {
    return GestureDetector(
      onTap: () => controller.viewUserProfile(user.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () => controller.viewUserProfile(user.id),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                children: [
                  _buildRankingBadge(index),
                  SizedBox(height: 8.h),
                  _buildUserAvatar(user),
                  SizedBox(height: 8.h),
                  _buildUserInfo(user),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankingBadge(int index) {
    Color badgeColor;
    IconData badgeIcon;

    switch (index) {
      case 0:
        badgeColor = Colors.amber;
        badgeIcon = Icons.emoji_events_rounded;
        break;
      case 1:
        badgeColor = Colors.grey;
        badgeIcon = Icons.military_tech_rounded;
        break;
      case 2:
        badgeColor = Colors.brown;
        badgeIcon = Icons.military_tech_rounded;
        break;
      default:
        badgeColor = AppColors.primary;
        badgeIcon = Icons.star_rounded;
    }

    return Container(
      width: 24.w,
      height: 24.h,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        badgeIcon,
        color: Colors.white,
        size: 14.sp,
      ),
    );
  }

  Widget _buildUserAvatar(UserModel user) {
    return Hero(
      tag: 'popular_user_${user.id}',
      child: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
        ),
        child: Padding(
          padding: EdgeInsets.all(2.w), // Agora o padding está no lugar correto
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
            ),
            child: CircleAvatar(
              radius: 22.r,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: user.profileImage != null
                  ? CachedNetworkImageProvider(user.profileImage!)
                  : null,
              child: user.profileImage == null
                  ? Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 20.sp,
              )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(UserModel user) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  user.name,
                  style: TextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (user.isVerified) ...[
                SizedBox(width: 2.w),
                Icon(
                  Icons.verified_rounded,
                  color: AppColors.primary,
                  size: 12.sp,
                ),
              ],
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            '${user.postsCount} posts',
            style: TextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 24.h,
            child: ElevatedButton(
              onPressed: () => controller.viewUserProfile(user.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Ver perfil',
                style: TextStyles.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
