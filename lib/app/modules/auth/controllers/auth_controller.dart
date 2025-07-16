import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString verificationId = ''.obs;
  final RxInt resendToken = 0.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> phoneFormKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> signInWithEmail() async {
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final userCredential = await _authRepository.signInWithEmail(
        emailController.text.trim(),
        passwordController.text,
      );

      if (userCredential.user != null) {
        await _navigateToHome();
      }
    } catch (e) {
      _showErrorSnackbar('Erro ao fazer login', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithEmail() async {
    if (!registerFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final userCredential = await _authRepository.signUpWithEmail(
        emailController.text.trim(),
        passwordController.text,
      );

      if (userCredential.user != null) {
        await _createUserProfile(userCredential.user!);
        await _navigateToHome();
      }
    } catch (e) {
      _showErrorSnackbar('Erro ao criar conta', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final userCredential = await _authRepository.signInWithGoogle();

      if (userCredential.user != null) {
        final userExists = await _userRepository.userExists(
            userCredential.user!.uid);

        if (!userExists) {
          await _createUserProfile(userCredential.user!);
        }

        await _navigateToHome();
      }
    } catch (e) {
      _showErrorSnackbar('Erro ao fazer login com Google', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    try {
      isLoading.value = true;

      final userCredential = await _authRepository.signInWithApple();

      if (userCredential.user != null) {
        final userExists = await _userRepository.userExists(
            userCredential.user!.uid);

        if (!userExists) {
          await _createUserProfile(userCredential.user!);
        }

        await _navigateToHome();
      }
    } catch (e) {
      _showErrorSnackbar('Erro ao fazer login com Apple', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPhoneVerification() async {
    if (!phoneFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      await _authRepository.verifyPhoneNumber(
        phoneController.text.trim(),
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId.value = verificationId;
          this.resendToken.value = resendToken ?? 0;
          Get.snackbar(
            'Código enviado',
            'Verifique seu SMS',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          _showErrorSnackbar(
              'Erro na verificação', e.message ?? 'Erro desconhecido');
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP() async {
    if (otpController.text.length != 6) {
      _showErrorSnackbar('Código inválido', 'Digite o código de 6 dígitos');
      return;
    }

    try {
      isLoading.value = true;

      final userCredential = await _authRepository.signInWithPhoneCredential(
        verificationId.value,
        otpController.text.trim(),
      );

      if (userCredential.user != null) {
        final userExists = await _userRepository.userExists(
            userCredential.user!.uid);

        if (!userExists) {
          await _createUserProfile(userCredential.user!);
        }

        await _navigateToHome();
      }
    } catch (e) {
      _showErrorSnackbar('Erro na verificação', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      _showErrorSnackbar('Erro ao sair', e.toString());
    }
  }

  Future<void> resetPassword() async {
    if (emailController.text.isEmpty) {
      _showErrorSnackbar(
          'Email obrigatório', 'Digite seu email para recuperar a senha');
      return;
    }

    try {
      isLoading.value = true;

      await _authRepository.resetPassword(emailController.text.trim());

      Get.snackbar(
        'Email enviado',
        'Verifique sua caixa de entrada',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      _showErrorSnackbar('Erro ao enviar email', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createUserProfile(User user) async {
    final userModel = UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: nameController.text.isNotEmpty
          ? nameController.text.trim()
          : user.displayName ?? 'Usuária',
      profileImage: user.photoURL,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      phoneNumber: user.phoneNumber,
    );

    await _userRepository.createUser(userModel);
  }

  Future<void> _navigateToHome() async {
    Get.offAllNamed(AppRoutes.MAIN_NAVIGATION);
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    phoneController.clear();
    otpController.clear();
  }
}
