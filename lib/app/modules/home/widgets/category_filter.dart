import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final RxString selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilter({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Obx(() => _buildCategoryChip(category));
        },
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = selectedCategory.value == category;

    return GestureDetector(
      onTap: () => onCategorySelected(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.border.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.shadow.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCategoryIcon(category, isSelected),
            SizedBox(width: 8.w),
            Text(
              category,
              style: TextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.onPrimary : AppColors.text,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category, bool isSelected) {
    IconData iconData;

    switch (category.toLowerCase()) {
      case 'casual':
        iconData = Icons.style_rounded;
        break;
      case 'trabalho':
        iconData = Icons.business_center_rounded;
        break;
      case 'festa':
        iconData = Icons.celebration_rounded;
        break;
      case 'esporte':
        iconData = Icons.sports_rounded;
        break;
      case 'praia':
        iconData = Icons.beach_access_rounded;
        break;
      case 'inverno':
        iconData = Icons.ac_unit_rounded;
        break;
      case 'verão':
        iconData = Icons.wb_sunny_rounded;
        break;
      case 'formal':
        iconData = Icons.diamond_rounded;
        break;
      case 'noturno':
        iconData = Icons.nightlife_rounded;
        break;
      default:
        iconData = Icons.checkroom_rounded;
    }

    return Container(
      width: 20.w,
      height: 20.h,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.onPrimary.withOpacity(0.2)
            : AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Icon(
        iconData,
        size: 12.sp,
        color: isSelected ? AppColors.onPrimary : AppColors.primary,
      ),
    );
  }
}
