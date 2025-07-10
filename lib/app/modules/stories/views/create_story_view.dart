import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/story_model.dart';
import 'package:look4me/app/modules/stories/controllers/stories_controller.dart';
import 'package:look4me/app/shared/components/custom_button.dart';
import 'package:look4me/app/shared/components/custom_text_field.dart';

class CreateStoryView extends GetView<StoriesController> {
  const CreateStoryView({Key? key}) : super(key: key);

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
                child: Form(
                  key: controller.createFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 32.h),
                      _buildImageSection(),
                      SizedBox(height: 24.h),
                      _buildContentField(),
                      SizedBox(height: 24.h),
                      _buildTypeSelector(),
                      SizedBox(height: 24.h),
                      _buildLinkField(),
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
              'Criar Story',
              style: TextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.onPrimary,
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  '24h',
                  style: TextStyles.labelSmall.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
        Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                color: AppColors.onPrimary,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compartilhe uma dica! ✨',
                    style: TextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    'Stories desaparecem em 24 horas',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLight.withOpacity(0.1),
                AppColors.secondaryLight.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Compartilhe dicas de moda, looks do dia, tendências e muito mais!',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Imagem',
              style: TextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Opcional',
                style: TextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'Adicione uma imagem para tornar seu story mais atrativo',
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() => _buildImagePicker()),
      ],
    );
  }

  Widget _buildImagePicker() {
    final hasImage = controller.selectedImagePath.value.isNotEmpty;

    return GestureDetector(
      onTap: controller.showImageSourceDialog,
      child: Container(
        height: hasImage ? 200.h : 120.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: hasImage ? Colors.transparent : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: hasImage ? AppColors.primary : AppColors.border,
            width: hasImage ? 2 : 1,
          ),
        ),
        child: hasImage ? _buildImagePreview() : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_photo_alternate_outlined,
            color: AppColors.primary,
            size: 24.sp,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Adicionar Imagem',
          style: TextStyles.titleSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 14.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 4.w),
            Text(
              'Câmera',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 8.w),
            Text('•', style: TextStyle(color: AppColors.textTertiary)),
            SizedBox(width: 8.w),
            Icon(
              Icons.photo_library_outlined,
              size: 14.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 4.w),
            Text(
              'Galeria',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Image.file(
            File(controller.selectedImagePath.value),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.error.withOpacity(0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 32.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Erro ao carregar imagem',
                      style: TextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: 16.h,
          right: 16.w,
          child: Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
        ),
        Positioned(
          bottom: 16.h,
          left: 16.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: Colors.white,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Toque para alterar',
                  style: TextStyles.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Conteúdo',
              style: TextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyles.titleSmall.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'Compartilhe sua dica, tendência ou inspiração',
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: controller.contentController,
          hint: 'Ex: Dica incrível para combinar acessórios dourados com looks casuais...',
          maxLines: 4,
          maxLength: 280,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Conteúdo é obrigatório';
            }
            if (value!.length < 10) {
              return 'Conteúdo deve ter pelo menos 10 caracteres';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Story',
          style: TextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Escolha o tipo que melhor descreve seu conteúdo',
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        Obx(() => Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: controller.storyTypes.map((type) {
            final isSelected = controller.selectedType.value == type;
            return GestureDetector(
              onTap: () => controller.selectStoryType(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: isSelected ? _getTypeGradient(type) : null,
                  color: isSelected ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.border,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: _getTypeColor(type).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.getStoryTypeIcon(type),
                      color: isSelected ? Colors.white : _getTypeColor(type),
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      controller.getStoryTypeDisplayName(type),
                      style: TextStyles.labelMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.text,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildLinkField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Link Externo',
              style: TextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Opcional',
                style: TextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'Adicione um link para loja, tutorial ou mais informações',
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: controller.linkController,
          hint: 'https://exemplo.com',
          keyboardType: TextInputType.url,
          prefixIcon: Icons.link_rounded,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final uri = Uri.tryParse(value);
              if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                return 'URL inválida';
              }
              if (!['http', 'https'].contains(uri.scheme.toLowerCase())) {
                return 'URL deve começar com http:// ou https://';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return Obx(() => CustomButton(
      text: 'Publicar Story',
      onPressed: controller.canCreateStory ? controller.createStory : null,
      isLoading: controller.isCreating.value,
      isEnabled: controller.canCreateStory,
      icon: Icons.publish_rounded,
    ));
  }

  Color _getTypeColor(StoryType type) {
    switch (type) {
      case StoryType.tip:
        return AppColors.primary;
      case StoryType.outfit:
        return AppColors.secondary;
      case StoryType.accessory:
        return AppColors.accent;
      case StoryType.trend:
        return Colors.orange;
      case StoryType.discount:
        return Colors.green;
      case StoryType.tutorial:
        return Colors.blue;
    }
  }

  LinearGradient _getTypeGradient(StoryType type) {
    final color = _getTypeColor(type);
    return LinearGradient(
      colors: [
        color,
        color.withOpacity(0.8),
      ],
    );
  }
}
