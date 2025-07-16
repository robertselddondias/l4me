import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool showShimmer;

  const LoadingWidget({
    super.key,
    this.message,
    this.showShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    if (showShimmer) {
      return _buildShimmerList();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: 5,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmer,
        highlightColor: AppColors.shimmerHighlight,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerHeader(),
              _buildShimmerImages(),
              _buildShimmerFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: const BoxDecoration(
              color: AppColors.shimmer,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: AppColors.shimmer,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 80.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: AppColors.shimmer,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60.w,
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

  Widget _buildShimmerImages() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 240.h,
              decoration: BoxDecoration(
                color: AppColors.shimmer,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              height: 240.h,
              decoration: BoxDecoration(
                color: AppColors.shimmer,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerFooter() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.shimmer,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: AppColors.shimmer,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                width: 60.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: AppColors.shimmer,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              const Spacer(),
              Container(
                width: 40.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: AppColors.shimmer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 40.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: AppColors.shimmer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
