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
              _buildCategorySection(),
              Expanded(child: _buildPostsList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar(bool isScrolled) {
    return SliverAppBar(
      expandedHeight: 100.h, // Reduzido de 120.h
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
                AppColors.background,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _BackgroundPatternPainter(),
                ),
              ),
              // Content
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h), // Reduzido
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          _buildLogo(),
                          const Spacer(),
                          _buildNotificationButton(),
                          SizedBox(width: 6.w), // Reduzido
                          _buildRefreshButton(),
                        ],
                      ),
                      SizedBox(height: 8.h), // Reduzido
                      _buildWelcomeText(),
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

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 40.w, // Reduzido de 48.w
          height: 40.h, // Reduzido de 48.h
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12.r), // Reduzido
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8, // Reduzido
                offset: const Offset(0, 2), // Reduzido
              ),
            ],
          ),
          child: Icon(
            Icons.favorite_rounded,
            color: AppColors.onPrimary,
            size: 20.sp, // Reduzido
          ),
        ),
        SizedBox(width: 10.w), // Reduzido
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Look4Me',
              style: TextStyles.titleMedium.copyWith( // Reduzido de titleLarge
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.3, // Reduzido
              ),
            ),
            Text(
              'Seu estilo, sua escolha',
              style: TextStyles.labelSmall.copyWith( // Reduzido
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        Container(
          width: 36.w, // Reduzido de 44.w
          height: 36.h, // Reduzido de 44.h
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r), // Reduzido
            border: Border.all(
              color: AppColors.border.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.1),
                blurRadius: 6, // Reduzido
                offset: const Offset(0, 1), // Reduzido
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              // TODO: Navegar para notificações
              Get.snackbar('Notificações', 'Em breve!');
            },
            icon: Icon(
              Icons.notifications_outlined,
              color: AppColors.text,
              size: 16.sp, // Reduzido
            ),
            padding: EdgeInsets.zero,
          ),
        ),
        // Badge de notificação
        Positioned(
          top: 6.h, // Reduzido
          right: 6.w, // Reduzido
          child: Container(
            width: 6.w, // Reduzido
            height: 6.h, // Reduzido
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
    );
  }

  Widget _buildRefreshButton() {
    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 36.w, // Reduzido de 44.w
      height: 36.h, // Reduzido de 44.h
      decoration: BoxDecoration(
        color: controller.isLoading.value
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12.r), // Reduzido
        border: Border.all(
          color: controller.isLoading.value
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 6, // Reduzido
            offset: const Offset(0, 1), // Reduzido
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
            size: 16.sp, // Reduzido
          ),
        ),
        padding: EdgeInsets.zero,
      ),
    ));
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descubra o look perfeito',
          style: TextStyles.titleSmall.copyWith( // Reduzido de titleMedium
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 1.h), // Reduzido
        Obx(() => Text(
          controller.filteredPosts.length == 1
              ? '${controller.filteredPosts.length} look disponível'
              : '${controller.filteredPosts.length} looks disponíveis',
          style: TextStyles.labelSmall.copyWith( // Reduzido
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
          ),
        )),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Container(
      height: 52.h, // Muito reduzido
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withOpacity(0.3),
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
          padding: EdgeInsets.only(top: 12.h),
          itemCount: controller.filteredPosts.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.filteredPosts.length) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Column(
                  children: [
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Carregando mais looks...',
                      style: TextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
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
    // TODO: Implementar funcionalidade de salvar
    Get.snackbar(
      'Post Salvo',
      'Look adicionado aos seus favoritos!',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      icon: Icon(Icons.bookmark_rounded, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }

  void _handleSharePost(post) {
    // TODO: Implementar funcionalidade de compartilhar
    Get.snackbar(
      'Compartilhar',
      'Link copiado para a área de transferência!',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      icon: Icon(Icons.share_rounded, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }
}

// Custom painter para o padrão de fundo
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Criar padrão geométrico sutil
    for (int i = 0; i < 5; i++) {
      final x = (size.width / 4) * i;
      final y = size.height * 0.6;

      path.addOval(Rect.fromCircle(
        center: Offset(x, y),
        radius: 20,
      ));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
