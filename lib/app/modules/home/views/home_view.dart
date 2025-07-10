import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/modules/home/controllers/home_controller.dart';
import 'package:look4me/app/shared/components/loading_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refreshPosts,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              _buildDynamicAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildQuickLooksSection(),
                    SizedBox(height: 20.h),
                    _buildTrendingSection(),
                    SizedBox(height: 20.h),
                    _buildDailyChallengesSection(),
                    SizedBox(height: 20.h),
                    _buildRecentVotesSection(),
                    SizedBox(height: 80.h), // Espaço para navegação
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicAppBar() {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.flash_on_rounded,
                        color: AppColors.onPrimary,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Look4Me',
                            style: TextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          Obx(() => Text(
                            _getGreetingMessage(),
                            style: TextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )),
                        ],
                      ),
                    ),
                    _buildNotificationButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return GestureDetector(
      onTap: () => controller.openNotifications(),
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.notifications_outlined,
                color: AppColors.text,
                size: 20.sp,
              ),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLooksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Looks Rápidos',
                style: TextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'NOVO',
                  style: TextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => controller.goToCreateQuickLook(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Criar',
                      style: TextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            'Escolha rápida • Desaparecem em 15 minutos',
            style: TextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _buildQuickLooksList(),
      ],
    );
  }

  Widget _buildQuickLooksList() {
    return Obx(() {
      if (controller.isLoadingQuickLooks.value) {
        return Container(
          height: 280.h,
          child: const LoadingWidget(showShimmer: false),
        );
      }

      if (controller.quickLooks.isEmpty) {
        return Container(
          height: 200.h,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flash_off_outlined,
                size: 48.sp,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: 16.h),
              Text(
                'Nenhum look rápido no momento',
                style: TextStyles.titleMedium.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Seja a primeira a criar um!',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return SizedBox(
        height: 280.h,
        child: PageView.builder(
          padEnds: false,
          controller: PageController(viewportFraction: 0.85),
          itemCount: controller.quickLooks.length,
          itemBuilder: (context, index) {
            final quickLook = controller.quickLooks[index];
            return Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 20.w : 8.w,
                right: 8.w,
              ),
              child: _buildQuickLookCard(quickLook),
            );
          },
        ),
      );
    });
  }

  Widget _buildQuickLookCard(dynamic quickLook) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Background das imagens (placeholder)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.secondaryLight],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: AppColors.primaryLight.withOpacity(0.7),
                      child: Icon(
                        Icons.image_outlined,
                        size: 60.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Container(width: 2, color: Colors.white.withOpacity(0.3)),
                  Expanded(
                    child: Container(
                      color: AppColors.secondaryLight.withOpacity(0.7),
                      child: Icon(
                        Icons.image_outlined,
                        size: 60.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),

            // Timer e info no topo
            Positioned(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '12min',
                          style: TextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 14.r,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo na parte inferior
            Positioned(
              bottom: 80.h,
              left: 16.w,
              right: 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Maria Silva',
                    style: TextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Qual fica melhor para reunião importante?',
                    style: TextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Trabalho',
                      style: TextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Botões de votação
            Positioned(
              bottom: 16.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                children: [
                  Expanded(
                    child: _buildVoteButton(
                      label: 'Opção 1',
                      percentage: 42,
                      isWinning: false,
                      onTap: () => _voteQuickLook(quickLook, 1),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildVoteButton(
                      label: 'Opção 2',
                      percentage: 58,
                      isWinning: true,
                      onTap: () => _voteQuickLook(quickLook, 2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteButton({
    required String label,
    required int percentage,
    required bool isWinning,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isWinning
              ? AppColors.primary.withOpacity(0.9)
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isWinning)
                  Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 12.sp,
                  ),
                if (isWinning) SizedBox(width: 4.w),
                Text(
                  '$percentage%',
                  style: TextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Container(
                width: 4.w,
                height: 20.h,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Em Alta Agora',
                style: TextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.trending_up_rounded,
                color: AppColors.secondary,
                size: 20.sp,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _buildTrendingList(),
      ],
    );
  }

  Widget _buildTrendingList() {
    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            width: 160.w,
            margin: EdgeInsets.only(right: 12.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                      gradient: LinearGradient(
                        colors: [AppColors.primaryLight, AppColors.secondaryLight],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.trending_up_rounded,
                            size: 40.sp,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.orange, Colors.red]),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'HOT',
                              style: TextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 8.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Look para reunião importante',
                          style: TextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Trabalho',
                                style: TextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 8.sp,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Icon(
                                  Icons.how_to_vote_rounded,
                                  size: 12.sp,
                                  color: AppColors.textTertiary,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  '234',
                                  style: TextStyles.labelSmall.copyWith(
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyChallengesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.pink.shade400],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Desafio do Dia',
                      style: TextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Look para trabalho remoto',
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
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Text(
                  '🔥 Participar',
                  style: TextStyles.labelMedium.copyWith(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _buildChallengesList(),
      ],
    );
  }

  Widget _buildChallengesList() {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 3,
        itemBuilder: (context, index) {
          final gradients = [
            [Colors.orange.shade400, Colors.pink.shade400],
            [Colors.purple.shade400, Colors.blue.shade400],
            [Colors.green.shade400, Colors.teal.shade400],
          ];

          final challenges = [
            'Look Profissional',
            'Style Sustentável',
            'Minimalista Chic',
          ];

          final descriptions = [
            'Vista-se para o sucesso',
            'Peças que já tem',
            'Máximo 3 cores',
          ];

          return Container(
            width: 280.w,
            margin: EdgeInsets.only(right: 12.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradients[index],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: gradients[index][0].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenges[index],
                            style: TextStyles.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            descriptions[index],
                            style: TextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '+${50 + (index * 10)} XP',
                        style: TextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: 0.7,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '70%',
                      style: TextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentVotesSection() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Seus Votos Recentes',
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => controller.viewAllVotes(),
                  child: Text(
                    'Ver todos',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          _buildRecentVotesList(),
        ],
      );
    });
  }

  Widget _buildRecentVotesList() {
    return Container(
        height: 120.h,
        child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
    itemCount: 5,
    itemBuilder: (context, index) {
    return Container(
    width: 200.w,
    margin: EdgeInsets.only(right: 12.w),
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(import 'package:flutter/material.dart';
    import 'package:flutter_screenutil/flutter_screenutil.dart';
    import 'package:get/get.dart';
    import 'package:look4me/app/core/constants/app_colors.dart';
    import 'package:look4me/app/core/themes/text_styles.dart';
    import 'package:look4me/app/modules/home/controllers/home_controller.dart';
    import 'package:look4me/app/modules/home/widgets/quick_looks_section.dart';
    import 'package:look4me/app/modules/home/widgets/trending_polls_section.dart';
    import 'package:look4me/app/modules/home/widgets/daily_challenges_section.dart';
    import 'package:look4me/app/shared/components/loading_widget.dart';

    class HomeView extends GetView<HomeController> {
    const HomeView({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
    child: RefreshIndicator(
    onRefresh: controller.refreshPosts,
    color: AppColors.primary,
    child: CustomScrollView(
    slivers: [
    _buildDynamicAppBar(),
    SliverToBoxAdapter(
    child: Column(
    children: [
    _buildQuickLooksSection(),
    SizedBox(height: 20.h),
    _buildTrendingSection(),
    SizedBox(height: 20.h),
    _buildDailyChallengesSection(),
    SizedBox(height: 20.h),
    _buildRecentVotesSection(),
    SizedBox(height: 80.h), // Espaço para navegação
    ],
    ),
    ),
    ],
    ),
    ),
    ),
    );
    }

    Widget _buildDynamicAppBar() {
    return SliverAppBar(
    expandedHeight: 120.h,
    floating: true,
    pinned: true,
    backgroundColor: AppColors.surface,
    flexibleSpace: FlexibleSpaceBar(
    background: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
    AppColors.primary.withOpacity(0.1),
    AppColors.secondary.withOpacity(0.05),
    ],
    ),
    ),
    child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
    Row(
    children: [
    Container(
    width: 48.w,
    height: 48.h,
    decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(16.r),
    ),
    child: Icon(
    Icons.flash_on_rounded,
    color: AppColors.onPrimary,
    size: 24.sp,
    ),
    ),
    SizedBox(width: 16.w),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Look4Me',
    style: TextStyles.headlineSmall.copyWith(
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    ),
    ),
    Obx(() => Text(
    _getGreetingMessage(),
    style: TextStyles.bodyMedium.copyWith(
    color: AppColors.textSecondary,
    ),
    )),
    ],
    ),
    ),
    _buildNotificationButton(),
    ],
    ),
    ],
    ),
    ),
    ),
    ),
    );
    }

    Widget _buildNotificationButton() {
    return Container(
    width: 44.w,
    height: 44.h,
    decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12.r),
    boxShadow: [
    BoxShadow(
    color: AppColors.shadowLight,
    blurRadius: 8,
    offset: const Offset(0, 2),
    ),
    ],
    ),
    child: Stack(
    children: [
    Center(
    child: Icon(
    Icons.notifications_outlined,
    color: AppColors.text,
    size: 20.sp,
    ),
    ),
    Positioned(
    top: 8.h,
    right: 8.w,
    child: Container(
    width: 8.w,
    height: 8.h,
    decoration: BoxDecoration(
    color: AppColors.error,
    shape: BoxShape.circle,
    ),
    ),
    ),
    ],
    ),
    );
    }

    Widget _buildQuickLooksSection() {
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Row(
    children: [
    Icon(
    Icons.flash_on_rounded,
    color: AppColors.primary,
    size: 20.sp,
    ),
    SizedBox(width: 8.w),
    Text(
    'Looks Rápidos',
    style: TextStyles.titleLarge.copyWith(
    fontWeight: FontWeight.w700,
    ),
    ),
    SizedBox(width: 8.w),
    Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(
    'NOVO',
    style: TextStyles.labelSmall.copyWith(
    color: Colors.white,
    fontWeight: FontWeight.w700,
    ),
    ),
    ),
    const Spacer(),
    TextButton(
    onPressed: () => controller.goToCreateQuickLook(),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(
    Icons.add_circle_outline,
    size: 16.sp,
    color: AppColors.primary,
    ),
    SizedBox(width: 4.w),
    Text(
    'Criar',
    style: TextStyles.labelMedium.copyWith(
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
    ),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    SizedBox(height: 4.h),
    Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Text(
    'Escolha rápida • Desaparecem em 15 minutos',
    style: TextStyles.bodySmall.copyWith(
    color: AppColors.textSecondary,
    ),
    ),
    ),
    SizedBox(height: 16.h),
    const QuickLooksSection(),
    ],
    );
    }

    Widget _buildTrendingSection() {
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Row(
    children: [
    Container(
    width: 4.w,
    height: 20.h,
    decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(2.r),
    ),
    ),
    SizedBox(width: 12.w),
    Text(
    'Em Alta Agora',
    style: TextStyles.titleLarge.copyWith(
    fontWeight: FontWeight.w700,
    ),
    ),
    SizedBox(width: 8.w),
    Icon(
    Icons.trending_up_rounded,
    color: AppColors.secondary,
    size: 20.sp,
    ),
    ],
    ),
    ),
    SizedBox(height: 16.h),
    const TrendingPollsSection(),
    ],
    );
    }

    Widget _buildDailyChallengesSection() {
    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Row(
    children: [
    Container(
    padding: EdgeInsets.all(8.w),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [Colors.orange.shade400, Colors.pink.shade400],
    ),
    borderRadius: BorderRadius.circular(12.r),
    ),
    child: Icon(
    Icons.emoji_events_rounded,
    color: Colors.white,
    size: 20.sp,
    ),
    ),
    SizedBox(width: 12.w),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    'Desafio do Dia',
    style: TextStyles.titleMedium.copyWith(
    fontWeight: FontWeight.w700,
    ),
    ),
    Text(
    'Look para trabalho remoto',
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
    color: Colors.orange.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20.r),
    border: Border.all(color: Colors.orange.withOpacity(0.3)),
    ),
    child: Text(
    '🔥 Participar',
    style: TextStyles.labelMedium.copyWith(
    color: Colors.orange.shade700,
    fontWeight: FontWeight.w600,
    ),
    ),
    ),
    ],
    ),
    ),
    SizedBox(height: 16.h),
    const DailyChallengesSection(),
    ],
    );
    }

    Widget _buildRecentVotesSection() {
    return Obx(() {
    if (controller.isLoading.value) {
    return const LoadingWidget();
    }

    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Row(
    children: [
    Icon(
    Icons.history_rounded,
    color: AppColors.textSecondary,
    size: 20.sp,
    ),
    SizedBox(width: 8.w),
    Text(
    'Seus Votos Recentes',
    style: TextStyles.titleMedium.copyWith(
    fontWeight: FontWeight.w600,
    ),
    ),
    const Spacer(),
    TextButton(
    onPressed: () => controller.viewAllVotes(),
    child: Text(
    'Ver todos',
    style: TextStyles.bodyMedium.copyWith(
    color: AppColors.primary,
    ),
    ),
    ),
    ],
    ),
    ),
    SizedBox(height: 12.h),
    _buildRecentVotesList(),
    ],
    );
    });
    }

    Widget _buildRecentVotesList() {
    // Aqui você implementaria a lista de votos recentes
    return Container(
    height: 120.h,
    child: ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    itemCount: 5, // Placeholder
    itemBuilder: (context, index) {
    return Container(
    width: 200.w,
    margin: EdgeInsets.only(right: 12.w),
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(
    color: AppColors.border.withOpacity(0.3),
    ),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    children: [
    Container(
    width: 24.w,
    height: 24.h,
    decoration: BoxDecoration(
    color: AppColors.primary,
    shape: BoxShape.circle,
    ),
    child: Icon(
    Icons.check_rounded,
    color: Colors.white,
    size: 14.sp,
    ),
    ),
    SizedBox(width: 8.w),
    Expanded(
    child: Text(
    'Você votou em',
    style: TextStyles.bodySmall.copyWith(
    color: AppColors.textSecondary,
    ),
    ),
    ),
    ],
    ),
    SizedBox(height: 8.h),
    Text(
    'Look para festa de aniversário',
    style: TextStyles.labelMedium.copyWith(
    fontWeight: FontWeight.w600,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    ),
    const Spacer(),
    Text(
    'Há 2 horas',
    style: TextStyles.bodySmall.copyWith(
    color: AppColors.textTertiary,
    ),
    ),
    ],
    ),
    );
    },
    ),
    );
    }

    String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    final userName = controller.getCurrentUserName();

    String greeting;
    if (hour < 12) {
    greeting = 'Bom dia';
    } else if (hour < 18) {
    greeting = 'Boa tarde';
    } else {
    greeting = 'Boa noite';
    }

    return '$greeting, $userName! 💫';
    }
    }
