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
    final occasionColor = _getOccasionColorByName(category);

    return GestureDetector(
      onTap: () => onCategorySelected(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [occasionColor, occasionColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : occasionColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? occasionColor.withOpacity(0.4)
                  : occasionColor.withOpacity(0.1),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCategoryIcon(category, isSelected, occasionColor),
            SizedBox(width: 6.w),
            Text(
              category,
              style: TextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : occasionColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category, bool isSelected, Color occasionColor) {
    IconData iconData = _getOccasionIconByName(category);

    return Container(
      width: 22.w,
      height: 22.h,
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withOpacity(0.2)
            : occasionColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        iconData,
        size: 14.sp,
        color: isSelected ? Colors.white : occasionColor,
      ),
    );
  }

  // MAPEAMENTO DE CORES POR NOME DA CATEGORIA
  Color _getOccasionColorByName(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'todos':
        return AppColors.primary;
      case 'trabalho':
        return Colors.blue;
      case 'festa':
        return Colors.purple;
      case 'casual':
        return Colors.green;
      case 'encontro':
        return Colors.pink;
      case 'formatura':
        return Colors.indigo;
      case 'casamento':
        return Colors.orange;
      case 'academia':
        return Colors.red;
      case 'viagem':
        return Colors.teal;
      case 'balada':
        return Colors.deepPurple;
      case 'praia':
        return Colors.cyan;
      case 'shopping':
        return Colors.amber;
      case 'outros':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  // MAPEAMENTO DE ÍCONES POR NOME DA CATEGORIA
  IconData _getOccasionIconByName(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'todos':
        return Icons.apps_rounded;
      case 'trabalho':
        return Icons.work;
      case 'festa':
        return Icons.celebration;
      case 'casual':
        return Icons.weekend;
      case 'encontro':
        return Icons.favorite;
      case 'formatura':
        return Icons.school;
      case 'casamento':
        return Icons.church;
      case 'academia':
        return Icons.fitness_center;
      case 'viagem':
        return Icons.flight;
      case 'balada':
        return Icons.nightlife;
      case 'praia':
        return Icons.beach_access;
      case 'shopping':
        return Icons.shopping_bag;
      case 'outros':
        return Icons.more_horiz;
      default:
        return Icons.style;
    }
  }
}
