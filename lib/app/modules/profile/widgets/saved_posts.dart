import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/post_model.dart';
import 'package:look4me/app/modules/navigation/controllers/navigation_controller.dart';
import 'package:look4me/app/shared/components/empty_state.dart';

class SavedPosts extends StatelessWidget {
  final List<PostModel> savedPosts;
  final Function(String)? onRemoveFromSaved;

  const SavedPosts({
    super.key,
    required this.savedPosts,
    this.onRemoveFromSaved,
  });

  @override
  Widget build(BuildContext context) {
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

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1 / 1.25,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final post = savedPosts[index];
          return _buildSavedPostCard(context, post);
        },
        childCount: savedPosts.length,
      ),
    );
  }

  Widget _buildSavedPostCard(BuildContext context, PostModel post) {
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
                        maxLines: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showRemoveDialog(context, post),
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

  Widget _buildImagePreview(BuildContext context, PostModel post, int winningOption) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showFullImage(context, post.imageOption1),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: winningOption == 1 ? Colors.amber : Colors.transparent,
                        width: winningOption == 1 ? 2.w : 0,
                      ),
                    ),
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
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textTertiary,
                        ),
                      ),
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
                        color: winningOption == 2 ? Colors.amber : Colors.transparent,
                        width: winningOption == 2 ? 2.w : 0,
                      ),
                    ),
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
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
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
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              height: Get.height * 0.8,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            Positioned(
              top: 10.w,
              right: 10.w,
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

  void _showRemoveDialog(BuildContext context, PostModel post) {
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
              onRemoveFromSaved?.call(post.id);
              Get.snackbar(
                'Removido',
                'Post removido dos salvos',
                backgroundColor: Colors.amber,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
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
}
