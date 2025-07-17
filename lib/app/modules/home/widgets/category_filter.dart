import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';

class CategoryFilter extends StatefulWidget {
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
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter>
    with TickerProviderStateMixin {
  late AnimationController _selectionController;
  late Animation<double> _selectionAnimation;

  @override
  void initState() {
    super.initState();
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h, // Reduzido ainda mais
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
        itemCount: widget.categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 6.w),
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          return Obx(() => _buildCategoryChip(category, index));
        },
      ),
    );
  }

  Widget _buildCategoryChip(String category, int index) {
    final isSelected = widget.selectedCategory.value == category;
    final isAll = category == 'Todos';
    final categoryData = _getCategoryData(category);

    return GestureDetector(
      onTap: () {
        widget.onCategorySelected(category);
        if (isSelected) {
          _selectionController.forward();
        } else {
          _selectionController.reset();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        height: 36.h, // Altura muito reduzida
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14.w : 12.w,
          vertical: 6.h, // Padding vertical mínimo
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [
              categoryData['color'],
              categoryData['color'].withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(20.r), // Reduzido ainda mais
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.border.withOpacity(0.3),
            width: isSelected ? 0 : 1.5,
          ),
          boxShadow: [
            if (isSelected) ...[
              BoxShadow(
                color: categoryData['color'].withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: categoryData['color'].withOpacity(0.15),
                blurRadius: 32,
                offset: const Offset(0, 12),
                spreadRadius: 4,
              ),
            ] else ...[
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isSelected ? 20.w : 18.w, // Muito reduzido
              height: isSelected ? 20.h : 18.h, // Muito reduzido
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.95)
                    : categoryData['color'].withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ] : null,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected
                      ? categoryData['activeIcon']
                      : categoryData['icon'],
                  key: ValueKey('${category}_${isSelected}'),
                  size: isSelected ? 12.sp : 10.sp, // Muito reduzido
                  color: isSelected
                      ? categoryData['color']
                      : categoryData['color'].withOpacity(0.8),
                ),
              ),
            ),

            SizedBox(width: 6.w), // Reduzido

            // Text
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyles.labelSmall.copyWith( // Mudado para labelSmall
                color: isSelected ? Colors.white : AppColors.text,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: isSelected ? 11.sp : 10.sp, // Muito reduzido
                letterSpacing: 0.1,
              ),
              child: Text(category),
            ),

            // Active indicator
            if (isSelected) ...[
              SizedBox(width: 4.w), // Muito reduzido
              AnimatedBuilder(
                animation: _selectionAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _selectionAnimation.value,
                    child: Container(
                      width: 4.w, // Muito reduzido
                      height: 4.h, // Muito reduzido
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 2,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryData(String category) {
    switch (category) {
      case 'Todos':
        return {
          'color': AppColors.primary,
          'icon': Icons.grid_view_rounded,
          'activeIcon': Icons.grid_view,
        };
      case 'Trabalho':
        return {
          'color': const Color(0xFF2196F3),
          'icon': Icons.work_outline_rounded,
          'activeIcon': Icons.work_rounded,
        };
      case 'Festa':
        return {
          'color': const Color(0xFF9C27B0),
          'icon': Icons.celebration_outlined,
          'activeIcon': Icons.celebration_rounded,
        };
      case 'Casual':
        return {
          'color': const Color(0xFF4CAF50),
          'icon': Icons.weekend_outlined,
          'activeIcon': Icons.weekend_rounded,
        };
      case 'Encontro':
        return {
          'color': const Color(0xFFE91E63),
          'icon': Icons.favorite_outline_rounded,
          'activeIcon': Icons.favorite_rounded,
        };
      case 'Formatura':
        return {
          'color': const Color(0xFF3F51B5),
          'icon': Icons.school_outlined,
          'activeIcon': Icons.school_rounded,
        };
      case 'Casamento':
        return {
          'color': const Color(0xFFFF9800),
          'icon': Icons.church_outlined,
          'activeIcon': Icons.church_rounded,
        };
      case 'Academia':
        return {
          'color': const Color(0xFFF44336),
          'icon': Icons.fitness_center_outlined,
          'activeIcon': Icons.fitness_center_rounded,
        };
      case 'Viagem':
        return {
          'color': const Color(0xFF009688),
          'icon': Icons.flight_outlined,
          'activeIcon': Icons.flight_rounded,
        };
      case 'Balada':
        return {
          'color': const Color(0xFF673AB7),
          'icon': Icons.nightlife_outlined,
          'activeIcon': Icons.nightlife_rounded,
        };
      case 'Praia':
        return {
          'color': const Color(0xFF00BCD4),
          'icon': Icons.beach_access_outlined,
          'activeIcon': Icons.beach_access_rounded,
        };
      case 'Shopping':
        return {
          'color': const Color(0xFFFFC107),
          'icon': Icons.shopping_bag_outlined,
          'activeIcon': Icons.shopping_bag_rounded,
        };
      case 'Outros':
        return {
          'color': const Color(0xFF9E9E9E),
          'icon': Icons.more_horiz_outlined,
          'activeIcon': Icons.more_horiz_rounded,
        };
      default:
        return {
          'color': AppColors.primary,
          'icon': Icons.style_outlined,
          'activeIcon': Icons.style_rounded,
        };
    }
  }
}
