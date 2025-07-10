import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'custom_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? customAction;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
    this.customAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            SizedBox(height: 24.h),
            _buildTitle(),
            SizedBox(height: 12.h),
            _buildSubtitle(),
            if (actionText != null || customAction != null) ...[
              SizedBox(height: 32.h),
              _buildAction(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 80.w,
      height: 80.h,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 40.sp,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyles.headlineSmall.copyWith(
        color: AppColors.text,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: TextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.4,
      ),
    );
  }

  Widget _buildAction() {
    if (customAction != null) {
      return customAction!;
    }

    if (actionText != null && onAction != null) {
      return CustomButton(
        text: actionText!,
        onPressed: onAction,
        type: ButtonType.outlined,
        size: ButtonSize.medium,
        width: 200.w,
      );
    }

    return const SizedBox.shrink();
  }
}
