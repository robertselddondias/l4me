import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/modules/explore/widgets/user_card.dart';
import 'package:look4me/app/modules/search/controllers/search_controller.dart';
import 'package:look4me/app/shared/components/custom_text_field.dart';
import 'package:look4me/app/shared/components/empty_state.dart';
import 'package:look4me/app/shared/components/loading_widget.dart';

class SearchUsersView extends GetView<SearchL4MController> {
  const SearchUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.onSecondary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buscar Usuárias',
                  style: TextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Encontre pessoas incríveis',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: CustomTextField(
        controller: controller.searchController,
        hint: 'Digite o nome da usuária...',
        prefixIcon: Icons.search_rounded,
        onChanged: controller.searchUsers,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const LoadingWidget(showShimmer: false);
      }

      if (controller.searchQuery.value.isEmpty) {
        return _buildRecentSearches();
      }

      if (controller.searchResults.isEmpty) {
        return const EmptyState(
          icon: Icons.person_search_outlined,
          title: 'Nenhuma usuária encontrada',
          subtitle: 'Tente buscar por outro nome ou verifique a ortografia',
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final user = controller.searchResults[index];
          return UserCard(
            user: user,
            onTap: () => controller.viewUserProfile(user.id),
            showFollowButton: true,
            onFollowToggle: () => controller.toggleFollowUser(user.id),
          );
        },
      );
    });
  }

  Widget _buildRecentSearches() {
    return Obx(() {
      if (controller.recentSearches.isEmpty) {
        return _buildEmptyRecentSearches();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Buscas Recentes',
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: controller.clearRecentSearches,
                  child: Text(
                    'Limpar',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: controller.recentSearches.length,
              itemBuilder: (context, index) {
                final user = controller.recentSearches[index];
                return UserCard(
                  user: user,
                  onTap: () => controller.viewUserProfile(user.id),
                  showRemoveButton: true,
                  onRemove: () => controller.removeFromRecentSearches(user.id),
                  showFollowButton: true,
                  onFollowToggle: () => controller.toggleFollowUser(user.id),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEmptyRecentSearches() {
    return Column(
      children: [
        SizedBox(height: 40.h),
        const EmptyState(
          icon: Icons.search_outlined,
          title: 'Comece a buscar',
          subtitle: 'Digite o nome de uma usuária para encontrar pessoas incríveis na comunidade Look4Me',
        ),
        SizedBox(height: 40.h),
        _buildSuggestedUsers(),
      ],
    );
  }

  Widget _buildSuggestedUsers() {
    return Obx(() {
      if (controller.isLoadingPopular.value) {
        return SizedBox(
          height: 200.h,
          child: const LoadingWidget(showShimmer: false),
        );
      }

      if (controller.popularUsers.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'Usuárias Sugeridas',
              style: TextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          ...controller.popularUsers.take(5).map((user) => Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: UserCard(
              user: user,
              onTap: () => controller.viewUserProfile(user.id),
              showFollowButton: true,
              onFollowToggle: () => controller.toggleFollowUser(user.id),
            ),
          )),
        ],
      );
    });
  }
}
