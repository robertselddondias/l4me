import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/modules/home/controllers/home_controller.dart';
import 'package:look4me/app/modules/home/widgets/category_filter.dart';
import 'package:look4me/app/modules/home/widgets/home_shimmer_loading.dart';
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
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildModernAppBar(innerBoxIsScrolled),
          ],
          body: Column(
            children: [
              _buildModernCategorySection(),
              Expanded(child: _buildPostsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar(bool isScrolled) {
    return SliverAppBar(
      expandedHeight: 100.h,
      floating: true,
      pinned: true,
      snap: false,
      elevation: 0,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                AppColors.background.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Pattern moderno e sutil
              Positioned.fill(
                child: CustomPaint(
                  painter: _ModernBackgroundPainter(),
                ),
              ),
              // Conteúdo
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          _buildModernLogo(),
                          const Spacer(),
                          _buildNotificationButton(),
                          SizedBox(width: 12.w),
                          _buildRefreshButton(),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      _buildWelcomeSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
        Text(
          'Look4Me',
          style: TextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.text,
            letterSpacing: -0.5,
          ),
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
              // TODO: Implementar notificações
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
          // Badge de notificação
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

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descubra o look perfeito',
          style: TextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildModernCategorySection() {
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
              onVote: (option) => controller.voteOnPost(post.id, option),
              onSave: () => _handleSavePost(post),
              onShare: () => _handleSharePost(post),
            );
          },
        ),
      );
    });
  }

  void _handleSavePost(post) {
    Get.snackbar(
      'Post Salvo',
      'Look adicionado aos seus favoritos!',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      icon: Icon(Icons.bookmark_rounded, color: Colors.white),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
  }

  void _handleSharePost(post) {
    Get.snackbar(
      'Compartilhar',
      'Link copiado para a área de transferência!',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      icon: Icon(Icons.share_rounded, color: Colors.white),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16.w),
      borderRadius: 12.r,
    );
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
