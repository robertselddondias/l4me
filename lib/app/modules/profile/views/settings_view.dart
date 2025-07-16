// lib/app/modules/profile/views/settings_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/modules/profile/controllers/profile_controller.dart';
import 'package:look4me/app/shared/components/custom_button.dart';

class SettingsView extends GetView<ProfileController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    Text(
                      'Configurações da Conta',
                      style: TextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    _buildAccountActions(),
                    SizedBox(height: 32.h),
                    // Você pode adicionar mais seções de configurações aqui no futuro
                    // Ex: Notificações, Privacidade, etc.
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.text,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Configurações',
              style: TextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações da Conta',
          style: TextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 16.h),
        CustomButton(
          text: 'Sair da Conta',
          onPressed: controller.signOut,
          type: ButtonType.outlined,
          icon: Icons.logout_outlined,
          textColor: AppColors.primary,
          borderColor: AppColors.primary,
        ),
        SizedBox(height: 16.h),
        CustomButton(
          text: 'Excluir Conta',
          onPressed: controller.deleteAccount,
          type: ButtonType.outlined,
          icon: Icons.delete_outline,
          textColor: AppColors.error,
          borderColor: AppColors.error,
        ),
      ],
    );
  }
}
