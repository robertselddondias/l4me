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
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const PostCard({
    Key? key,
    required this.post,
    required this.hasUserVoted,
    this.userVote,
    required this.onVote,
    this.onSave,
    this.onShare,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with TickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _resultsAnimationController;

  late Animation<double> _heartScaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _resultsSlideAnimation;
  late Animation<double> _resultsOpacityAnimation;

  bool _showResults = false;
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

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _resultsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _resultsSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultsAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _resultsOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultsAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
  }

  void _initializeState() {
    _showResults = widget.hasUserVoted;
    _selectedOption = widget.hasUserVoted ? widget.userVote : null;

    _heartAnimationController.reset();
    _slideAnimationController.reset();
    _resultsAnimationController.reset();

    if (widget.hasUserVoted && _selectedOption != null) {
      _slideAnimationController.value = 1.0;
      _resultsAnimationController.value = 1.0;
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
    }
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    _slideAnimationController.dispose();
    _resultsAnimationController.dispose();
    super.dispose();
  }

  void _handleVote(int option) {
    setState(() {
      _selectedOption = option;
      _showResults = true;
    });

    _heartAnimationController.forward().then((_) {
      _heartAnimationController.reverse();
    });

    _slideAnimationController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      _resultsAnimationController.forward();
    });

    widget.onVote(option);
  }

  void _handleVoteSuccess() {
    setState(() {
      _showResults = true;
    });
    _slideAnimationController.forward();
    _resultsAnimationController.forward();
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
            _buildFooter(),
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
            child: widget.post.authorProfileImage!.isNotEmpty
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
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        widget.post.occasion.name,
                        style: TextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
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
          child: _buildModernImageOption(1, widget.post.imageOption1),
        ),
        Expanded(
          child: _buildModernImageOption(2, widget.post.imageOption2),
        ),
      ],
    );
  }

  Widget _buildModernImageOption(int option, String imageUrl) {
    final isSelected = widget.hasUserVoted && _selectedOption == option;
    final percentage = option == 1
        ? widget.post.option1Percentage
        : widget.post.option2Percentage;

    return GestureDetector(
      onTap: widget.hasUserVoted ? null : () => _handleVote(option),
      child: Container(
        margin: option == 1 ? EdgeInsets.only(right: 1.w) : EdgeInsets.only(left: 1.w),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem
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

            // Percentual no canto superior direito (apenas se votou)
            if (widget.hasUserVoted)
              Positioned(
                top: 16.h,
                right: 16.w,
                child: AnimatedBuilder(
                  animation: _resultsAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _resultsSlideAnimation.value,
                      child: Opacity(
                        opacity: _resultsOpacityAnimation.value,
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
                    );
                  },
                ),
              ),

            // Botão de voto (apenas se não votou)
            if (!widget.hasUserVoted) _buildModernVoteButton(option),

            // Indicador de seleção
            if (widget.hasUserVoted && isSelected) _buildSelectionIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernVoteButton(int option) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
        ),
        child: Center(
          child: Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.touch_app_rounded,
              color: AppColors.primary,
              size: 32.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _slideAnimationController,
        builder: (context, child) {
          return Opacity(
            opacity: _slideAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary,
                  width: 4,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      child: Column(
        children: [
          // Votação simples e moderna (apenas se votou)
          if (widget.hasUserVoted) ...[
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.poll_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Obrigado pelo seu voto!',
                    style: TextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.post.option1Votes + widget.post.option2Votes} votos',
                    style: TextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Call to action para votar
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.how_to_vote_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Qual look você escolheria?',
                      style: TextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
