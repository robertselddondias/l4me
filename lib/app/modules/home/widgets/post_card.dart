import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool hasUserVoted;
  final int? userVote;
  final Function(int) onVote;
  final VoidCallback? onRemoveVote;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const PostCard({
    Key? key,
    required this.post,
    required this.hasUserVoted,
    this.userVote,
    required this.onVote,
    this.onRemoveVote,
    this.onSave,
    this.onShare,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with TickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late AnimationController _selectionAnimationController;

  late Animation<double> _heartScaleAnimation;
  late Animation<double> _selectionAnimation;

  int? _selectedOption;

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
  }

  void _initializeState() {
    _selectedOption = widget.hasUserVoted ? widget.userVote : null;

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

    if (needsStateUpdate) {
      _initializeState();

      if (!oldWidget.hasUserVoted && widget.hasUserVoted) {
        _handleVoteSuccess();
      }

      if (oldWidget.hasUserVoted && !widget.hasUserVoted) {
        _handleVoteRemoved();
      }
    }
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    _selectionAnimationController.dispose();
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

  void _handleVoteRemoved() {
    setState(() {
      _selectedOption = null;
    });
    _selectionAnimationController.reverse();
  }

  void _showFullScreenImage(String imageUrl, int option) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fundo escuro
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

            // Botão de fechar
            Positioned(
              top: MediaQuery.of(context).padding.top + 16.h,
              right: 16.w,
              child: Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ),

            // Info da opção
            Positioned(
              top: MediaQuery.of(context).padding.top + 16.h,
              left: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20.r),
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

            // Botão de voto (se não votou ainda)
            if (!widget.hasUserVoted)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 24.h,
                left: 24.w,
                right: 24.w,
                child: Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(28.r),
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
                      borderRadius: BorderRadius.circular(28.r),
                      onTap: () {
                        Get.back();
                        _handleVote(option);
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.how_to_vote_rounded,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Votar nesta opção',
                              style: TextStyles.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernHeader(),
            if (widget.post.description.isNotEmpty) _buildDescription(),
            _buildMainContent(),
            if (widget.post.tags.isNotEmpty) _buildTagsSection(),
            _buildMinimalFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
      child: Row(
        children: [
          // Avatar com design moderno
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: widget.post.authorProfileImage != null && widget.post.authorProfileImage!.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: CachedNetworkImage(
                imageUrl: widget.post.authorProfileImage!,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.person_rounded,
                  color: AppColors.onPrimary,
                  size: 24.sp,
                ),
              ),
            )
                : Icon(
              Icons.person_rounded,
              color: AppColors.onPrimary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          // Info do usuário
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.authorName,
                  style: TextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _getOccasionColor(widget.post.occasion).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        widget.post.occasionDisplayName,
                        style: TextStyles.labelSmall.copyWith(
                          color: _getOccasionColor(widget.post.occasion),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.access_time_rounded,
                      size: 12.sp,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _getTimeAgo(widget.post.createdAt),
                      style: TextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Menu de ações
          _buildActionMenu(),
        ],
      ),
    );
  }

  Widget _buildActionMenu() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: PopupMenuButton<String>(
        icon: Icon(
          Icons.more_horiz_rounded,
          color: AppColors.textSecondary,
          size: 20.sp,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 8,
        onSelected: (value) {
          switch (value) {
            case 'save':
              widget.onSave?.call();
              break;
            case 'share':
              widget.onShare?.call();
              break;
            case 'remove_vote':
              widget.onRemoveVote?.call();
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'save',
            child: Row(
              children: [
                Icon(Icons.bookmark_border_rounded, size: 18.sp),
                SizedBox(width: 12.w),
                const Text('Salvar'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share_rounded, size: 18.sp),
                SizedBox(width: 12.w),
                const Text('Compartilhar'),
              ],
            ),
          ),
          if (widget.hasUserVoted)
            PopupMenuItem(
              value: 'remove_vote',
              child: Row(
                children: [
                  Icon(Icons.remove_circle_outline_rounded, size: 18.sp, color: AppColors.error),
                  SizedBox(width: 12.w),
                  Text('Remover Voto', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w).copyWith(bottom: 16.h),
      child: Text(
        widget.post.description,
        style: TextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      height: 320.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            _buildImagesSection(),
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

  Widget _buildImagesSection() {
    return Row(
      children: [
        Expanded(
          child: _buildImageOption(1, widget.post.imageOption1),
        ),
        Expanded(
          child: _buildImageOption(2, widget.post.imageOption2),
        ),
      ],
    );
  }

  Widget _buildImageOption(int option, String imageUrl) {
    final isSelected = widget.hasUserVoted && _selectedOption == option;
    final percentage = option == 1
        ? widget.post.option1Percentage
        : widget.post.option2Percentage;

    return Container(
      margin: option == 1 ? EdgeInsets.only(right: 1.w) : EdgeInsets.only(left: 1.w),
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
                    width: 24.w,
                    height: 24.h,
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
                      fontSize: 10.sp,
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
                    size: 32.sp,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Erro ao carregar',
                    style: TextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Gradient sutil para contraste
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
                stops: const [0.7, 1.0],
              ),
            ),
          ),

          // GestureDetector para expandir imagem (cobre toda a área)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _showFullScreenImage(imageUrl, option),
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Percentual (apenas se votou)
          if (widget.hasUserVoted)
            Positioned(
              top: 16.h,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [AppColors.primary, AppColors.secondary]
                        : [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.6)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                    ],
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Botão de voto (apenas se não votou) - com stopPropagation
          if (!widget.hasUserVoted)
            Positioned(
              bottom: 12.h,
              right: 12.w,
              child: GestureDetector(
                onTap: () => _handleVote(option),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.how_to_vote_rounded,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
            ),

          // Indicador de seleção
          if (widget.hasUserVoted && isSelected) _buildSelectionIndicator(),

          // Ícone de expandir (canto superior esquerdo) - com indicação visual
          Positioned(
            top: 12.h,
            left: 12.w,
            child: Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.fullscreen_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _selectionAnimationController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary.withOpacity(_selectionAnimation.value),
                width: 4,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15 * _selectionAnimation.value),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTagsSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.label_outline_rounded,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6.w),
              Text(
                'Tags',
                style: TextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: widget.post.tags.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      child: Row(
        children: [
          Icon(
            Icons.how_to_vote_rounded,
            size: 16.sp,
            color: AppColors.textTertiary,
          ),
          SizedBox(width: 6.w),
          Text(
            '${widget.post.totalVotes} votos',
            style: TextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12.w),
          Icon(
            Icons.fullscreen_rounded,
            size: 14.sp,
            color: AppColors.textTertiary,
          ),
          const Spacer(),
          if (widget.hasUserVoted) ...[
            Icon(
              Icons.check_circle_rounded,
              size: 16.sp,
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
          ] else ...[
            Icon(
              Icons.touch_app_rounded,
              size: 16.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 6.w),
            Text(
              'Vote',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
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

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'agora';
    }
  }
}
