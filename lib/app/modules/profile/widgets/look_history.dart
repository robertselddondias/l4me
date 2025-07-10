import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/post_model.dart';

class LookHistory extends StatelessWidget {
  final List<PostModel> posts;
  final Function(String)? onDeletePost;

  const LookHistory({
    Key? key,
    required this.posts,
    this.onDeletePost,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final post = posts[index];
          return _buildPostCard(post);
        },
        childCount: posts.length,
      ),
    );
  }

  Widget _buildPostCard(PostModel post) {
    return GestureDetector(
      onTap: () => _showPostDetails(post),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePreview(post),
            _buildPostInfo(post),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(PostModel post) {
    return Expanded(
      flex: 3,
      child: Container(
        width: double.infinity,
        child: ClipRRect(
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
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceVariant,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceVariant,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, color: AppColors.border),
                  Expanded(
                    child: CachedNetworkImage(
                      imageUrl: post.imageOption2,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceVariant,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surfaceVariant,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: PopupMenuButton<String>(
                  icon: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'delete' && onDeletePost != null) {
                      onDeletePost!(post.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Deletar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    post.occasionDisplayName,
                    style: TextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostInfo(PostModel post) {
    final winningOption = post.option1Votes > post.option2Votes ? 1 : 2;
    final winningPercentage = post.option1Votes > post.option2Votes
        ? post.option1Percentage
        : post.option2Percentage;

    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.all(12.w),
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
              SizedBox(height: 8.h),
            ],
            Row(
              children: [
                Icon(
                  Icons.how_to_vote_outlined,
                  size: 14.sp,
                  color: AppColors.textTertiary,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${post.totalVotes} votos',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            if (post.totalVotes > 0) ...[
              Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 14.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Opção $winningOption venceu (${winningPercentage.toStringAsFixed(0)}%)',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const Spacer(),
            Text(
              _formatDate(post.createdAt),
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostDetails(PostModel post) {
    // Implementar modal com detalhes do post
    // Por enquanto, vamos usar um BottomSheet simples
    showModalBottomSheet(
      context: navigatorKey.currentContext!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPostDetailsModal(post),
    );
  }

  Widget _buildPostDetailsModal(PostModel post) {
    return Container(
      height: 0.8.sh,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              color: AppColors.textTertiary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          post.description.isNotEmpty
                              ? post.description
                              : 'Look para ${post.occasionDisplayName}',
                          style: TextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          post.occasionDisplayName,
                          style: TextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImageWithResult(
                          post.imageOption1,
                          1,
                          post.option1Votes,
                          post.option1Percentage,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildImageWithResult(
                          post.imageOption2,
                          2,
                          post.option2Votes,
                          post.option2Percentage,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildResultsSummary(post),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWithResult(String imageUrl, int option, int votes, double percentage) {
    return Column(
      children: [
        Container(
          height: 200.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: votes > 0 ? AppColors.primary : AppColors.border,
              width: votes > 0 ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Opção $option',
          style: TextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${percentage.toStringAsFixed(0)}% ($votes votos)',
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSummary(PostModel post) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultados',
            style: TextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total de votos:',
                style: TextStyles.bodyMedium,
              ),
              Text(
                '${post.totalVotes}',
                style: TextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Publicado em:',
                style: TextStyles.bodyMedium,
              ),
              Text(
                _formatDate(post.createdAt),
                style: TextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else {
      return 'Há pouco';
    }
  }

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
