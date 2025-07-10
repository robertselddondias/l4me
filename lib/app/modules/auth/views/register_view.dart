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

class RegisterView extends GetView<AuthController> {
  const RegisterView({Key? key}) : super(key: key);

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
              SizedBox(height: 40.h),
              _buildHeader(),
              SizedBox(height: 40.h),
              _buildWelcomeCard(),
              SizedBox(height: 32.h),
              _buildRegisterForm(),
              SizedBox(height: 24.h),
              _buildTermsAndPrivacy(),
              SizedBox(height: 32.h),
              _buildDivider(),
              SizedBox(height: 24.h),
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
        SizedBox(height: 32.h),
        Row(
          children: [
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.person_add_rounded,
                color: AppColors.onPrimary,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Criar conta',
                    style: TextStyles.headlineLarge.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Junte-se à comunidade',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withOpacity(0.1),
            AppColors.secondaryLight.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                color: AppColors.primary,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Bem-vinda ao Look4Me!',
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Descubra o look perfeito para cada ocasião com a ajuda da nossa comunidade de mulheres incríveis! 💫',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildFeatureBadge(Icons.how_to_vote_rounded, 'Vote em looks'),
              SizedBox(width: 8.w),
              _buildFeatureBadge(Icons.auto_stories_rounded, 'Dicas rápidas'),
              SizedBox(width: 8.w),
              _buildFeatureBadge(Icons.people_rounded, 'Comunidade'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.border.withOpacity(0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 16.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              text,
              style: TextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: controller.registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações da Conta',
            style: TextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: controller.nameController,
            label: 'Nome Completo',
            hint: 'Digite seu nome completo',
            prefixIcon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Nome é obrigatório';
              }
              if (value!.length < 2) {
                return 'Nome deve ter pelo menos 2 caracteres';
              }
              if (value.split(' ').length < 2) {
                return 'Digite seu nome completo';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            controller: controller.emailController,
            label: 'Email',
            hint: 'Digite seu melhor email',
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
              hint: 'Crie uma senha segura',
              obscureText: controller.obscurePassword.value,
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
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
                if (!value.contains(RegExp(r'[A-Za-z]')) ||
                    !value.contains(RegExp(r'[0-9]'))) {
                  return 'Senha deve conter letras e números';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 16.h),
          _buildPasswordStrengthIndicator(),
          SizedBox(height: 20.h),
          Obx(
                () => CustomTextField(
              controller: controller.confirmPasswordController,
              label: 'Confirmar Senha',
              hint: 'Digite sua senha novamente',
              obscureText: controller.obscureConfirmPassword.value,
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureConfirmPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Confirmação de senha é obrigatória';
                }
                if (value != controller.passwordController.text) {
                  return 'Senhas não coincidem';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 32.h),
          Obx(
                () => CustomButton(
              text: 'Criar Minha Conta',
              onPressed: controller.signUpWithEmail,
              isLoading: controller.isLoading.value,
              icon: Icons.arrow_forward_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Obx(() {
      final password = controller.passwordController.text;
      final strength = _calculatePasswordStrength(password);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Força da senha: ',
                style: TextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _getStrengthText(strength),
                style: TextStyles.bodySmall.copyWith(
                  color: _getStrengthColor(strength),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  height: 4.h,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 4.w),
                  decoration: BoxDecoration(
                    color: index < strength
                        ? _getStrengthColor(strength)
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              );
            }),
          ),
        ],
      );
    });
  }

  Widget _buildTermsAndPrivacy() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.textSecondary,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Ao criar uma conta, você concorda com nossos '),
                  TextSpan(
                    text: 'Termos de Uso',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' e '),
                  TextSpan(
                    text: 'Política de Privacidade',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
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
            'ou cadastre-se com',
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
          'Já tem uma conta? ',
          style: TextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            controller.clearControllers();
            Get.back();
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          ),
          child: Text(
            'Fazer login',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;

    // Length
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;

    // Contains letters and numbers
    if (password.contains(RegExp(r'[A-Za-z]')) &&
        password.contains(RegExp(r'[0-9]'))) strength++;

    // Contains special characters
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength;
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Fraca';
      case 2:
        return 'Média';
      case 3:
        return 'Forte';
      case 4:
        return 'Muito Forte';
      default:
        return 'Fraca';
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.info;
      case 4:
        return AppColors.success;
      default:
        return AppColors.error;
    }
  }
}
