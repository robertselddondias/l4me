// lib/app/modules/home/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/post_model.dart';
import 'package:flutter/gestures.dart'; // Importação adicionada para Text.rich e TapGestureRecognizer

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

  int? _selectedOption;
  bool _isDescriptionExpanded = false; // NOVO: Estado para a descrição expansível

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

    _heartAnimationController.reset();
    _selectionAnimationController.reset();

    if (widget.hasUserVoted && _selectedOption != null) {
      _selectionAnimationController.value = 1.0;
    }
    _isDescriptionExpanded = false; // Garante que a descrição comece contraída
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
    _saveAnimationController.forward().then((_) {
      _saveAnimationController.reverse();
    });
    widget.onSave?.call();
  }

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
        borderRadius: BorderRadius.circular(16.r),
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
          _buildHeader(),
          _buildImagesSection(),
          _buildActionBar(),
          _buildVoteInfo(),
          if (widget.post.description.isNotEmpty) _buildDescription(),
          if (widget.post.tags.isNotEmpty) _buildTags(),
          _buildTimeStamp(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              radius: 19.r,
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
                size: 20.sp,
              )
                  : null,
            ),
          ),
          SizedBox(width: 12.w),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible( // Mantido Flexible para o nome do autor
                      child: Text(
                        widget.post.authorName,
                        style: TextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible( // Mantido Flexible para a tag de ocasião
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _getOccasionColor(widget.post.occasion).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          widget.post.occasionDisplayName,
                          style: TextStyles.labelSmall.copyWith(
                            color: _getOccasionColor(widget.post.occasion),
                            fontWeight: FontWeight.w600,
                            fontSize: 9.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  widget.post.occasionDisplayName,
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          // Follow button or menu
          Flexible(
            child: !widget.isOwnPost ? _buildFollowButton() : _buildMenuButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return Container(
      height: 32.h,
      child: ElevatedButton(
        onPressed: widget.onFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isFollowing ? AppColors.surfaceVariant : AppColors.primary,
          foregroundColor: widget.isFollowing ? AppColors.text : AppColors.onPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: widget.isFollowing ? const BorderSide(color: AppColors.border) : BorderSide.none,
          ),
          minimumSize: Size(80.w, 32.h), // Melhoria: Define um tamanho mínimo para consistência
        ),
        child: Text(
          widget.isFollowing ? 'Seguindo' : 'Seguir',
          style: TextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return Container(
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
    );
  }

  // NOVO/MODIFICADO: Widget para exibir a descrição com funcionalidade de "Ver mais/menos"
  Widget _buildDescription() {
    const int maxLinesToShow = 3; // Número máximo de linhas antes de truncar

    // Cria um TextPainter para verificar se o texto excede o limite de linhas
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.post.description,
        style: TextStyles.bodyMedium.copyWith(color: AppColors.text, height: 1.4),
      ),
      maxLines: maxLinesToShow,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: MediaQuery.of(context).size.width - (16.w * 2)); // Largura disponível para o texto

    final bool isOverflowing = textPainter.didExceedMaxLines;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: widget.post.description,
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.text,
                    height: 1.4,
                  ),
                ),
                if (isOverflowing && !_isDescriptionExpanded) // Se houver overflow e não estiver expandido
                  TextSpan(
                    text: '... ', // Adiciona reticências antes do "Ver mais"
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.text, // Mesma cor do texto principal
                      height: 1.4,
                    ),
                  ),
                if (isOverflowing && !_isDescriptionExpanded)
                  TextSpan(
                    text: 'Ver mais',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        setState(() {
                          _isDescriptionExpanded = true;
                        });
                      },
                  ),
                if (isOverflowing && _isDescriptionExpanded) // Se estiver expandido, mostra "Ver menos"
                  TextSpan(
                    text: ' Ver menos',
                    style: TextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        setState(() {
                          _isDescriptionExpanded = false;
                        });
                      },
                  ),
              ],
            ),
            maxLines: _isDescriptionExpanded ? null : maxLinesToShow, // Define maxLines com base no estado de expansão
            overflow: TextOverflow.fade, // Usa fade para o overflow do Text.rich
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
    final isSelected = widget.hasUserVoted && _selectedOption == option;
    final percentage = option == 1
        ? widget.post.option1Percentage
        : widget.post.option2Percentage;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagem base
        GestureDetector(
          onTap: () => _showFullScreenImage(imageUrl, option),
          child: CachedNetworkImage(
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
                color: isSelected
                    ? AppColors.primary
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
                  if (isSelected) ...[
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

        // Label da opção
        Positioned(
          top: 12.h,
          left: 12.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'Opção $option',
              style: TextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10.sp,
              ),
            ),
          ),
        ),

        // Indicador de seleção
        if (widget.hasUserVoted && isSelected) _buildSelectionIndicator(),
      ],
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
                color: AppColors.primary.withOpacity(_selectionAnimation.value * 0.6),
                width: 3,
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
          ],
          const Spacer(),
          // Action buttons
          _buildActionButton(
            icon: Icons.bookmark_border_rounded,
            activeIcon: Icons.bookmark_rounded,
            isActive: widget.isSaved,
            onTap: _handleSave,
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
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildVoteInfo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: Text(
        '${widget.post.totalVotes} votos',
        style: TextStyles.bodyMedium.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTags() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
      child: Wrap(
        spacing: 6.w,
        runSpacing: 4.h,
        children: widget.post.tags.take(3).map((tag) {
          return Text(
            '#$tag',
            style: TextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeStamp() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.w),
      child: Text(
        _getTimeAgo(widget.post.createdAt),
        style: TextStyles.bodySmall.copyWith(
          color: AppColors.textTertiary,
          fontSize: 10.sp,
        ),
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
