import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/modules/create_post/controllers/create_post_controller.dart';
import 'package:look4me/app/modules/create_post/widgets/image_picker_widget.dart';
import 'package:look4me/app/modules/create_post/widgets/occasion_selector.dart'; // Certifique-se de que o import está correto
import 'package:look4me/app/shared/components/custom_button.dart';
import 'package:look4me/app/shared/components/custom_text_field.dart';

class CreatePostView extends GetView<CreatePostController> {
  const CreatePostView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Desfoca o campo de texto atual, fechando o teclado
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        SizedBox(height: 24.h),
                        _buildDescriptionField(),
                        SizedBox(height: 24.h),
                        _buildImagesSection(),
                        SizedBox(height: 24.h),
                        _buildOccasionSection(),
                        SizedBox(height: 24.h),
                        _buildTagsSection(),
                        SizedBox(height: 32.h),
                        _buildCreateButton(),
                        SizedBox(height: 20.h),
                      ],
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

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                Icons.close_rounded,
                color: AppColors.text,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Criar Look',
              style: TextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compartilhe seu look! 💫',
          style: TextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Mostre duas opções e deixe a comunidade escolher qual fica melhor em você.',
          style: TextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descrição *',
          style: TextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        CustomTextField(
          controller: controller.descriptionController,
          hint: 'Ex: Qual dessas opções fica melhor para o trabalho?',
          maxLines: 3,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Descrição é obrigatória';
            }
            if (value!.length < 10) {
              return 'Descrição deve ter pelo menos 10 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opções de Look *',
          style: TextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Adicione duas fotos para que as pessoas possam votar',
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: Obx(() => ImagePickerWidget(
                imagePath: controller.image1Path.value,
                label: 'Opção 1',
                onTap: () => controller.showImageSourceDialog(1),
              )),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Obx(() => ImagePickerWidget(
                imagePath: controller.image2Path.value,
                label: 'Opção 2',
                onTap: () => controller.showImageSourceDialog(2),
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOccasionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ocasião *',
          style: TextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Para que tipo de ocasião é este look?',
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() => OccasionSelector(
          occasions: controller.occasions,
          selectedOccasion: controller.selectedOccasion.value,
          onOccasionSelected: controller.selectOccasion,
        )),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags (Opcional)',
          style: TextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Adicione até 5 tags para ajudar outros usuários a encontrar seu look',
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() => Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: controller.availableTags.map((tag) {
            final isSelected = controller.selectedTags.contains(tag);
            return GestureDetector(
              onTap: () => controller.toggleTag(tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.border,
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.onPrimary : AppColors.text,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        if (controller.selectedTags.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Text(
            '${controller.selectedTags.length}/5 tags selecionadas',
            style: TextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCreateButton() {
    return Obx(() => CustomButton(
      text: 'Publicar Look',
      onPressed: controller.canCreatePost ? controller.createPost : null,
      isLoading: controller.isLoading.value,
      isEnabled: controller.canCreatePost,
      icon: Icons.publish_rounded,
    ));
  }
}
