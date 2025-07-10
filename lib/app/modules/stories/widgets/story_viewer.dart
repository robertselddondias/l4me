import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';
import 'package:look4me/app/data/models/story_model.dart';
import 'package:url_launcher/url_launcher.dart';

class StoryViewer extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;
  final Function(String)? onStoryViewed;
  final VoidCallback? onClose;

  const StoryViewer({
    Key? key,
    required this.stories,
    this.initialIndex = 0,
    this.onStoryViewed,
    this.onClose,
  }) : super(key: key);

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _scaleController;

  int _currentIndex = 0;
  Timer? _timer;
  bool _isPaused = false;
  bool _isVisible = true;

  static const Duration _storyDuration = Duration(seconds: 15);
  static const Duration _animationDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    _progressController = AnimationController(
      duration: _storyDuration,
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startStory();
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _scaleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startStory() {
    _progressController.reset();
    _progressController.forward();

    _timer?.cancel();
    _timer = Timer(_storyDuration, () {
      if (!_isPaused && mounted) {
        _nextStory();
      }
    });

    // Marcar como visualizado
    if (widget.onStoryViewed != null) {
      widget.onStoryViewed!(widget.stories[_currentIndex].id);
    }
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.nextPage(
        duration: _animationDuration,
        curve: Curves.easeInOut,
      );
      _startStory();
    } else {
      _closeViewer();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.previousPage(
        duration: _animationDuration,
        curve: Curves.easeInOut,
      );
      _startStory();
    }
  }

  void _pauseStory() {
    setState(() {
      _isPaused = true;
    });
    _progressController.stop();
    _timer?.cancel();
  }

  void _resumeStory() {
    setState(() {
      _isPaused = false;
    });

    final remainingTime = Duration(
      milliseconds: ((_storyDuration.inMilliseconds) *
          (1.0 - _progressController.value)).round(),
    );

    _progressController.forward();
    _timer = Timer(remainingTime, () {
      if (!_isPaused && mounted) {
        _nextStory();
      }
    });
  }

  void _toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void _closeViewer() {
    _scaleController.reverse().then((_) {
      if (widget.onClose != null) {
        widget.onClose!();
      } else {
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          return Transform.scale(
            scale: Curves.easeOut.transform(_scaleController.value),
            child: Opacity(
              opacity: _scaleController.value,
              child: _buildStoryContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoryContent() {
    return GestureDetector(
      onTapDown: (details) => _pauseStory(),
      onTapUp: (details) {
        _resumeStory();
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.localPosition.dx < screenWidth * 0.3) {
          _previousStory();
        } else if (details.localPosition.dx > screenWidth * 0.7) {
          _nextStory();
        } else {
          _toggleVisibility();
        }
      },
      onTapCancel: () => _resumeStory(),
      onLongPressStart: (_) => _pauseStory(),
      onLongPressEnd: (_) => _resumeStory(),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              if (index != _currentIndex) {
                setState(() {
                  _currentIndex = index;
                });
                _startStory();
              }
            },
            itemCount: widget.stories.length,
            itemBuilder: (context, index) {
              return _buildStoryPage(widget.stories[index]);
            },
          ),
          if (_isVisible) _buildOverlay(),
        ],
      ),
    );
  }

  Widget _buildStoryPage(StoryModel story) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          if (story.imageUrl != null)
            _buildStoryImage(story.imageUrl!)
          else
            _buildGradientBackground(),

          // Content overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Story content
          _buildStoryTextContent(story),
        ],
      ),
    );
  }

  Widget _buildStoryImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.surfaceVariant,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildGradientBackground(),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
            AppColors.accent,
          ],
        ),
      ),
    );
  }

  Widget _buildStoryTextContent(StoryModel story) {
    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            // Story content
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    story.content,
                    style: TextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  if (story.linkUrl != null) ...[
                    SizedBox(height: 16.h),
                    _buildActionButton(story),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(StoryModel story) {
    return GestureDetector(
      onTap: () => _launchURL(story.linkUrl!),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getActionIcon(story.type),
              color: AppColors.primary,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              _getActionText(story.type),
              style: TextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return SafeArea(
      child: Column(
        children: [
          // Progress indicators
          _buildProgressIndicators(),
          SizedBox(height: 16.h),

          // Header
          _buildHeader(),

          const Spacer(),

          // Bottom controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: List.generate(
          widget.stories.length,
              (index) => Expanded(
            child: Container(
              height: 3.h,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(1.5.r),
              ),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  double progress = 0.0;
                  if (index < _currentIndex) {
                    progress = 1.0;
                  } else if (index == _currentIndex) {
                    progress = _progressController.value;
                  }

                  return FractionallySizedBox(
                    widthFactor: progress,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1.5.r),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final story = widget.stories[_currentIndex];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: story.authorProfileImage != null
                ? CachedNetworkImageProvider(story.authorProfileImage!)
                : null,
            child: story.authorProfileImage == null
                ? Icon(
              Icons.person,
              color: Colors.white,
              size: 20.sp,
            )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.authorName,
                  style: TextStyles.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatTimeAgo(story.createdAt),
                  style: TextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _getTypeColor(story.type).withOpacity(0.9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              story.typeDisplayName,
              style: TextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _closeViewer,
            child: Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          if (_isPaused)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.pause_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Pausado',
                    style: TextStyles.labelSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          Text(
            '${_currentIndex + 1} de ${widget.stories.length}',
            style: TextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(StoryType type) {
    switch (type) {
      case StoryType.discount:
        return Icons.shopping_bag_outlined;
      case StoryType.tutorial:
        return Icons.play_arrow_rounded;
      case StoryType.tip:
        return Icons.lightbulb_outlined;
      default:
        return Icons.link_rounded;
    }
  }

  String _getActionText(StoryType type) {
    switch (type) {
      case StoryType.discount:
        return 'Ver Oferta';
      case StoryType.tutorial:
        return 'Assistir';
      case StoryType.tip:
        return 'Saiba Mais';
      default:
        return 'Ver Mais';
    }
  }

  Color _getTypeColor(StoryType type) {
    switch (type) {
      case StoryType.tip:
        return AppColors.primary;
      case StoryType.outfit:
        return AppColors.secondary;
      case StoryType.accessory:
        return AppColors.accent;
      case StoryType.trend:
        return Colors.orange;
      case StoryType.discount:
        return Colors.green;
      case StoryType.tutorial:
        return Colors.blue;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  Future<void> _launchURL(String url) async {
    _pauseStory();
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Erro ao abrir URL: $e');
    } finally {
      _resumeStory();
    }
  }
}
