import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/modules/profile/controllers/profile_controller.dart';
import 'package:look4me/app/shared/components/custom_button.dart';
import 'package:look4me/app/shared/components/custom_text_field.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({Key? key}) : super(key: key);

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
                  key: controller.editFormKey,
                  child: Column(
                    children: [
                      _buildProfileImageSection(),
                      SizedBox(height: 32.h),
                      _buildPersonalInfoSection(),
                      SizedBox(height: 24.h),
                      _buildInterestsSection(),
                      SizedBox(height: 32.h),
                      _buildActionButtons(),
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
                Icons.arrow_back_rounded,
                color: AppColors.text,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Editar Perfil',
              style: TextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Obx(() => controller.isUpdatingProfile.value
              ? SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          )
              : Icon(
            Icons.edit_rounded,
            color: AppColors.primary,
            size: 20.sp,
          )),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        Text(
          'Foto de Perfil',
          style: TextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Toque na foto para alterar',
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 24.h),
        Obx(() => _buildProfileImageWidget()),
      ],
    );
  }

  Widget _buildProfileImageWidget() {
    final user = controller.currentUser.value;
    final isUpdating = controller.isUpdatingProfile.value;

    return GestureDetector(
      onTap: isUpdating ? null : controller.pickProfileImage,
      child: Stack(
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: user?.profileImage != null
                  ? CachedNetworkImage(
                imageUrl: user!.profileImage!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.primaryLight,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildDefaultAvatar(),
              )
                  : _buildDefaultAvatar(),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                gradient: isUpdating
                    ? LinearGradient(colors: [AppColors.textTertiary, AppColors.textTertiary])
                    : AppColors.primaryGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surface,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isUpdating
                  ? Padding(
                padding: EdgeInsets.all(10.w),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.surface,
                  ),
                ),
              )
                  : Icon(
                Icons.camera_alt_rounded,
                color: AppColors.onPrimary,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.onPrimary,
        size: 60.sp,
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Informações Pessoais',
                style: TextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            controller: controller.nameController,
            label: 'Nome',
            hint: 'Digite seu nome completo',
            prefixIcon: Icons.badge_outlined,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Nome é obrigatório';
              }
              if (value!.length < 2) {
                return 'Nome deve ter pelo menos 2 caracteres';
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          CustomTextField(
            controller: controller.bioController,
            label: 'Bio',
            hint: 'Conte um pouco sobre você...',
            prefixIcon: Icons.edit_note_rounded,
            maxLines: 3,
            maxLength: 150,
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value != null && value.length > 150) {
                return 'Bio deve ter no máximo 150 caracteres';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    final availableInterests = [
      'Moda',
      'Beleza',
      'Casual',
      'Formal',
      'Vintage',
      'Streetwear',
      'Minimalista',
      'Colorido',
      'Acessórios',
      'Sapatos',
      'Bolsas',
      'Joias',
    ];

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_outline_rounded,
                color: AppColors.secondary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Interesses',
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12.r),
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
            'Selecione até 5 interesses para personalizar sua experiência',
            style: TextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            final userInterests = controller.currentUser.value?.interests ?? [];
            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: availableInterests.map((interest) {
                final isSelected = userInterests.contains(interest);
                return GestureDetector(
                  onTap: () => _toggleInterest(interest),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                        colors: [AppColors.secondary, AppColors.accent],
                      )
                          : null,
                      color: isSelected ? null : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.border,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Text(
                      interest,
                      style: TextStyles.labelMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.text,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
          SizedBox(height: 12.h),
          Obx(() {
            final selectedCount = controller.currentUser.value?.interests.length ?? 0;
            return Text(
              '$selectedCount/5 interesses selecionados',
              style: TextStyles.bodySmall.copyWith(
                color: selectedCount >= 5 ? AppColors.error : AppColors.textTertiary,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Obx(() => CustomButton(
          text: 'Salvar Alterações',
          onPressed: controller.updateProfile,
          isLoading: controller.isUpdatingProfile.value,
          icon: Icons.check_rounded,
        )),
        SizedBox(height: 12.h),
        CustomButton(
          text: 'Cancelar',
          onPressed: () => Get.back(),
          type: ButtonType.outlined,
          icon: Icons.close_rounded,
        ),
      ],
    );
  }

  void _toggleInterest(String interest) {
    final user = controller.currentUser.value;
    if (user == null) return;

    final currentInterests = List<String>.from(user.interests);

    if (currentInterests.contains(interest)) {
      currentInterests.remove(interest);
    } else {
      if (currentInterests.length < 5) {
        currentInterests.add(interest);
      } else {
        Get.snackbar(
          'Limite atingido',
          'Você pode selecionar no máximo 5 interesses',
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }
    }

    controller.currentUser.value = user.copyWith(interests: currentInterests);
  }
}
