import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool hasUserVoted;
  final int? userVote;
  final Function(int) onVote;

  const PostCard({
    super.key,
    required this.post,
    required this.hasUserVoted,
    this.userVote,
    required this.onVote,
  });

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

    _showResults = widget.hasUserVoted;
    _selectedOption = widget.userVote;

    if (widget.hasUserVoted) {
      _slideAnimationController.value = 1.0;
      _resultsAnimationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.hasUserVoted && widget.hasUserVoted) {
      _handleVoteSuccess();
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

    // Animate heart
    _heartAnimationController.forward().then((_) {
      _heartAnimationController.reverse();
    });

    // Animate slide and results
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
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (widget.post.description.isNotEmpty) _buildDescription(),
          _buildMainContent(),
          _buildEngagementSection(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
      child: Row(
        children: [
          Hero(
            tag: 'post_avatar_${widget.post.id}',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.8),
                    AppColors.secondary.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(2.w),
              child: CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.surface,
                child: CircleAvatar(
                  radius: 20.r,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: widget.post.authorProfileImage != null
                      ? CachedNetworkImageProvider(widget.post.authorProfileImage!)
                      : null,
                  child: widget.post.authorProfileImage == null
                      ? Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 20.sp,
                  )
                      : null,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.post.authorName,
                      style: TextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      width: 4.w,
                      height: 4.h,
                      decoration: const BoxDecoration(
                        color: AppColors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatTimeAgo(widget.post.createdAt),
                      style: TextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _getOccasionColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    widget.post.occasionDisplayName,
                    style: TextStyles.labelSmall.copyWith(
                      color: _getOccasionColor(),
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Menu de opções
            },
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Text(
        widget.post.description,
        style: TextStyles.bodyMedium.copyWith(
          color: AppColors.text,
          height: 1.4,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 0.8, // Mais alto que largo, como Instagram
          child: SizedBox(
            width: double.infinity,
            child: _buildImagesSection(),
          ),
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
    final isSelected = _selectedOption == option;
    final percentage = option == 1
        ? widget.post.option1Percentage
        : widget.post.option2Percentage;
    final votes = option == 1 ? widget.post.option1Votes : widget.post.option2Votes;

    return GestureDetector(
      onTap: widget.hasUserVoted ? null : () => _handleVote(option),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.surface,
            width: isSelected ? 3 : 0,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
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
                      child: const CircularProgressIndicator(
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

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),

            // Option number
            Positioned(
              top: 16.h,
              left: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Opção $option',
                  style: TextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ),

            // Results overlay
            if (_showResults) _buildResultsOverlay(option, percentage, votes, isSelected),

            // Vote button (when not voted)
            if (!widget.hasUserVoted) _buildVoteButton(option),

            // Selection indicator
            if (isSelected) _buildSelectionIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsOverlay(int option, double percentage, int votes, bool isSelected) {
    return AnimatedBuilder(
      animation: _resultsAnimationController,
      builder: (context, child) {
        return Positioned(
          bottom: 16.h,
          left: 16.w,
          right: 16.w,
          child: Transform.translate(
            offset: Offset(0, 30.h * (1 - _resultsSlideAnimation.value)),
            child: Opacity(
              opacity: _resultsOpacityAnimation.value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [AppColors.primary, AppColors.secondary]
                        : [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.6)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (isSelected) ...[
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 16.sp,
                              ),
                              SizedBox(width: 6.w),
                            ],
                            Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: TextStyles.titleSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$votes votos',
                          style: TextStyles.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    // Progress bar
                    Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoteButton(int option) {
    return Positioned(
      bottom: 20.h,
      left: 16.w,
      right: 16.w,
      child: AnimatedBuilder(
        animation: _slideAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 60.h * _slideAnimation.value),
            child: Opacity(
              opacity: 1 - _slideAnimation.value,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleVote(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.95),
                    foregroundColor: AppColors.primary,
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.how_to_vote_rounded,
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Votar',
                        style: TextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
                  width: 3,
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

  Widget _buildEngagementSection() {
    if (!_showResults) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _resultsAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20.h * (1 - _resultsSlideAnimation.value)),
          child: Opacity(
            opacity: _resultsOpacityAnimation.value,
            child: Container(
              margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryLight.withOpacity(0.1),
                    AppColors.secondaryLight.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.poll_rounded,
                        color: AppColors.primary,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Resultados da Votação',
                        style: TextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildEngagementStats(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEngagementStats() {
    final isOption1Winner = widget.post.option1Votes >= widget.post.option2Votes;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            'Opção 1',
            widget.post.option1Votes,
            widget.post.option1Percentage,
            isOption1Winner,
            _selectedOption == 1,
          ),
        ),
        Container(
          width: 1,
          height: 40.h,
          color: AppColors.border,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
        ),
        Expanded(
          child: _buildStatItem(
            'Opção 2',
            widget.post.option2Votes,
            widget.post.option2Percentage,
            !isOption1Winner,
            _selectedOption == 2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int votes, double percentage, bool isWinner, bool isUserChoice) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isWinner) ...[
              Icon(
                Icons.emoji_events_rounded,
                color: AppColors.primary,
                size: 14.sp,
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
                color: isWinner ? AppColors.primary : AppColors.text,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          '$votes votos',
          style: TextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isUserChoice) ...[
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              'Seu voto',
              style: TextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 9.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.how_to_vote_outlined,
                  size: 14.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${widget.post.totalVotes}',
                  style: TextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'votos',
                  style: TextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (widget.post.tags.isNotEmpty)
            Wrap(
              spacing: 6.w,
              children: widget.post.tags.take(3).map((tag) {
                return Text(
                  '#$tag',
                  style: TextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Color _getOccasionColor() {
    switch (widget.post.occasion) {
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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'agora';
    }
  }
}
