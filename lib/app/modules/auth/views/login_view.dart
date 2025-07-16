import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/modules/auth/controllers/auth_controller.dart';
import 'package:look4me/app/modules/auth/widgets/social_login_buttons.dart';
import 'package:look4me/app/routes/app_routes.dart';
import 'package:look4me/app/shared/components/custom_button.dart';
import 'package:look4me/app/shared/components/custom_text_field.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              _buildHeader(),
              SizedBox(height: 48.h),
              _buildLoginForm(),
              SizedBox(height: 32.h),
              _buildDivider(),
              SizedBox(height: 32.h),
              _buildSocialLogin(),
              SizedBox(height: 24.h),
              _buildFooter(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Icon(
            Icons.favorite_rounded,
            color: AppColors.onPrimary,
            size: 40.sp,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'Bem-vinda de volta!',
          style: TextStyles.headlineLarge.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Entre na sua conta e continue descobrindo os melhores looks',
          style: TextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: controller.loginFormKey,
      child: Column(
        children: [
          CustomTextField(
            controller: controller.emailController,
            label: 'Email',
            hint: 'Digite seu email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Email é obrigatório';
              }
              if (!GetUtils.isEmail(value!)) {
                return 'Email inválido';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          Obx(
                () => CustomTextField(
              controller: controller.passwordController,
              label: 'Senha',
              hint: 'Digite sua senha',
              obscureText: controller.obscurePassword.value,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Senha é obrigatória';
                }
                if (value!.length < 6) {
                  return 'Senha deve ter pelo menos 6 caracteres';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 16.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: controller.resetPassword,
              child: Text(
                'Esqueceu sua senha?',
                style: TextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 32.h),
          Obx(
                () => CustomButton(
              text: 'Entrar',
              onPressed: controller.signInWithEmail,
              isLoading: controller.isLoading.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'ou',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        SocialLoginButtons(
          onGooglePressed: controller.signInWithGoogle,
          onApplePressed: controller.signInWithApple,
          onPhonePressed: () => Get.toNamed(AppRoutes.PHONE_AUTH),
          isLoading: controller.isLoading.value,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Não tem conta? ',
          style: TextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            controller.clearControllers();
            Get.toNamed(AppRoutes.REGISTER);
          },
          child: Text(
            'Criar conta',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
