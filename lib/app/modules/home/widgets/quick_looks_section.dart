import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/quick_look_model.dart';

class QuickLooksSection extends StatelessWidget {
  const QuickLooksSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280.h,
      child: PageView.builder(
        padEnds: false,
        controller: PageController(viewportFraction: 0.85),
        itemCount: _getMockQuickLooks().length,
        itemBuilder: (context, index) {
          final quickLook = _getMockQuickLooks()[index];
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
  }

  Widget _buildQuickLookCard(QuickLookModel quickLook) {
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
            // Background das imagens
            _buildImageBackground(quickLook),

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
            _buildTopInfo(quickLook),

            // Conteúdo na parte inferior
            _buildBottomContent(quickLook),

            // Botões de votação
            _buildVotingButtons(quickLook),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBackground(QuickLookModel quickLook) {
    return Row(
      children: [
        Expanded(
          child: CachedNetworkImage(
            imageUrl: quickLook.imageOption1,
            fit: BoxFit.cover,
            height: double.infinity,
            placeholder: (context, url) => Container(
              color: AppColors.primaryLight.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.primaryLight,
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.primary,
                size: 40.sp,
              ),
            ),
          ),
        ),
        Container(
          width: 2,
          color: Colors.white.withOpacity(0.3),
        ),
        Expanded(
          child: CachedNetworkImage(
            imageUrl: quickLook.imageOption2,
            fit: BoxFit.cover,
            height: double.infinity,
            placeholder: (context, url) => Container(
              color: AppColors.secondaryLight.withOpacity(0.3),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.secondary,
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.secondaryLight,
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.secondary,
                size: 40.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopInfo(QuickLookModel quickLook) {
    return Positioned(
      top: 16.h,
      left: 16.w,
      right: 16.w,
      child: Row(
        children: [
          // Timer countdown
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
                  _getTimeRemaining(quickLook.expiresAt),
                  style: TextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // User avatar
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
              backgroundImage: quickLook.authorProfileImage != null
                  ? CachedNetworkImageProvider(quickLook.authorProfileImage!)
                  : null,
              child: quickLook.authorProfileImage == null
                  ? Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 16.sp,
              )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomContent(QuickLookModel quickLook) {
    return Positioned(
      bottom: 80.h,
      left: 16.w,
      right: 16.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quickLook.authorName,
            style: TextStyles.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            quickLook.question,
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
              color: _getOccasionColor(quickLook.occasion).withOpacity(0.9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              quickLook.occasionDisplayName,
              style: TextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotingButtons(QuickLookModel quickLook) {
    return Positioned(
      bottom: 16.h,
      left: 16.w,
      right: 16.w,
      child: Row(
        children: [
          Expanded(
            child: _buildVoteButton(
              label: 'Opção 1',
              votes: quickLook.option1Votes,
              percentage: quickLook.option1Percentage,
              isWinning: quickLook.option1Votes > quickLook.option2Votes,
              onTap: () => _voteOption(quickLook.id, 1),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildVoteButton(
              label: 'Opção 2',
              votes: quickLook.option2Votes,
              percentage: quickLook.option2Percentage,
              isWinning: quickLook.option2Votes > quickLook.option1Votes,
              onTap: () => _voteOption(quickLook.id, 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoteButton({
    required String label,
    required int votes,
    required double percentage,
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
                  '${percentage.toStringAsFixed(0)}%',
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

  // Mock data para demonstração
  List<QuickLookModel> _getMockQuickLooks() {
    return [
      QuickLookModel(
        id: '1',
        authorId: 'user1',
        authorName: 'Maria Silva',
        authorProfileImage: 'https://picsum.photos/100/100?random=1',
        question: 'Qual fica melhor para o trabalho hoje?',
        imageOption1: 'https://picsum.photos/300/400?random=10',
        imageOption2: 'https://picsum.photos/300/400?random=11',
        occasion: 'trabalho',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
        option1Votes: 23,
        option2Votes: 31,
      ),
      QuickLookModel(
        id: '2',
        authorId: 'user2',
        authorName: 'Ana Costa',
        question: 'Para encontro romântico, qual escolher?',
        imageOption1: 'https://picsum.photos/300/400?random=12',
        imageOption2: 'https://picsum.photos/300/400?random=13',
        occasion: 'encontro',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        expiresAt: DateTime.now().add(const Duration(minutes: 13)),
        option1Votes: 45,
        option2Votes: 38,
      ),
      QuickLookModel(
        id: '3',
        authorId: 'user3',
        authorName: 'Carla Mendes',
        question: 'Look para festa de aniversário?',
        imageOption1: 'https://picsum.photos/300/400?random=14',
        imageOption2: 'https://picsum.photos/300/400?random=15',
        occasion: 'festa',
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        expiresAt: DateTime.now().add(const Duration(minutes: 7)),
        option1Votes: 67,
        option2Votes: 52,
      ),
    ];
  }

  String _getTimeRemaining(DateTime expiresAt) {
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.inMinutes <= 0) return 'Expirado';
    return '${remaining.inMinutes}min';
  }

  Color _getOccasionColor(String occasion) {
    switch (occasion) {
      case 'trabalho':
        return Colors.blue;
      case 'festa':
        return Colors.purple;
      case 'encontro':
        return Colors.pink;
      case 'casual':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  void _voteOption(String quickLookId, int option) {
    // Implementar lógica de votação
    Get.snackbar(
      'Voto registrado!',
      'Você votou na Opção $option',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
