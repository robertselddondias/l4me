import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';

class TrendingPollsSection extends StatelessWidget {
  const TrendingPollsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _getMockTrendingPolls().length,
        itemBuilder: (context, index) {
          final poll = _getMockTrendingPolls()[index];
          return Container(
            width: 160.w,
            margin: EdgeInsets.only(right: 12.w),
            child: _buildTrendingPollCard(poll),
          );
        },
      ),
    );
  }

  Widget _buildTrendingPollCard(Map<String, dynamic> poll) {
    return Container(
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
          // Imagem preview
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CachedNetworkImage(
                            imageUrl: poll['image1'],
                            fit: BoxFit.cover,
                            height: double.infinity,
                          ),
                        ),
                        Container(width: 1, color: Colors.white),
                        Expanded(
                          child: CachedNetworkImage(
                            imageUrl: poll['image2'],
                            fit: BoxFit.cover,
                            height: double.infinity,
                          ),
                        ),
                      ],
                    ),
                    // Badge de trending
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange, Colors.red],
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_up_rounded,
                              color: Colors.white,
                              size: 10.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'HOT',
                              style: TextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 8.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Conteúdo
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poll['question'],
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
                          poll['occasion'],
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
                            '${poll['votes']}',
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
  }

  List<Map<String, dynamic>> _getMockTrendingPolls() {
    return [
      {
        'question': 'Melhor look para reunião importante?',
        'image1': 'https://picsum.photos/150/200?random=20',
        'image2': 'https://picsum.photos/150/200?random=21',
        'occasion': 'Trabalho',
        'votes': 234,
      },
      {
        'question': 'Qual para jantar romântico?',
        'image1': 'https://picsum.photos/150/200?random=22',
        'image2': 'https://picsum.photos/150/200?random=23',
        'occasion': 'Encontro',
        'votes': 189,
      },
      {
        'question': 'Look para festa de formatura?',
        'image1': 'https://picsum.photos/150/200?random=24',
        'image2': 'https://picsum.photos/150/200?random=25',
        'occasion': 'Festa',
        'votes': 156,
      },
      {
        'question': 'Estilo para workshop?',
        'image1': 'https://picsum.photos/150/200?random=26',
        'image2': 'https://picsum.photos/150/200?random=27',
        'occasion': 'Casual',
        'votes': 98,
      },
    ];
  }
}
