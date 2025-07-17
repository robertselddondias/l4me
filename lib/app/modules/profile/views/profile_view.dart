import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/post_model.dart';
import 'package:look4me/app/modules/home/controllers/home_controller.dart';
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
              'Salvos',
              1,
              Icons.bookmark_outline,
              Icons.bookmark_rounded,
            ),
          ),
          Expanded(
            child: _buildTabItem(
              'Estatísticas',
              2,
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
          return _buildSavedPostsTab(); // NOVA ABA
        case 2:
          return _buildStatsTab();
        default:
          return _buildLooksTab();
      }
    });
  }

  Widget _buildSavedPostsTab() {
    return FutureBuilder<List<PostModel>>(
      future: Get.find<HomeController>().getSavedPostsData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: LoadingWidget(showShimmer: false),
          );
        }

        final savedPosts = snapshot.data ?? [];

        if (savedPosts.isEmpty) {
          return SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.bookmark_outline,
              title: 'Nenhum post salvo',
              subtitle: 'Salve posts interessantes tocando no ícone de bookmark para vê-los aqui depois!',
              actionText: 'Explorar Posts',
              onAction: () => Get.find<NavigationController>().changePage(0),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1 / 1.25,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final post = savedPosts[index];
                return _buildSavedPostCard(post);
              },
              childCount: savedPosts.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedPostCard(PostModel post) {
    final winningOption = post.option1Votes > post.option2Votes ? 1 : (post.option1Votes < post.option2Votes ? 2 : 0);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: _buildSavedImagePreview(post, winningOption),
          ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.description.isNotEmpty) ...[
                  Text(
                    post.description,
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.bookmark_rounded,
                      size: 12.sp,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Salvo',
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${post.totalVotes} votos',
                      style: TextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Por ${post.authorName}',
                        style: TextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showRemoveFromSavedDialog(post),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.bookmark_remove_outlined,
                          size: 16.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedImagePreview(PostModel post, int winningOption) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: post.imageOption1,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.amber,
                      strokeWidth: 1.5,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.broken_image_outlined, color: AppColors.textTertiary),
                  ),
                ),
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: post.imageOption2,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.amber,
                      strokeWidth: 1.5,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.broken_image_outlined, color: AppColors.textTertiary),
                  ),
                ),
              ),
            ],
          ),
          // Badge de post salvo
          Positioned(
            top: 8.h,
            left: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_rounded,
                    color: Colors.white,
                    size: 10.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Salvo',
                    style: TextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Indicador da opção vencedora
          if (winningOption != 0)
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 10.sp,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Op. $winningOption',
                      style: TextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showRemoveFromSavedDialog(PostModel post) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remover dos Salvos'),
        content: const Text('Tem certeza que deseja remover este post dos seus salvos?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.find<HomeController>().removeFromSaved(post.id);
              Get.snackbar(
                'Removido',
                'Post removido dos salvos',
                backgroundColor: Colors.amber,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                icon: Icon(Icons.bookmark_remove, color: Colors.white),
              );
              // Força refresh da aba
              controller.selectedTabIndex.refresh();
            },
            child: const Text(
              'Remover',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
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
