import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';

class ImagePickerWidget extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final String? hint;
  final bool isRequired;
  final double? height;
  final double? width;

  const ImagePickerWidget({
    Key? key,
    required this.imagePath,
    required this.label,
    required this.onTap,
    this.hint,
    this.isRequired = false,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 200.h,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: imagePath.isEmpty ? AppColors.surfaceVariant : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: imagePath.isEmpty ? AppColors.border : AppColors.primary,
            width: imagePath.isEmpty ? 1 : 2,
          ),
          boxShadow: imagePath.isNotEmpty ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: imagePath.isEmpty ? _buildEmptyState() : _buildImagePreview(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.add_a_photo_outlined,
            color: AppColors.primary,
            size: 28.sp,
          ),
        ),
        SizedBox(height: 16.h),
        // CORREÇÃO: Envolver o Text(label) em Expanded para evitar overflow
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w), // Adicione um padding para evitar texto muito próximo das bordas
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded( // Permite que a label ocupe o espaço restante
                child: Text(
                  label,
                  style: TextStyles.titleSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center, // Centraliza o texto expandido
                  overflow: TextOverflow.ellipsis, // Adiciona reticências se o texto for muito longo
                  maxLines: 1, // Limita a 1 linha
                ),
              ),
              if (isRequired) ...[
                SizedBox(width: 4.w),
                Text(
                  '*',
                  style: TextStyles.titleSmall.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w), // Padding para o hint também
          child: Text(
            hint ?? 'Toque para adicionar foto',
            style: TextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, // Garante que o hint não transborde
            maxLines: 1,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Mantém a Row compacta
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 14.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 4.w),
              Flexible( // CORREÇÃO: Permite que 'Câmera' encolha se necessário
                child: Text(
                  'Câmera',
                  style: TextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 1,
                height: 12.h,
                color: AppColors.primary.withOpacity(0.3),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.photo_library_outlined,
                size: 14.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 4.w),
              Flexible( // CORREÇÃO: Permite que 'Galeria' encolha se necessário
                child: Text(
                  'Galeria',
                  style: TextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Image.file(
            File(imagePath),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorState();
            },
          ),
        ),

        // Overlay gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.6),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // Label
        Positioned(
          top: 12.h,
          left: 12.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              label,
              style: TextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis, // Garante que a label não transborde
              maxLines: 1,
            ),
          ),
        ),

        // Edit button
        Positioned(
          top: 12.h,
          right: 12.w,
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

        // Success indicator
        Positioned(
          bottom: 12.h,
          right: 12.w,
          child: Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
        ),

        // Tap to change hint
        Positioned(
          bottom: 12.h,
          left: 12.w,
          right: 12.w, // Adicionei right para garantir que a Row se ajuste
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Mantém a Row compacta
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: Colors.white,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Expanded( // CORREÇÃO: Permite que 'Toque para alterar' encolha
                  child: Text(
                    'Toque para alterar',
                    style: TextStyles.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis, // Adiciona reticências se o texto for muito longo
                    maxLines: 1, // Limita a 1 linha
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 32.sp,
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Erro ao carregar imagem',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          SizedBox(height: 4.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Toque para tentar novamente',
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
