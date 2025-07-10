import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/modules/auth/controllers/auth_controller.dart';
import 'package:look4me/app/shared/components/custom_button.dart';
import 'package:look4me/app/shared/components/custom_text_field.dart';

class PhoneAuthView extends GetView<AuthController> {
  const PhoneAuthView({Key? key}) : super(key: key);

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
              Obx(() => controller.verificationId.value.isEmpty
                  ? _buildPhoneForm()
                  : _buildOTPForm()),
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
        Text(
          'Entrar com telefone',
          style: TextStyles.headlineLarge.copyWith(
            color: AppColors.text,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() => Text(
          controller.verificationId.value.isEmpty
              ? 'Digite seu número de telefone para receber um código de verificação'
              : 'Digite o código de 6 dígitos enviado para seu telefone',
          style: TextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        )),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Form(
      key: controller.phoneFormKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CountryCodePicker(
                  onChanged: (country) {},
                  initialSelection: 'BR',
                  favorite: const ['+55', 'BR'],
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  alignLeft: false,
                  padding: EdgeInsets.zero,
                  textStyle: TextStyles.bodyMedium,
                ),
                Container(
                  width: 1,
                  height: 40.h,
                  color: AppColors.border,
                ),
                Expanded(
                  child: CustomTextField(
                    controller: controller.phoneController,
                    hint: '(11) 99999-9999',
                    keyboardType: TextInputType.phone,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Telefone é obrigatório';
                      }
                      if (value!.length < 10) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          Obx(
                () => CustomButton(
              text: 'Enviar Código',
              onPressed: controller.sendPhoneVerification,
              isLoading: controller.isLoading.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPForm() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) => _buildOTPField(index)),
        ),
        SizedBox(height: 24.h),
        TextButton(
          onPressed: () {
            controller.verificationId.value = '';
            controller.otpController.clear();
          },
          child: Text(
            'Alterar número',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 32.h),
        Obx(
              () => CustomButton(
            text: 'Verificar Código',
            onPressed: controller.verifyOTP,
            isLoading: controller.isLoading.value,
            isEnabled: controller.otpController.text.length == 6,
          ),
        ),
        SizedBox(height: 16.h),
        TextButton(
          onPressed: controller.sendPhoneVerification,
          child: Text(
            'Reenviar código',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 45.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: controller.otpController.text.length > index
              ? AppColors.primary
              : AppColors.border,
          width: controller.otpController.text.length > index ? 2 : 1,
        ),
      ),
      child: Center(
        child: TextField(
          onChanged: (value) {
            if (value.length == 1 && index < 5) {
              FocusScope.of(Get.context!).nextFocus();
            } else if (value.isEmpty && index > 0) {
              FocusScope.of(Get.context!).previousFocus();
            }

            String currentOTP = controller.otpController.text;
            if (index < currentOTP.length) {
              currentOTP = currentOTP.replaceRange(index, index + 1, value);
            } else {
              currentOTP += value;
            }
            controller.otpController.text = currentOTP;
          },
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
          ),
        ),
      ),
    );
  }
}
