import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';

enum ButtonType { filled, outlined, text }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? child;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.filled,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? _getHeight(),
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    final isDisabled = !isEnabled || isLoading;

    switch (type) {
      case ButtonType.filled:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: textColor ?? AppColors.onPrimary,
            disabledBackgroundColor: AppColors.textTertiary,
            disabledForegroundColor: AppColors.surface,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(16.r),
            ),
            padding: padding ?? _getPadding(),
          ),
          child: _buildContent(),
        );

      case ButtonType.outlined:
        return OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? AppColors.primary,
            disabledForegroundColor: AppColors.textTertiary,
            side: BorderSide(
              color: isDisabled
                  ? AppColors.textTertiary
                  : (borderColor ?? AppColors.primary),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(16.r),
            ),
            padding: padding ?? _getPadding(),
          ),
          child: _buildContent(),
        );

      case ButtonType.text:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? AppColors.primary,
            disabledForegroundColor: AppColors.textTertiary,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(16.r),
            ),
            padding: padding ?? _getPadding(),
          ),
          child: _buildContent(),
        );
    }
  }

  Widget _buildContent() {
    if (child != null) return child!;

    if (isLoading) {
      return SizedBox(
        width: _getLoadingSize(),
        height: _getLoadingSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.filled
                ? AppColors.onPrimary
                : AppColors.primary,
          ),
        ),
      );
    }

    final textWidget = Text(
      text,
      style: _getTextStyle(),
    );

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          SizedBox(width: 8.w),
          textWidget,
        ],
      );
    }

    return textWidget;
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 40.h;
      case ButtonSize.medium:
        return 52.h;
      case ButtonSize.large:
        return 60.h;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);
      case ButtonSize.medium:
        return EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h);
      case ButtonSize.large:
        return EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h);
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = size == ButtonSize.small
        ? TextStyles.labelMedium
        : TextStyles.labelLarge;

    return baseStyle.copyWith(
      fontWeight: FontWeight.w600,
      color: textColor,
    );
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16.sp;
      case ButtonSize.medium:
        return 20.sp;
      case ButtonSize.large:
        return 24.sp;
    }
  }

  double _getLoadingSize() {
    switch (size) {
      case ButtonSize.small:
        return 16.sp;
      case ButtonSize.medium:
        return 20.sp;
      case ButtonSize.large:
        return 24.sp;
    }
  }
}
