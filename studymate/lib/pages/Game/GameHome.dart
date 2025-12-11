import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'GameRanks.dart';
import 'GameLeaderBoard.dart';
import '../../theme/app_constants.dart';

class GameHome extends StatefulWidget {
  const GameHome({super.key});

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Animation للزر (نبض)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animation للشخصية (طفو)
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  // Helper function to get user data from Hive
  Map<String, dynamic> _getUserData() {
    final userBox = Hive.box('userBox');
    final xp = userBox.get('xp', defaultValue: 0);
    return {
      'username': userBox.get('username', defaultValue: 'Player'),
      'xp': xp,
      'title': _calculateRankFromXP(xp), // Calculate rank dynamically
    };
  }

  // Calculate rank dynamically based on XP (matches updated system)
  String _calculateRankFromXP(int xp) {
    if (xp >= 3500) {
      return 'El Batal';
    } else if (xp >= 2500) {
      return 'Legend';
    } else if (xp >= 1700) {
      return 'Mentor';
    } else if (xp >= 1100) {
      return 'Expert';
    } else if (xp >= 650) {
      return 'Challenger';
    } else if (xp >= 350) {
      return 'Achiever';
    } else if (xp >= 150) {
      return 'Explorer';
    } else {
      return 'NewComer';
    }
  }

  Color _getRankColor(String rank) {
    switch (rank) {
      case 'El Batal':
        return AppConstants.rankElBatal;
      case 'Legend':
        return AppConstants.rankLegend;
      case 'Mentor':
        return AppConstants.rankMentor;
      case 'Expert':
        return AppConstants.rankExpert;
      case 'Challenger':
        return AppConstants.rankChallenger;
      case 'Achiever':
        return AppConstants.rankAchiever;
      case 'Explorer':
        return AppConstants.rankExplorer;
      case 'NewComer':
      default:
        return AppConstants.rankNewComer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userData = _getUserData();
    final rankColor = _getRankColor(userData['title']);

    return Scaffold(
      backgroundColor: AppConstants.backgroundDark,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0e27),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppConstants.textOnDark,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // خلفية متدرجة مع تأثير gaming
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0a0e27),
                  const Color(0xFF1a1f3a),
                  AppConstants.backgroundDark,
                  const Color(0xFF1a1f3a),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Particles effect (نقاط متحركة في الخلفية)
          ...List.generate(15, (index) {
            return Positioned(
              left: (index * 73.5) % size.width,
              top: (index * 97.3) % size.height,
              child: TweenAnimationBuilder(
                duration: Duration(milliseconds: 2000 + (index * 200)),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: (value * 0.3),
                    child: Container(
                      width: 4 + (index % 3) * 2,
                      height: 4 + (index % 3) * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            rankColor.withOpacity(0.8),
                            rankColor.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  if (mounted) setState(() {});
                },
              ),
            );
          }),

          // المحتوى الرئيسي
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.02),

                    // Header مع اسم اللاعب والرتبة
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            rankColor.withOpacity(0.2),
                            rankColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: rankColor.withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: rankColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                color: rankColor,
                                size: 28,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                userData['username'],
                                style: AppConstants.pageTitle.copyWith(
                                  color: AppConstants.textOnDark,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: rankColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: rankColor.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.military_tech_rounded,
                                  color: AppConstants.textOnDark,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  userData['title'],
                                  style: AppConstants.cardTitle.copyWith(
                                    color: AppConstants.textOnDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.stars_rounded,
                                color: AppConstants.primaryCyan,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${userData['xp']} XP',
                                style: AppConstants.subtitle.copyWith(
                                  color: AppConstants.primaryCyan,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

                    // عنوان درامي
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: Column(
                              children: [
                                Text(
                                  'Welcome to',
                                  style: AppConstants.subtitle.copyWith(
                                    color: AppConstants.textOnDark
                                        .withOpacity(0.7),
                                    fontSize: 18,
                                    letterSpacing: 2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppConstants.primaryCyan,
                                      AppConstants.primaryBlue,
                                      AppConstants.rankLegend,
                                      AppConstants.rankElBatal,
                                    ],
                                    stops: const [0.0, 0.3, 0.6, 1.0],
                                  ).createShader(bounds),
                                  child: Text(
                                    'EL BATAL',
                                    style: AppConstants.pageTitle.copyWith(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 4,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(0, 4),
                                          blurRadius: 20,
                                          color: AppConstants.rankElBatal
                                              .withOpacity(0.8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Text(
                                  'GAMIFICATION',
                                  style: AppConstants.cardTitle.copyWith(
                                    color: rankColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: size.height * 0.02),

                    // شخصية البطل مع animation
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: Container(
                            width: size.width * 0.85,
                            height: size.height * 0.35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: rankColor.withOpacity(0.4),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Glow effect
                                Center(
                                  child: Container(
                                    width: size.width * 0.6,
                                    height: size.width * 0.6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          rankColor.withOpacity(0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // الشخصية
                                Center(
                                  child: Image.asset(
                                    'assets/img/GameCharacters/ElBatal.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Gaming Features Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildFeatureCard(
                            context: context,
                            icon: Icons.emoji_events_rounded,
                            title: 'Ranks',
                            subtitle: 'View All',
                            color: AppConstants.rankLegend,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const GameRanks()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildFeatureCard(
                            context: context,
                            icon: Icons.leaderboard_rounded,
                            title: 'Leaderboard',
                            subtitle: 'Top Players',
                            color: AppConstants.primaryCyan,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const GameLeaderBoard()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.03),

                    // زر Explore الرئيسي مع animation
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: size.width * 0.7,
                            height: 65,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppConstants.primaryBlue,
                                  AppConstants.primaryCyan,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppConstants.primaryBlue.withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const GameRanks()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.rocket_launch_rounded,
                                    color: AppConstants.textOnDark,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'START YOUR JOURNEY',
                                    style: AppConstants.cardTitle.copyWith(
                                      color: AppConstants.textOnDark,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Quote تحفيزية
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppConstants.backgroundDark.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: rankColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            color: rankColor,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Every XP brings you closer to becoming El Batal',
                            style: AppConstants.bodyText.copyWith(
                              color: AppConstants.textOnDark.withOpacity(0.9),
                              fontSize: 15,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '— Stay Focused, Stay Determined',
                            style: AppConstants.smallText.copyWith(
                              color: rankColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 170,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: AppConstants.textOnDark,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppConstants.cardTitle.copyWith(
                color: AppConstants.textOnDark,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppConstants.smallText.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
