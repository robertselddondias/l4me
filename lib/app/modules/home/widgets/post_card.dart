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
    Key? key,
    required this.post,
    required this.hasUserVoted,
    this.userVote,
    required this.onVote,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _showResults = widget.hasUserVoted;

    if (widget.hasUserVoted) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.hasUserVoted && widget.hasUserVoted) {
      setState(() {
        _showResults = true;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleVote(int option) {
    widget.onVote(option);
    setState(() {
      _showResults = true;
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (widget.post.description.isNotEmpty) _buildDescription(),
          _buildImagesSection(),
          _buildVotingSection(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Hero(
            tag: 'avatar_${widget.post.authorId}',
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.primaryLight,
                backgroundImage: widget.post.authorProfileImage != null
                    ? CachedNetworkImageProvider(widget.post.authorProfileImage!)
                    : null,
                child: widget.post.authorProfileImage == null
                    ? Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 24.sp,
                )
                    : null,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.authorName,
                  style: TextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14.sp,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatTimeAgo(widget.post.createdAt),
                      style: TextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getOccasionColor().withOpacity(0.1),
                  _getOccasionColor().withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: _getOccasionColor().withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getOccasionIcon(),
                  size: 16.sp,
                  color: _getOccasionColor(),
                ),
                SizedBox(width: 6.w),
                Text(
                  widget.post.occasionDisplayName,
                  style: TextStyles.labelMedium.copyWith(
                    color: _getOccasionColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
        style: TextStyles.bodyLarge.copyWith(
          color: AppColors.text,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: _buildImageOption(1, widget.post.imageOption1),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: _buildImageOption(2, widget.post.imageOption2),
          ),
        ],
      ),
    );
  }

  Widget _buildImageOption(int option, String imageUrl) {
    final isSelected = widget.hasUserVoted && widget.userVote == option;
    final percentage = option == 1
        ? widget.post.option1Percentage
        : widget.post.option2Percentage;

    return GestureDetector(
      onTap: widget.hasUserVoted ? null : () => _handleVote(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 280.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : widget.hasUserVoted
                ? AppColors.border.withOpacity(0.5)
                : AppColors.border,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
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
                      CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Carregando...',
                        style: TextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
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
                        Icons.broken_image_outlined,
                        color: AppColors.textTertiary,
                        size: 48.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Erro ao carregar',
                        style: TextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Overlay gradiente
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),

              // Option label
              Positioned(
                top: 16.h,
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

              // Results overlay
              if (_showResults) _buildResultsOverlay(option, percentage, isSelected),

              // Voting button
              if (!widget.hasUserVoted) _buildVoteButton(option),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsOverlay(int option, double percentage, bool isSelected) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          top: 16.h,
          right: 16.w,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: (isSelected ? AppColors.primary : Colors.black)
                          .withOpacity(0.3),
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
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
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
        );
      },
    );
  }

  Widget _buildVoteButton(int option) {
    return Positioned(
      bottom: 16.h,
      left: 16.w,
      right: 16.w,
      child: Container(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleVote(option),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.9),
            foregroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.h),
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVotingSection() {
    if (!_showResults) {
      return SizedBox(height: 20.h);
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: EdgeInsets.all(20.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight.withOpacity(0.1),
                  AppColors.secondaryLight.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Resultados da Votação',
                  style: TextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildResultBar(1, widget.post.option1Votes, widget.post.option1Percentage),
                SizedBox(height: 12.h),
                _buildResultBar(2, widget.post.option2Votes, widget.post.option2Percentage),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultBar(int option, int votes, double percentage) {
    final isUserChoice = widget.userVote == option;
    final isWinner = (option == 1 && widget.post.option1Votes >= widget.post.option2Votes) ||
        (option == 2 && widget.post.option2Votes >= widget.post.option1Votes);

    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 800 + (option * 200)),
            width: double.infinity * (percentage / 100),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isWinner ? [
                  AppColors.primary,
                  AppColors.primaryLight,
                ] : [
                  AppColors.textTertiary,
                  AppColors.textTertiary.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(24.r),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            height: 48.h,
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(
                      isWinner ? Icons.emoji_events_rounded : Icons.circle_outlined,
                      size: 16.sp,
                      color: percentage > 30
                          ? Colors.white
                          : (isWinner ? AppColors.primary : AppColors.textSecondary),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Opção $option',
                      style: TextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: percentage > 30
                            ? Colors.white
                            : AppColors.text,
                      ),
                    ),
                    if (isUserChoice) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: percentage > 30
                              ? Colors.white.withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'Seu voto',
                          style: TextStyles.labelSmall.copyWith(
                            color: percentage > 30
                                ? Colors.white
                                : AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const Spacer(),
                Text(
                  '${percentage.toStringAsFixed(0)}% ($votes)',
                  style: TextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: percentage > 30
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.all(20.w).copyWith(top: 0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.how_to_vote_outlined,
                  size: 16.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  '${widget.post.totalVotes} votos',
                  style: TextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
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
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12.r),
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

  IconData _getOccasionIcon() {
    switch (widget.post.occasion) {
      case PostOccasion.trabalho:
        return Icons.work_outline_rounded;
      case PostOccasion.festa:
        return Icons.celebration_outlined;
      case PostOccasion.casual:
        return Icons.weekend_outlined;
      case PostOccasion.encontro:
        return Icons.favorite_outline_rounded;
      case PostOccasion.formatura:
        return Icons.school_outlined;
      case PostOccasion.casamento:
        return Icons.church_outlined;
      case PostOccasion.academia:
        return Icons.fitness_center_outlined;
      case PostOccasion.viagem:
        return Icons.flight_outlined;
      case PostOccasion.balada:
        return Icons.nightlife_outlined;
      case PostOccasion.praia:
        return Icons.beach_access_outlined;
      case PostOccasion.shopping:
        return Icons.shopping_bag_outlined;
      default:
        return Icons.more_horiz_outlined;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'agora';
    }
  }
}
