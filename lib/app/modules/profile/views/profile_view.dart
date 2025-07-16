import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/modules/navigation/controllers/navigation_controller.dart';
import 'package:look4me/app/modules/profile/controllers/profile_controller.dart';
import 'package:look4me/app/modules/profile/widgets/look_history.dart';
import 'package:look4me/app/modules/profile/widgets/profile_header.dart';
import 'package:look4me/app/shared/components/empty_state.dart';
import 'package:look4me/app/shared/components/loading_widget.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.currentUser.value == null) {
            return const LoadingWidget(showShimmer: false);
          }

          return RefreshIndicator(
            onRefresh: controller.refreshProfile,
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ProfileHeader(
                        user: controller.currentUser.value,
                        onEditProfile: controller.goToEditProfile,
                        onChangePhoto: controller.pickProfileImage,
                        isUpdating: controller.isUpdatingProfile.value,
                      ),
                      SizedBox(height: 24.h),
                      _buildTabBar(),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
                _buildTabContent(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      elevation: 0,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      floating: true,
      snap: true,
      title: Text(
        'Perfil',
        style: TextStyles.titleLarge.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert_rounded,
            color: AppColors.text,
          ),
          onSelected: (value) {
            switch (value) {
              case 'settings':
                controller.goToSettings();
                break;
              case 'logout':
                controller.signOut();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined),
                  SizedBox(width: 12),
                  Text('Configurações'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_outlined, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Sair', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: _buildTabItem(
              'Meus Looks',
              0,
              Icons.style_outlined,
              Icons.style_rounded,
            ),
          ),
          Expanded(
            child: _buildTabItem(
              'Estatísticas',
              1,
              Icons.bar_chart_outlined,
              Icons.bar_chart_rounded,
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildTabItem(String title, int index, IconData icon, IconData activeIcon) {
    final isActive = controller.selectedTabIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.all(4.w),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isActive ? [
            const BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyles.labelMedium.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Obx(() {
      switch (controller.selectedTabIndex.value) {
        case 0:
          return _buildLooksTab();
        case 1:
          return _buildStatsTab();
        default:
          return _buildLooksTab();
      }
    });
  }

  Widget _buildLooksTab() {
    return Obx(() {
      if (controller.isLoadingPosts.value) {
        return const SliverToBoxAdapter(
          child: LoadingWidget(showShimmer: false),
        );
      }

      if (controller.userPosts.isEmpty) {
        return SliverToBoxAdapter(
          child: EmptyState(
            icon: Icons.style_outlined,
            title: 'Nenhum look ainda',
            subtitle: 'Compartilhe seu primeiro look e receba votos da comunidade!',
            actionText: 'Criar Look',
            onAction: () => Get.find<NavigationController>().changePage(2),
          ),
        );
      }

      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: LookHistory(
          posts: controller.userPosts,
          onDeletePost: controller.deletePost,
        ),
      );
    });
  }

  Widget _buildStatsTab() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Obx(() {
          final user = controller.currentUser.value;
          if (user == null) return const SizedBox.shrink();

          return Column(
            children: [
              _buildStatsCard(
                'Total de Posts',
                user.postsCount.toString(),
                Icons.post_add_outlined,
                AppColors.primary,
              ),
              SizedBox(height: 16.h),
              _buildStatsCard(
                'Seguidores',
                user.followersCount.toString(),
                Icons.people_outline,
                AppColors.secondary,
              ),
              SizedBox(height: 16.h),
              _buildStatsCard(
                'Seguindo',
                user.followingCount.toString(),
                Icons.person_add_outlined,
                AppColors.accent,
              ),
              SizedBox(height: 24.h),
              _buildJoinDateCard(user),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
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
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  title,
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinDateCard(user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: AppColors.onPrimary,
            size: 24.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Membro desde',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.onPrimary.withOpacity(0.9),
                  ),
                ),
                Text(
                  controller.getJoinDate(),
                  style: TextStyles.titleMedium.copyWith(
                    color: AppColors.onPrimary,
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
}
