import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/user_model.dart';
import 'package:look4me/app/shared/components/custom_button.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel? user;
  final VoidCallback? onEditProfile;
  final VoidCallback? onChangePhoto;
  final bool isUpdating;

  const ProfileHeader({
    Key? key,
    this.user,
    this.onEditProfile,
    this.onChangePhoto,
    this.isUpdating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Container(
        padding: EdgeInsets.all(20.w),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildProfileImage(),
          SizedBox(height: 20.h),
          _buildUserInfo(),
          SizedBox(height: 20.h),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          width: 120.w,
          height: 120.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: user!.profileImage != null
                ? CachedNetworkImage(
              imageUrl: user!.profileImage!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.primaryLight,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => _buildDefaultAvatar(),
            )
                : _buildDefaultAvatar(),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: isUpdating ? null : onChangePhoto,
            child: Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surface,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isUpdating
                  ? Padding(
                padding: EdgeInsets.all(8.w),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.onPrimary,
                  ),
                ),
              )
                  : Icon(
                Icons.camera_alt_rounded,
                color: AppColors.onPrimary,
                size: 18.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.onPrimary,
        size: 60.sp,
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          user!.name,
          style: TextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        if (user!.bio != null && user!.bio!.isNotEmpty) ...[
          Text(
            user!.bio!,
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16.h),
        ],
        _buildStatsRow(),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          user!.postsCount.toString(),
          'Posts',
        ),
        _buildStatItem(
          user!.followersCount.toString(),
          'Seguidores',
        ),
        _buildStatItem(
          user!.followingCount.toString(),
          'Seguindo',
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Editar Perfil',
            onPressed: onEditProfile,
            type: ButtonType.outlined,
            size: ButtonSize.medium,
            icon: Icons.edit_outlined,
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          width: 52.w,
          height: 52.h,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: IconButton(
            onPressed: () {
              // Implementar compartilhamento do perfil
            },
            icon: Icon(
              Icons.share_outlined,
              color: AppColors.textSecondary,
              size: 24.sp,
            ),
          ),
        ),
      ],
    );
  }
}
