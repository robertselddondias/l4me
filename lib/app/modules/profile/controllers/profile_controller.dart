import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:look4me/app/data/models/post_model.dart';
import 'package:look4me/app/data/models/user_model.dart';
import 'package:look4me/app/data/repositories/post_repository.dart';
import 'package:look4me/app/data/repositories/user_repository.dart';
import 'package:look4me/app/data/services/firebase_service.dart';
import 'package:look4me/app/data/services/storage_service.dart';
import 'package:look4me/app/routes/app_routes.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  final PostRepository _postRepository = PostRepository();
  final StorageService _storageService = StorageService();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingPosts = false.obs;
  final RxBool isUpdatingProfile = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<PostModel> userPosts = <PostModel>[].obs;
  final RxInt selectedTabIndex = 0.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final GlobalKey<FormState> editFormKey = GlobalKey<FormState>();

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadCurrentUser();
    loadUserPosts();
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    super.onClose();
  }

  Future<void> loadCurrentUser() async {
    try {
      isLoading.value = true;
      final firebaseUser = FirebaseService.currentUser;

      if (firebaseUser != null) {
        final user = await _userRepository.getUserById(firebaseUser.uid);
        if (user != null) {
          currentUser.value = user;
          nameController.text = user.name;
          bioController.text = user.bio ?? '';
        }
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao carregar perfil: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserPosts() async {
    try {
      isLoadingPosts.value = true;
      final firebaseUser = FirebaseService.currentUser;

      if (firebaseUser != null) {
        final posts = await _postRepository.getUserPosts(firebaseUser.uid);
        userPosts.assignAll(posts);
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao carregar posts: $e');
    } finally {
      isLoadingPosts.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await Future.wait([
      loadCurrentUser(),
      loadUserPosts(),
    ]);
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  Future<void> pickProfileImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        await _uploadProfileImage(pickedFile.path);
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao selecionar imagem: $e');
    }
  }

  Future<void> _uploadProfileImage(String imagePath) async {
    try {
      isUpdatingProfile.value = true;
      final firebaseUser = FirebaseService.currentUser;

      if (firebaseUser == null) return;

      final imageUrl = await _storageService.uploadProfileImage(
        userId: firebaseUser.uid,
        imagePath: imagePath,
      );

      await _userRepository.updateProfileImage(firebaseUser.uid, imageUrl);

      if (currentUser.value != null) {
        currentUser.value = currentUser.value!.copyWith(
          profileImage: imageUrl,
        );
      }

      Get.snackbar('Sucesso', 'Foto atualizada com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao atualizar foto: $e');
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (!editFormKey.currentState!.validate()) return;

    try {
      isUpdatingProfile.value = true;
      final firebaseUser = FirebaseService.currentUser;

      if (firebaseUser == null || currentUser.value == null) return;

      final updatedUser = currentUser.value!.copyWith(
        name: nameController.text.trim(),
        bio: bioController.text.trim(),
      );

      await _userRepository.updateUser(updatedUser);
      currentUser.value = updatedUser;

      Get.back();
      Get.snackbar('Sucesso', 'Perfil atualizado com sucesso!');
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao atualizar perfil: $e');
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  void goToEditProfile() {
    Get.toNamed(AppRoutes.EDIT_PROFILE);
  }

  void goToSettings() {
    Get.toNamed(AppRoutes.SETTINGS);
  }

  Future<void> signOut() async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Sair da conta'),
          content: const Text('Tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Sair'),
            ),
          ],
        ),
      );

      if (result == true) {
        isLoading.value = true;
        await FirebaseService.auth.signOut();
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao sair: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Deletar post'),
          content: const Text('Tem certeza que deseja deletar este post?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Deletar'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      );

      if (result == true) {
        await _postRepository.deletePost(postId);
        userPosts.removeWhere((post) => post.id == postId);

        if (currentUser.value != null) {
          await _userRepository.decrementPostsCount(currentUser.value!.id);
          currentUser.value = currentUser.value!.copyWith(
            postsCount: currentUser.value!.postsCount - 1,
          );
        }

        Get.snackbar('Sucesso', 'Post deletado com sucesso!');
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao deletar post: $e');
    }
  }

  String getJoinDate() {
    if (currentUser.value == null) return '';

    final date = currentUser.value!.createdAt;
    final months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];

    return 'Entrou em ${months[date.month - 1]} ${date.year}';
  }
}
