import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/modules/home/controllers/home_controller.dart';
import 'package:look4me/app/modules/home/widgets/category_filter.dart';
import 'package:look4me/app/modules/home/widgets/home_shimmer_loading.dart';
import 'package:look4me/app/modules/home/widgets/post_card.dart';
import 'package:look4me/app/modules/navigation/controllers/navigation_controller.dart';
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
            // CORRIGIDO: AppBar fixo fora do scroll
            _buildFixedAppBar(),
            _buildCategorySection(),
            Expanded(child: _buildPostsList()),
          ],
        ),
      ),
    );
  }

  // NOVO: AppBar completamente fixo
  Widget _buildFixedAppBar() {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.background.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Pattern moderno e sutil
          Positioned.fill(
            child: CustomPaint(
              painter: _ModernBackgroundPainter(),
            ),
          ),
          // Conteúdo do AppBar
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
            child: Row(
              children: [
                _buildModernLogo(),
                const Spacer(),
                _buildNotificationButton(),
                SizedBox(width: 12.w),
                _buildRefreshButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernLogo() {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.favorite_rounded,
            color: AppColors.onPrimary,
            size: 18.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Look4Me',
              style: TextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Descubra o look perfeito',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Obx(() => Container(
      width: 36.w,
      height: 36.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          IconButton(
            onPressed: () {
              Get.snackbar(
                'Notificações',
                'Nenhuma notificação nova!',
                backgroundColor: AppColors.info,
                colorText: Colors.white,
                icon: Icon(Icons.notifications_rounded, color: Colors.white),
                duration: const Duration(seconds: 2),
              );
            },
            icon: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.text,
              size: 16.sp,
            ),
            padding: EdgeInsets.zero,
          ),
          if (controller.hasNotifications.value)
            Positioned(
              top: 6.h,
              right: 6.w,
              child: Container(
                width: 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface,
                    width: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    ));
  }

  Widget _buildRefreshButton() {
    return Obx(() => Container(
      width: 36.w,
      height: 36.h,
      decoration: BoxDecoration(
        color: controller.isLoading.value
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: controller.isLoading.value
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        onPressed: controller.refreshPosts,
        icon: AnimatedRotation(
          turns: controller.isLoading.value ? 1 : 0,
          duration: const Duration(milliseconds: 800),
          child: Icon(
            Icons.refresh_rounded,
            color: controller.isLoading.value
                ? AppColors.primary
                : AppColors.text,
            size: 16.sp,
          ),
        ),
        padding: EdgeInsets.zero,
      ),
    ));
  }

  Widget _buildCategorySection() {
    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
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
        return const HomeShimmerLoading();
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
        backgroundColor: AppColors.surface,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(0, 16.h, 0, 100.h),
          itemCount: controller.filteredPosts.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.filteredPosts.length) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: Column(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Carregando mais looks...',
                      style: TextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final post = controller.filteredPosts[index];

            if (index == controller.filteredPosts.length - 3) {
              controller.loadMorePosts();
            }

            return PostCard(
              key: ValueKey('post_${post.id}_${post.createdAt.millisecondsSinceEpoch}'),
              post: post,
              hasUserVoted: controller.hasUserVoted(post.id),
              userVote: controller.getUserVote(post.id),
              isFollowing: controller.isFollowingUser(post.authorId),
              isOwnPost: controller.isOwnPost(post.authorId),
              isSaved: controller.isPostSaved(post.id),
              onVote: (option) => controller.voteOnPost(post.id, option),
              onRemoveVote: () => controller.removeVote(post.id),
              onSave: () => controller.toggleSavePost(post.id),
              onShare: () => controller.sharePost(post.id),
              onFollow: () => controller.toggleFollowUser(post.authorId),
            );
          },
        ),
      );
    });
  }
}

// Custom painter moderno para o padrão de fundo
class _ModernBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Criar padrão geométrico moderno e sutil
    for (int i = 0; i < 3; i++) {
      final x = (size.width / 2) + (i * 60);
      final y = size.height * 0.3;

      // Círculos sutis
      path.addOval(Rect.fromCircle(
        center: Offset(x, y),
        radius: 15 + (i * 5),
      ));
    }

    // Formas geométricas abstratas
    final secondaryPaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    final secondaryPath = Path();
    secondaryPath.moveTo(size.width * 0.8, size.height * 0.6);
    secondaryPath.lineTo(size.width * 0.9, size.height * 0.7);
    secondaryPath.lineTo(size.width * 0.85, size.height * 0.8);
    secondaryPath.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(secondaryPath, secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
