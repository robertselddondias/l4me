import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/modules/create_post/views/create_post_view.dart';
import 'package:look4me/app/modules/home/views/home_view.dart';
import 'package:look4me/app/modules/navigation/controllers/navigation_controller.dart';
import 'package:look4me/app/modules/profile/views/profile_view.dart';
import 'package:look4me/app/modules/search/views/search_users_view.dart';
import 'package:look4me/app/modules/explore/views/explore_view.dart';

class MainNavigation extends GetView<NavigationController> {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _buildBody()),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody() {
    switch (controller.currentIndex.value) {
      case 0:
        return const HomeView();
      case 1:
        return const SearchUsersView();
      case 2:
        return const CreatePostView();
      case 3:
        return const ExploreView();
      case 4:
        return const ProfileView();
      default:
        return const HomeView();
    }
  }

  Widget _buildBottomNavigationBar() {
    return Obx(
          () => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: AppColors.surface,
          elevation: 0,
          height: 65, // ALTURA FIXA EM PIXELS - NÃO RESPONSIVA
          child: Container(
            height: 65, // DUPLICAR A ALTURA PARA GARANTIR
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Início',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search_rounded,
                  label: 'Buscar',
                  index: 1,
                ),
                const SizedBox(width: 48), // ESPAÇO FIXO PARA FAB
                _buildNavItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                  label: 'Explorar',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person_rounded,
                  label: 'Perfil',
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = controller.currentIndex.value == index;

    return Expanded(
      child: InkWell(
        onTap: () => controller.changePage(index),
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 45, // ALTURA ABSOLUTA - GARANTE QUE CABE
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ÍCONE - VALORES ABSOLUTOS
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                  size: 20, // TAMANHO FIXO
                ),
              ),

              // ESPAÇAMENTO MÍNIMO
              const SizedBox(height: 1),

              // LABEL - SEM OVERFLOW POSSÍVEL
              SizedBox(
                width: 50, // LARGURA FIXA
                height: 12, // ALTURA FIXA
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? AppColors.primary : AppColors.textTertiary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 9, // TAMANHO FIXO
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 56, // TAMANHO FIXO
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => controller.changePage(2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        heroTag: "create_post_fab",
        child: Obx(
              () => AnimatedRotation(
            turns: controller.currentIndex.value == 2 ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.add_rounded,
              color: AppColors.onPrimary,
              size: 24, // TAMANHO FIXO
            ),
          ),
        ),
      ),
    );
  }
}
