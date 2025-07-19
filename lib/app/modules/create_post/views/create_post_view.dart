import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/modules/create_post/controllers/create_post_controller.dart';
import 'package:look4me/app/shared/components/custom_button.dart';
import 'package:look4me/app/shared/components/custom_text_field.dart';
import 'package:look4me/app/data/models/post_model.dart';

class CreatePostView extends GetView<CreatePostController> {
  const CreatePostView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.close, color: AppColors.text, size: 24.sp),
          ),
          title: Text(
            'Criar Look',
            style: TextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          actions: [
            Obx(() => TextButton(
              onPressed: controller.isLoading.value
                  ? null // TRAVA o botão quando está carregando
                  : (controller.canCreatePost ? () => _handleCreatePost() : null),
              child: controller.isLoading.value
                  ? SizedBox(
                width: 16.w,
                height: 16.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textTertiary),
                ),
              )
                  : Text(
                'Publicar',
                style: TextStyle(
                  color: controller.canCreatePost ? AppColors.primary : AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
            )),
          ],
        ),
        body: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pergunta direta
                Text(
                  'Qual dessas opções fica melhor?',
                  style: TextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),

                SizedBox(height: 24.h),

                // Duas fotos lado a lado
                Row(
                  children: [
                    Expanded(child: Obx(() => _buildImagePicker(1))),
                    Container(
                      width: 40.w,
                      alignment: Alignment.center,
                      child: Text(
                        'VS',
                        style: TextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Expanded(child: Obx(() => _buildImagePicker(2))),
                  ],
                ),

                SizedBox(height: 32.h),

                // Descrição
                CustomTextField(
                  controller: controller.descriptionController,
                  hint: 'Conte um pouco sobre a situação...',
                  maxLines: 2,
                  maxLength: 120,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Descreva a situação';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24.h),

                // Ocasião melhorada - Como cards horizontais
                Text(
                  'Para que ocasião?',
                  style: TextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildOccasionCards(),

                SizedBox(height: 24.h),

                // Tags expandidas
                Text(
                  'Tags (opcional):',
                  style: TextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildExpandedTags(),

                SizedBox(height: 40.h),

                // Botão publicar com debug
                Obx(() => _buildPublishButton()),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método com debug para criar post
  Future<void> _handleCreatePost() async {
    // Evita execução múltipla
    if (controller.isLoading.value) {
      print('⚠️ Já está criando post, ignorando novo clique');
      return;
    }

    print('🚀 Iniciando criação do post...');
    print('📸 Imagem 1: ${controller.image1Path.value}');
    print('📸 Imagem 2: ${controller.image2Path.value}');
    print('📝 Descrição: ${controller.descriptionController.text}');
    print('🎯 Ocasião: ${controller.selectedOccasion.value.name}');
    print('🏷️ Tags: ${controller.selectedTags.toList()}');

    try {
      await controller.createPost();
      print('✅ Post criado com sucesso!');
    } catch (e) {
      print('❌ Erro ao criar post: $e');
      Get.snackbar(
        'Erro',
        'Falha ao criar post: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Seletor de ocasião como cards
  Widget _buildOccasionCards() {
    final occasions = [
      {'occasion': PostOccasion.casual, 'icon': Icons.weekend, 'label': 'Casual'},
      {'occasion': PostOccasion.trabalho, 'icon': Icons.work, 'label': 'Trabalho'},
      {'occasion': PostOccasion.festa, 'icon': Icons.celebration, 'label': 'Festa'},
      {'occasion': PostOccasion.encontro, 'icon': Icons.favorite, 'label': 'Encontro'},
      {'occasion': PostOccasion.academia, 'icon': Icons.fitness_center, 'label': 'Academia'},
      {'occasion': PostOccasion.viagem, 'icon': Icons.flight, 'label': 'Viagem'},
      {'occasion': PostOccasion.casamento, 'icon': Icons.church, 'label': 'Casamento'},
      {'occasion': PostOccasion.formatura, 'icon': Icons.school, 'label': 'Formatura'},
    ];

    return Container(
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: occasions.length,
        itemBuilder: (context, index) {
          final item = occasions[index];
          final occasion = item['occasion'] as PostOccasion;
          final icon = item['icon'] as IconData;
          final label = item['label'] as String;

          return Obx(() {
            final isSelected = controller.selectedOccasion.value == occasion;

            return GestureDetector(
              onTap: () => controller.selectOccasion(occasion),
              child: Container(
                width: 80.w,
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      color: isSelected ? Colors.white : AppColors.primary,
                      size: 24.sp,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      label,
                      style: TextStyles.bodySmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.text,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // Tags expandidas e organizadas
  Widget _buildExpandedTags() {
    final tagCategories = {
      'Estilo': ['casual', 'elegante', 'chique', 'básico', 'moderno', 'vintage', 'boho'],
      'Cores': ['colorido', 'neutro', 'preto', 'branco', 'rosa', 'azul', 'vermelho'],
      'Estação': ['verão', 'inverno', 'outono', 'primavera', 'frio', 'calor'],
      'Vibe': ['confortável', 'fashion', 'statement', 'minimalista', 'romântico', 'rock'],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categorias de tags
        ...tagCategories.entries.map((category) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.key,
                style: TextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: category.value.map((tag) {
                  return Obx(() {
                    final isSelected = controller.selectedTags.contains(tag);
                    return GestureDetector(
                      onTap: () => controller.toggleTag(tag),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16.r),
                          border: isSelected ? null : Border.all(
                            color: AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyles.bodySmall.copyWith(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
              SizedBox(height: 12.h),
            ],
          );
        }).toList(),

        // Contador de tags selecionadas
        Obx(() {
          if (controller.selectedTags.isEmpty) return SizedBox.shrink();

          return Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '${controller.selectedTags.length}/5 tags selecionadas: ${controller.selectedTags.join(", ")}',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildImagePicker(int option) {
    final imagePath = option == 1
        ? controller.image1Path.value
        : controller.image2Path.value;
    final isEmpty = imagePath.isEmpty;

    return GestureDetector(
      onTap: () => controller.showImageSourceDialog(option),
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          color: isEmpty ? AppColors.surfaceVariant : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isEmpty ? AppColors.border : AppColors.primary,
            width: isEmpty ? 1 : 2,
          ),
        ),
        child: isEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 8.h),
            Text(
              'Opção ${option}',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        )
            : Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceVariant,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 32.sp,
                      color: AppColors.textTertiary,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: GestureDetector(
                onTap: () => controller.removeImage(option),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: controller.isLoading.value
            ? null // TRAVA o botão quando está carregando
            : (controller.canCreatePost ? () => _handleCreatePost() : null),
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.isLoading.value
              ? AppColors.surfaceVariant
              : AppColors.primary,
          disabledBackgroundColor: AppColors.surfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: (controller.canCreatePost && !controller.isLoading.value) ? 2 : 0,
        ),
        child: controller.isLoading.value
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Publicando...',
              style: TextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.publish_rounded,
              color: controller.canCreatePost ? Colors.white : AppColors.textTertiary,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Publicar Look',
              style: TextStyles.titleMedium.copyWith(
                color: controller.canCreatePost ? Colors.white : AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
