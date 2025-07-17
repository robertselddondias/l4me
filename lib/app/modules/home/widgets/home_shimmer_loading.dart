import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:look4me/app/core/constants/app_colors.dart';

class HomeShimmerLoading extends StatelessWidget {
  const HomeShimmerLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 12.h),
      itemCount: 3,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmer,
        highlightColor: AppColors.shimmerHighlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerHeader(),
            _buildShimmerDescription(),
            _buildShimmerImages(),
            _buildShimmerFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      child: Row(
        children: [
          // Avatar with gradient border shimmer
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.shimmer,
            ),
            padding: EdgeInsets.all(2.w),
            child: CircleAvatar(
              radius: 22.r,
              backgroundColor: AppColors.shimmer,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 120.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: AppColors.shimmer,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 40.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: AppColors.shimmer,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 80.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: AppColors.shimmer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: AppColors.shimmer,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerDescription() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 16.h,
            decoration: BoxDecoration(
              color: AppColors.shimmer,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 200.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: AppColors.shimmer,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerImages() {
    return Container(
      height: 320.h, // Proporção similar ao AspectRatio 0.8
      child: Row(
        children: [
          Expanded(
            child: Container(
              color: AppColors.shimmer,
              child: Stack(
                children: [
                  // Shimmer para option label
                  Positioned(
                    top: 16.h,
                    left: 16.w,
                    child: Container(
                      width: 60.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerHighlight,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  // Shimmer para botão de voto
                  Positioned(
                    bottom: 20.h,
                    left: 16.w,
                    right: 16.w,
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerHighlight,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.shimmer,
              child: Stack(
                children: [
                  // Shimmer para option label
                  Positioned(
                    top: 16.h,
                    left: 16.w,
                    child: Container(
                      width: 60.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerHighlight,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  // Shimmer para botão de voto
                  Positioned(
                    bottom: 20.h,
                    left: 16.w,
                    right: 16.w,
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerHighlight,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
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

  Widget _buildShimmerFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Action buttons row shimmer
          Row(
            children: [
              Container(
                width: 80.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppColors.shimmer,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              SizedBox(width: 24.w),
              Container(
                width: 100.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppColors.shimmer,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              const Spacer(),
              Container(
                width: 100.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: AppColors.shimmer,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Tags row shimmer
          Row(
            children: [
              Container(
                width: 16.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: AppColors.shimmer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                width: 50.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: AppColors.shimmer,
                  borderRadius: BorderRadius.circular(7.r),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 60.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: AppColors.shimmer,
                  borderRadius: BorderRadius.circular(7.r),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 40.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: AppColors.shimmer,
                  borderRadius: BorderRadius.circular(7.r),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
