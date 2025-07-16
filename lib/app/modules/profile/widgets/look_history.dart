// lib/app/modules/profile/widgets/look_history.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/post_model.dart';
import 'package:get/get.dart';

class LookHistory extends StatelessWidget {
  final List<PostModel> posts;
  final Function(String)? onDeletePost;

  const LookHistory({
    super.key,
    required this.posts,
    this.onDeletePost,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1 / 1.25, // Ajustado para mais vertical como no Instagram
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final post = posts[index];
          return _buildPostCard(context, post); // Passa o context para o card
        },
        childCount: posts.length,
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, PostModel post) {
    // 0 se empate, 1 se opção 1 venceu, 2 se opção 2 venceu
    final winningOption = post.option1Votes > post.option2Votes ? 1 : (post.option1Votes < post.option2Votes ? 2 : 0);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: _buildImagePreview(context, post, winningOption),
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
                      Icons.how_to_vote_outlined,
                      size: 12.sp,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${post.totalVotes} votos',
                      style: TextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDate(post.createdAt),
                  style: TextStyles.bodySmall.copyWith( // Usando bodySmall, que é o menor definido no tema
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, PostModel post, int winningOption) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showFullImage(context, post.imageOption1),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: winningOption == 1 ? AppColors.primary : Colors.transparent,
                    width: winningOption == 1 ? 1.5.w : 0, // Borda mais suave para o vencedor
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl: post.imageOption1,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1.5)),
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textTertiary)),
                ),
              ),
            ),
          ),
          SizedBox(width: 1.w),
          Expanded(
            child: GestureDetector(
              onTap: () => _showFullImage(context, post.imageOption2),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: winningOption == 2 ? AppColors.primary : Colors.transparent,
                    width: winningOption == 2 ? 1.5.w : 0, // Borda mais suave para o vencedor
                  ),
                ),
                child: CachedNetworkImage(
                  imageUrl: post.imageOption2,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1.5)),
                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textTertiary)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    Get.dialog(
      AlertDialog( // Linha 164
        contentPadding: EdgeInsets.zero,
        content: Stack(
          children: [
            // CORREÇÃO: Removido 'width: double.infinity' para permitir que o AlertDialog defina a largura
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              height: Get.height * 0.8, // Mantém a altura responsiva
              placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textTertiary)),
            ),
            Positioned(
              top: 10.w,
              left: 10.w,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else {
      return 'Há pouco';
    }
  }
}
