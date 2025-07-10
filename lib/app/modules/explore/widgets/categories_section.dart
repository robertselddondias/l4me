import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/themes/text_styles.dart';
import '../controllers/explore_controller.dart';

class CategoriesSection extends GetView<ExploreController> {
  const CategoriesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categorias',
                style: TextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => controller.viewAllTrendingPosts(),
                child: Text(
                  'Ver todos',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _buildCategoriesGrid(),
      ],
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = [
      {
        'name': 'Trabalho',
        'icon': Icons.work_outline_rounded,
        'color': Colors.blue,
        'gradient': [Colors.blue.shade400, Colors.blue.shade600],
      },
      {
        'name': 'Festa',
        'icon': Icons.celebration_outlined,
        'color': Colors.purple,
        'gradient': [Colors.purple.shade400, Colors.purple.shade600],
      },
      {
        'name': 'Casual',
        'icon': Icons.weekend_outlined,
        'color': Colors.green,
        'gradient': [Colors.green.shade400, Colors.green.shade600],
      },
      {
        'name': 'Encontro',
        'icon': Icons.favorite_outline_rounded,
        'color': Colors.pink,
        'gradient': [Colors.pink.shade400, Colors.pink.shade600],
      },
      {
        'name': 'Academia',
        'icon': Icons.fitness_center_outlined,
        'color': Colors.red,
        'gradient': [Colors.red.shade400, Colors.red.shade600],
      },
      {
        'name': 'Viagem',
        'icon': Icons.flight_outlined,
        'color': Colors.teal,
        'gradient': [Colors.teal.shade400, Colors.teal.shade600],
      },
    ];

    return SizedBox(
      height: 140.h, // Altura fixa menor
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9, // Ajustado para caber melhor
          mainAxisSpacing: 12.w,
          crossAxisSpacing: 8.h, // Reduzido
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () => controller.searchByCategory(category['name']),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: category['gradient'],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: category['color'].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () => controller.searchByCategory(category['name']),
            child: Container(
              padding: EdgeInsets.all(12.w), // Padding reduzido
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Importante para evitar overflow
                children: [
                  Icon(
                    category['icon'],
                    color: Colors.white,
                    size: 24.sp, // Ícone menor
                  ),
                  SizedBox(height: 6.h), // Espaçamento reduzido
                  Flexible( // Usar Flexible em vez de Text direto
                    child: Text(
                      category['name'],
                      style: TextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp, // Fonte menor
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
        ),
      ),
    );
  }
}
