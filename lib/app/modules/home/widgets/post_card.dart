import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/post_model.dart';
import 'package:look4me/app/modules/home/controllers/home_controller.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool hasUserVoted;
  final int? userVote;
  final Function(int) onVote;
  final VoidCallback? onRemoveVote;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onFollow;
  final bool isFollowing;
  final bool isOwnPost;
  final bool isSaved;
  final Function(String)? onDeletePost;

  const PostCard({
    Key? key,
    required this.post,
    required this.hasUserVoted,
    this.userVote,
    required this.onVote,
    this.onRemoveVote,
    this.onSave,
    this.onShare,
    this.onFollow,
    this.isFollowing = false,
    this.isOwnPost = false,
    this.isSaved = false,
    this.onDeletePost,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with TickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late AnimationController _selectionAnimationController;
  late AnimationController _saveAnimationController;

  late Animation<double> _heartScaleAnimation;
  late Animation<double> _selectionAnimation;
  late Animation<double> _saveScaleAnimation;
  late Animation<Color?> _selectionColorAnimation;
  late Animation<double> _selectionBorderWidthAnimation;
  late Animation<Offset> _selectionOffsetAnimation;
  late Animation<double> _selectionBlurRadiusAnimation;

  int? _selectedOption;

  bool? _localIsSaved;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeState();
  }

  void _initializeAnimations() {
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _selectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _saveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _heartScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.elasticOut,
    ));

    _selectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _selectionAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    // Animation for selection border color
    _selectionColorAnimation = ColorTween(
      begin: AppColors.primary.withOpacity(0.0),
      end: AppColors.primary,
    ).animate(CurvedAnimation(
      parent: _selectionAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    // Animation for selection border width
    _selectionBorderWidthAnimation = Tween<double>(
      begin: 0.0,
      end: 3.0, // Thicker border for selected
    ).animate(CurvedAnimation(
      parent: _selectionAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    // Animation for selection shadow offset
    _selectionOffsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 4),
    ).animate(CurvedAnimation(
      parent: _selectionAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    // Animation for selection shadow blur radius
    _selectionBlurRadiusAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _selectionAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    _saveScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _saveAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  void _initializeState() {
    _selectedOption = widget.hasUserVoted ? widget.userVote : null;
    _localIsSaved = widget.isSaved;

    _heartAnimationController.reset();
    _selectionAnimationController.reset();

    if (widget.hasUserVoted && _selectedOption != null) {
      _selectionAnimationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool needsStateUpdate = false;

    if (oldWidget.hasUserVoted != widget.hasUserVoted) {
      needsStateUpdate = true;
    }

    if (oldWidget.userVote != widget.userVote) {
      needsStateUpdate = true;
    }

    if (oldWidget.post.id != widget.post.id) {
      needsStateUpdate = true;
    }

    // NOVO: Sincronizar estado local apenas se vier de fora
    if (oldWidget.isSaved != widget.isSaved && _localIsSaved == oldWidget.isSaved) {
      _localIsSaved = widget.isSaved;
      needsStateUpdate = true;
    }

    if (needsStateUpdate) {
      _initializeState();

      if (!oldWidget.hasUserVoted && widget.hasUserVoted) {
        _handleVoteSuccess();
      }

      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    _selectionAnimationController.dispose();
    _saveAnimationController.dispose();
    super.dispose();
  }

  void _handleVote(int option) {
    setState(() {
      _selectedOption = option;
    });

    _heartAnimationController.forward().then((_) {
      _heartAnimationController.reverse();
    });

    _selectionAnimationController.forward();

    widget.onVote(option);
  }

  void _handleVoteSuccess() {
    _selectionAnimationController.forward();
  }

  void _handleSave() {
    print('DEBUG: _handleSave chamado. Estado atual: $_localIsSaved');

    // Atualizar estado local IMEDIATAMENTE
    setState(() {
      _localIsSaved = !_localIsSaved!;
    });

    print('DEBUG: Novo estado local: $_localIsSaved');

    _saveAnimationController.forward().then((_) {
      _saveAnimationController.reverse();
    });

    widget.onSave?.call();
  }

  bool get _isCurrentlySaved {
    return _localIsSaved ?? widget.isSaved;
  }

  // MÉTODO PARA EXIBIR IMAGEM EM TELA CHEIA (JÁ EXISTENTE NO SEU CÓDIGO)
  void _showFullScreenImage(String imageUrl, int option) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.black,
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white,
                              size: 64.sp,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Erro ao carregar imagem',
                              style: TextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16.h,
              right: 16.w,
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16.h,
              left: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  'Opção $option',
                  style: TextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (!widget.hasUserVoted)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 24.h,
                left: 24.w,
                right: 24.w,
                child: Container(
                  width: double.infinity,
                  height: 48.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24.r),
                      onTap: () {
                        Get.back();
                        _handleVote(option);
                      },
                      child: Center(
                        child: Text(
                          'Votar na Opção $option',
                          style: TextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(), // Header limpo - só badge colorido
          _buildImagesSection(), // Imagens sem divisor da ocasião
          _buildActionBar(), // Action bar normal
          if (widget.post.description.isNotEmpty) _buildDescription(),
          if (widget.post.tags.isNotEmpty) _buildTags(), // Tags normais, sem ocasião
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      child: Row(
        children: [
          // Avatar com badge da ocasião
          Stack(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: widget.post.authorProfileImage != null &&
                    widget.post.authorProfileImage!.isNotEmpty
                    ? CachedNetworkImageProvider(widget.post.authorProfileImage!)
                    : null,
                child: widget.post.authorProfileImage == null ||
                    widget.post.authorProfileImage!.isEmpty
                    ? Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 22.sp,
                )
                    : null,
              ),
              // Badge da ocasião
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 18.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: _getOccasionColor(widget.post.occasion),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _getOccasionIcon(widget.post.occasion),
                    size: 10.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          // User info - CLEAN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.authorName,
                  style: TextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(width: 2.h),
                Text(
                  _getTimeAgoDetailed(widget.post.createdAt),
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          if (!widget.isOwnPost) ...[
            GetX<HomeController>(
              builder: (controller) {
                final isFollowing = controller.isFollowingUser(widget.post.authorId);

                if (isFollowing) {
                  return const SizedBox.shrink();
                }

                return Container(
                  height: 32.h,
                  child: ElevatedButton(
                    onPressed: widget.onFollow,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.zero,
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      'Seguir',
                      style: TextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 8.w),
          ],
          Container(
            width: 32.w,
            height: 32.h,
            child: _buildMenuButton(),
          ),
        ],
      ),
    );
  }

  IconData _getOccasionIcon(PostOccasion occasion) {
    switch (occasion) {
      case PostOccasion.trabalho:
        return Icons.work;
      case PostOccasion.festa:
        return Icons.celebration;
      case PostOccasion.casual:
        return Icons.weekend;
      case PostOccasion.encontro:
        return Icons.favorite;
      case PostOccasion.formatura:
        return Icons.school;
      case PostOccasion.casamento:
        return Icons.church;
      case PostOccasion.academia:
        return Icons.fitness_center;
      case PostOccasion.viagem:
        return Icons.flight;
      case PostOccasion.balada:
        return Icons.nightlife;
      case PostOccasion.praia:
        return Icons.beach_access;
      case PostOccasion.shopping:
        return Icons.shopping_bag;
      default:
        return Icons.circle;
    }
  }

  Widget _buildMenuButton() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'remove_vote':
            widget.onRemoveVote?.call();
            break;
          case 'unfollow':
            _showUnfollowConfirmation(Get.find<HomeController>());
            break;
          case 'report':
            _showReportDialog();
            break;
          case 'delete_post':
            _showDeletePostDialog();
            break;
        }
      },
      itemBuilder: (context) {
        List<PopupMenuEntry<String>> items = [];

        // Opção de excluir post (apenas para posts próprios)
        if (widget.isOwnPost) {
          items.add(
            const PopupMenuItem(
              value: 'delete_post',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Excluir post', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          );
        }

        // Opção de remover voto
        if (widget.hasUserVoted && widget.onRemoveVote != null) {
          items.add(
            const PopupMenuItem(
              value: 'remove_vote',
              child: Row(
                children: [
                  Icon(Icons.remove_circle_outline, color: AppColors.warning),
                  SizedBox(width: 12),
                  Text('Remover meu voto'),
                ],
              ),
            ),
          );
        }

        // Opção de deixar de seguir
        if (!widget.isOwnPost && widget.isFollowing) {
          items.add(
            const PopupMenuItem(
              value: 'unfollow',
              child: Row(
                children: [
                  Icon(Icons.person_remove_outlined, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Deixar de seguir'),
                ],
              ),
            ),
          );
        }

        // Opção de reportar
        if (!widget.isOwnPost) {
          items.add(
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report_outlined, color: AppColors.error),
                  SizedBox(width: 12),
                  Text('Reportar post'),
                ],
              ),
            ),
          );
        }

        if (items.isEmpty) {
          items.add(
            const PopupMenuItem(
              enabled: false,
              value: 'no_options',
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textTertiary),
                  SizedBox(width: 12),
                  Text('Nenhuma ação disponível',
                      style: TextStyle(color: AppColors.textTertiary)),
                ],
              ),
            ),
          );
        }

        return items;
      },
      child: Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(
          Icons.more_horiz_rounded,
          color: AppColors.textSecondary,
          size: 18.sp,
        ),
      ),
    );
  }

  void _showDeletePostDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_outlined, color: AppColors.error, size: 24.sp),
            SizedBox(width: 8.w),
            Text('Excluir Post'),
          ],
        ),
        content: Text(
          'Esta ação não pode ser desfeita. O post será excluído permanentemente.',
          style: TextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => _executeDeletePost(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeDeletePost() async {
    // Fecha o diálogo de confirmação
    Get.back();

    // Controle de loading
    bool isLoadingActive = true;

    // Mostra loading simples com timeout
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              SizedBox(height: 16.h),
              Text(
                'Excluindo post...',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Timeout de segurança (15 segundos)
    final timeoutTimer = Timer(Duration(seconds: 15), () {
      if (isLoadingActive) {
        isLoadingActive = false;
        if (Get.isDialogOpen == true) {
          Get.back(); // Fecha loading
        }
        Get.snackbar(
          'Timeout',
          'A operação demorou muito. Tente novamente.',
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });

    try {
      // Executa a exclusão
      await Get.find<HomeController>().deletePost(widget.post.id);

      // Cancela o timeout
      timeoutTimer.cancel();

      // Fecha o loading se ainda estiver ativo
      if (isLoadingActive) {
        isLoadingActive = false;
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      }

    } catch (e) {
      // Cancela o timeout
      timeoutTimer.cancel();

      // Fecha o loading em caso de erro
      if (isLoadingActive) {
        isLoadingActive = false;
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      }

      // Mostra erro
      Get.snackbar(
        'Erro',
        'Falha ao excluir o post: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.error, color: Colors.white),
      );
    }
  }

  void _showUnfollowConfirmation(HomeController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Deixar de seguir'),
        content: Text('Tem certeza que deseja deixar de seguir ${widget.post.authorName}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.toggleFollowUser(widget.post.authorId);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Deixar de seguir'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Reportar Post'),
        content: const Text('Tem certeza que deseja reportar este post por conteúdo inadequado?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Reportado',
                'Post reportado com sucesso. Nossa equipe irá analisar.',
                backgroundColor: AppColors.warning,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Reportar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return ClipRRect(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildImageOption(1, widget.post.imageOption1),
                ),
                Container(
                  width: 2.w,
                  color: AppColors.background,
                ),
                Expanded(
                  child: _buildImageOption(2, widget.post.imageOption2),
                ),
              ],
            ),
            // Heart animation overlay
            AnimatedBuilder(
              animation: _heartAnimationController,
              builder: (context, child) {
                if (_heartAnimationController.value == 0) {
                  return const SizedBox.shrink();
                }
                return Positioned.fill(
                  child: Center(
                    child: Transform.scale(
                      scale: _heartScaleAnimation.value,
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 40.sp,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(int option, String imageUrl) {
    // Check if the current user voted for this specific option
    final bool isUserSelected = widget.hasUserVoted && widget.userVote == option;
    final percentage = option == 1
        ? widget.post.option1Percentage
        : widget.post.option2Percentage;

    return GestureDetector(
      onTap: () => _showFullScreenImage(imageUrl, option),
      child: AnimatedBuilder(
        animation: _selectionAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isUserSelected
                    ? _selectionColorAnimation.value!
                    : Colors.transparent, // Only show border if user selected
                width: isUserSelected
                    ? _selectionBorderWidthAnimation.value
                    : 0.0,
              ),
              boxShadow: isUserSelected
                  ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(
                      _selectionAnimation.value * 0.4), // Animated shadow color
                  blurRadius: _selectionBlurRadiusAnimation.value,
                  offset: _selectionOffsetAnimation.value,
                ),
              ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isUserSelected ? 8.r : 0), // Slight rounded corners when selected
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagem base
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceVariant,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Carregando...',
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceVariant,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.textTertiary,
                            size: 28.sp,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Erro ao carregar',
                            style: TextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.05),
                        ],
                        stops: const [0.8, 1.0],
                      ),
                    ),
                  ),

                  // Resultado do voto (se votou)
                  if (widget.hasUserVoted)
                    Positioned(
                      top: 12.h,
                      right: 12.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: isUserSelected // Use isUserSelected here
                              ? AppColors.primary.withOpacity(0.9) // More prominent for user's vote
                              : Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isUserSelected) ...[ // Only show checkmark if this is the user's selected option
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 12.sp,
                              ),
                              SizedBox(width: 4.w),
                            ],
                            Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: TextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Botão de voto (se não votou)
                  if (!widget.hasUserVoted)
                    Positioned(
                      bottom: 12.h,
                      right: 12.w,
                      child: GestureDetector(
                        onTap: () => _handleVote(option),
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.how_to_vote_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // Vote status
          if (widget.hasUserVoted) ...[
            Icon(
              Icons.how_to_vote_rounded,
              size: 18.sp,
              color: AppColors.success,
            ),
            SizedBox(width: 6.w),
            Text(
              'Votou',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '• ${widget.post.totalVotes} votos',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            Icon(
              Icons.how_to_vote_outlined,
              size: 18.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              'Toque para votar',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '• ${widget.post.totalVotes} votos',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const Spacer(),
          // Action buttons
          GetX<HomeController>(
            builder: (controller) {
              final isSaved = controller.isPostSaved(widget.post.id);

              return GestureDetector(
                onTap: _handleSave,
                child: Icon(
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  size: 24.sp,
                  color: isSaved ? Colors.amber : AppColors.textSecondary,
                ),
              );
            },
          ),
          SizedBox(width: 16.w),
          _buildActionButton(
            icon: Icons.share_rounded,
            onTap: widget.onShare,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    IconData? activeIcon,
    bool isActive = false,
    Color? activeColor,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: isActive ? _saveAnimationController : const AlwaysStoppedAnimation(0),
        builder: (context, child) {
          return Transform.scale(
            scale: isActive ? _saveScaleAnimation.value : 1.0,
            child: Icon(
              isActive && activeIcon != null ? activeIcon : icon,
              size: 24.sp,
              color: isActive
                  ? (activeColor ?? AppColors.primary)
                  : AppColors.textSecondary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: Text(
        widget.post.description,
        style: TextStyles.bodyMedium.copyWith(
          color: AppColors.text,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags normais (se existirem)
          if (widget.post.tags.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: widget.post.tags.take(4).map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 10.sp,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getOccasionColor(PostOccasion occasion) {
    switch (occasion) {
      case PostOccasion.trabalho:
        return Colors.blue;
      case PostOccasion.festa:
        return Colors.purple;
      case PostOccasion.casual:
        return Colors.green;
      case PostOccasion.encontro:
        return Colors.pink;
      case PostOccasion.formatura:
        return Colors.indigo;
      case PostOccasion.casamento:
        return Colors.orange;
      case PostOccasion.academia:
        return Colors.red;
      case PostOccasion.viagem:
        return Colors.teal;
      case PostOccasion.balada:
        return Colors.deepPurple;
      case PostOccasion.praia:
        return Colors.cyan;
      case PostOccasion.shopping:
        return Colors.amber;
      default:
        return AppColors.primary;
    }
  }

  String _getTimeAgoDetailed(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'Há ${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'}';
    } else if (difference.inHours > 0) {
      return 'Há ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return 'Há ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'Agora mesmo';
    }
  }

  void _deletePost() {
    try {
      // Chama o método deletePost do HomeController
      final homeController = Get.find<HomeController>();
      homeController.deletePost(widget.post.id);

      Get.snackbar(
        'Sucesso',
        'Post excluído com sucesso!',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao excluir post: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: Icon(Icons.error, color: Colors.white),
      );
    }
  }
}
