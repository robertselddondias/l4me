import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../../../data/models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool showRemoveButton;
  final bool showFollowButton;
  final bool isFollowing;
  final VoidCallback? onFollowToggle;

  const UserCard({
    Key? key,
    required this.user,
    this.onTap,
    this.onRemove,
    this.showRemoveButton = false,
    this.showFollowButton = true,
    this.isFollowing = false,
    this.onFollowToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                _buildAvatar(),
                SizedBox(width: 16.w),
                Expanded(child: _buildUserInfo()),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Hero(
      tag: 'user_avatar_${user.id}',
      child: Container(
        width: 56.w,
        height: 56.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 26.r,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: user.profileImage != null
              ? CachedNetworkImageProvider(user.profileImage!)
              : null,
          child: user.profileImage == null
              ? Icon(
            Icons.person_rounded,
            color: AppColors.primary,
            size: 28.sp,
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                user.name,
                style: TextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (user.isVerified) ...[
              SizedBox(width: 4.w),
              Icon(
                Icons.verified_rounded,
                color: AppColors.primary,
                size: 16.sp,
              ),
            ],
          ],
        ),
        SizedBox(height: 4.h),
        if (user.bio != null && user.bio!.isNotEmpty) ...[
          Text(
            user.bio!,
            style: TextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
        ],
        _buildUserStats(),
      ],
    );
  }

  Widget _buildUserStats() {
    return Row(
      children: [
        _buildStatItem(user.postsCount.toString(), 'posts'),
        SizedBox(width: 12.w),
        _buildStatItem(user.followersCount.toString(), 'seguidores'),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Row(
      children: [
        Text(
          count,
          style: TextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          label,
          style: TextStyles.labelSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showFollowButton && onFollowToggle != null)
          _buildFollowButton(),
        if (showRemoveButton && onRemove != null) ...[
          if (showFollowButton) SizedBox(width: 8.w),
          _buildRemoveButton(),
        ],
      ],
    );
  }

  Widget _buildFollowButton() {
    return Container(
      height: 32.h,
      child: ElevatedButton(
        onPressed: onFollowToggle,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? AppColors.surfaceVariant : AppColors.primary,
          foregroundColor: isFollowing ? AppColors.text : AppColors.onPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: isFollowing ? BorderSide(color: AppColors.border) : BorderSide.none,
          ),
        ),
        child: Text(
          isFollowing ? 'Seguindo' : 'Seguir',
          style: TextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: IconButton(
        onPressed: onRemove,
        icon: Icon(
          Icons.close_rounded,
          color: AppColors.error,
          size: 16.sp,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
