import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:look4me/app/core/constants/app_colors.dart';
import 'package:look4me/app/core/themes/text_styles.dart';

class DailyChallengesSection extends StatelessWidget {
  const DailyChallengesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _getMockChallenges().length,
        itemBuilder: (context, index) {
          final challenge = _getMockChallenges()[index];
          return Container(
            width: 280.w,
            margin: EdgeInsets.only(right: 12.w),
            child: _buildChallengeCard(challenge, index),
          );
        },
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge, int index) {
    final gradients = [
      [Colors.orange.shade400, Colors.pink.shade400],
      [Colors.purple.shade400, Colors.blue.shade400],
      [Colors.green.shade400, Colors.teal.shade400],
      [Colors.red.shade400, Colors.orange.shade400],
    ];

    final gradient = gradients[index % gradients.length];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  challenge['icon'],
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge['title'],
                      style: TextStyles.titleSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      challenge['description'],
                      style: TextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  challenge['reward'],
                  style: TextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: challenge['progress'],
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '${(challenge['progress'] * 100).toInt()}%',
                style: TextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 14.sp,
                color: Colors.white.withOpacity(0.8),
              ),
              SizedBox(width: 4.w),
              Text(
                '${challenge['participants']} participando',
                style: TextStyles.labelSmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const Spacer(),
              Text(
                challenge['timeLeft'],
                style: TextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockChallenges() {
    return [
      {
        'title': 'Look Profissional',
        'description': 'Vista-se para o sucesso no trabalho',
        'icon': Icons.work_outline_rounded,
        'reward': '+50 XP',
        'progress': 0.7,
        'participants': 234,
        'timeLeft': '4h restantes',
      },
      {
        'title': 'Style Sustentável',
        'description': 'Crie looks com peças que já tem',
        'icon': Icons.eco_outlined,
        'reward': '+75 XP',
        'progress': 0.3,
        'participants': 189,
        'timeLeft': '12h restantes',
      },
      {
        'title': 'Minimalista Chic',
        'description': 'Menos é mais: máximo 3 cores',
        'icon': Icons.minimize_rounded,
        'reward': '+60 XP',
        'progress': 0.9,
        'participants': 156,
        'timeLeft': '2h restantes',
      },
      {
        'title': 'Vintage Vibes',
        'description': 'Looks inspirados nos anos 90',
        'icon': Icons.history_rounded,
        'reward': '+80 XP',
        'progress': 0.1,
        'participants': 98,
        'timeLeft': '18h restantes',
      },
    ];
  }
}
