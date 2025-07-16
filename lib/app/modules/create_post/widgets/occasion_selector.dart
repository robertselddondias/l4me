import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/post_model.dart';

class OccasionSelector extends StatelessWidget {
  final List<PostOccasion> occasions;
  final PostOccasion selectedOccasion;
  final Function(PostOccasion) onOccasionSelected;

  const OccasionSelector({
    super.key,
    required this.occasions,
    required this.selectedOccasion,
    required this.onOccasionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3.5,
        crossAxisSpacing: 8.w,
        mainAxisSpacing: 8.h,
      ),
      itemCount: occasions.length,
      itemBuilder: (context, index) {
        final occasion = occasions[index];
        return _buildOccasionChip(occasion);
      },
    );
  }

  Widget _buildOccasionChip(PostOccasion occasion) {
    final isSelected = selectedOccasion == occasion;
    final displayName = _getOccasionDisplayName(occasion);
    final icon = _getOccasionIcon(occasion);

    return GestureDetector(
      onTap: () => onOccasionSelected(occasion),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36.h, // Altura fixa para evitar overflow
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : [
            const BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.onPrimary : AppColors.primary,
                size: 14.sp,
              ),
              SizedBox(width: 3.w),
              Flexible(
                child: Text(
                  displayName,
                  style: TextStyles.labelSmall.copyWith(
                    color: isSelected ? AppColors.onPrimary : AppColors.text,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 8.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getOccasionDisplayName(PostOccasion occasion) {
    switch (occasion) {
      case PostOccasion.trabalho:
        return 'Trabalho';
      case PostOccasion.festa:
        return 'Festa';
      case PostOccasion.casual:
        return 'Casual';
      case PostOccasion.encontro:
        return 'Encontro';
      case PostOccasion.formatura:
        return 'Formatura';
      case PostOccasion.casamento:
        return 'Casamento';
      case PostOccasion.academia:
        return 'Academia';
      case PostOccasion.viagem:
        return 'Viagem';
      case PostOccasion.balada:
        return 'Balada';
      case PostOccasion.praia:
        return 'Praia';
      case PostOccasion.shopping:
        return 'Shopping';
      case PostOccasion.outros:
        return 'Outros';
    }
  }

  IconData _getOccasionIcon(PostOccasion occasion) {
    switch (occasion) {
      case PostOccasion.trabalho:
        return Icons.work_outline;
      case PostOccasion.festa:
        return Icons.celebration_outlined;
      case PostOccasion.casual:
        return Icons.weekend_outlined;
      case PostOccasion.encontro:
        return Icons.favorite_outline;
      case PostOccasion.formatura:
        return Icons.school_outlined;
      case PostOccasion.casamento:
        return Icons.church_outlined;
      case PostOccasion.academia:
        return Icons.fitness_center_outlined;
      case PostOccasion.viagem:
        return Icons.flight_outlined;
      case PostOccasion.balada:
        return Icons.nightlife_outlined;
      case PostOccasion.praia:
        return Icons.beach_access_outlined;
      case PostOccasion.shopping:
        return Icons.shopping_bag_outlined;
      case PostOccasion.outros:
        return Icons.more_horiz_outlined;
    }
  }
}
