import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:studymate/pages/Resuorces/CourseContent.dart';
import 'package:studymate/pages/Resuorces/Resources.dart';
import 'package:studymate/pages/ScheduleManager/ScheduleManager.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class Homebody extends StatefulWidget {
  const Homebody({super.key});
  @override
  State<Homebody> createState() => _HomebodyState();
}

class _HomebodyState extends State<Homebody>
    with SingleTickerProviderStateMixin {
  // Brand colors - Enhanced modern palette
  final Color primaryColor = const Color(0xFF1c74bb);
  final Color secondaryColor = const Color(0xFF165d96);
  final Color accentColor = const Color(0xFF18bebc);
  final Color accentColor2 = const Color(0xFF139896);
  final Color backgroundColor = const Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;

  // State variables
  List<dynamic> _events = [];
  List<String> courses = [];
  List<String> coursesIndex = [];
  List<dynamic> _recentQuizzes = [];
  bool _isLoading = true;
  bool _isLoadingQuizzes = true;
  bool _isLoadingCourses = true;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Loading shimmer effect
  Widget _buildLoadingShimmer({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.primary,
      highlightColor: Theme.of(context).colorScheme.secondary,
      child: child,
    );
  }

  // Schedule Loader Card
  Widget _buildScheduleLoaderCard() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: _buildLoadingShimmer(
        child: Container(
          width: 200,
          height: 120,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 20,
                color: Colors.white,
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Courses Loader Card
  Widget _buildCoursesLoaderCard() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: _buildLoadingShimmer(
        child: Container(
          width: 250,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Stack(
            children: [
              Container(
                width: 250,
                height: 180,
                color: Colors.white,
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  width: 150,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quizzes Loader Card
  Widget _buildQuizzesLoaderCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _buildLoadingShimmer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              color: Colors.white,
            ),
            title: Container(
              width: 100,
              height: 20,
              color: Colors.white,
            ),
            subtitle: Container(
              width: 60,
              height: 16,
              color: Colors.white,
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Load all data on init
  Future<void> _loadData() async {
    try {
      await Future.wait([
        _fetchTodaysSchedule(),
        _fetchRecentCourses(),
        _fetchRecentQuizzes()
      ]);
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Section with Gradient Background
          _buildHeroSection(),

          // Stats Cards Row with proper spacing
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: _buildStatsCards(),
          ),
          const SizedBox(height: 25),

          // Schedule section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionHeader('Today\'s Schedule',
                icon: Icons.calendar_today_rounded,
                onViewAll: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ScheduleView()))),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 140,
            child: _isLoading
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: 3,
                    itemBuilder: (_, __) => _buildScheduleLoaderCard(),
                  )
                : _buildScheduleSection(),
          ),
          const SizedBox(height: 30),

          // Courses section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionHeader('Recent Courses',
                icon: Icons.book_rounded,
                onViewAll: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => Resources()))),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 200,
            child: _isLoadingCourses
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: 3,
                    itemBuilder: (_, __) => _buildCoursesLoaderCard(),
                  )
                : _buildCoursesSection(),
          ),
          const SizedBox(height: 30),

          // Quizzes section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child:
                _buildSectionHeader('Recent Quizzes', icon: Icons.quiz_rounded),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _isLoadingQuizzes
                ? Column(
                    children:
                        List.generate(3, (_) => _buildQuizzesLoaderCard()),
                  )
                : _buildQuizzesSection(),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // Get gradient colors based on rank title (matching Gamification colors)
  List<Color> _getRankGradientColors(String title) {
    switch (title.toLowerCase()) {
      case 'el batal':
      case 'البطل':
        return [const Color(0xFFb3141c), const Color(0xFF8B0000)];
      case 'legend':
        return [const Color(0xFFFFD700), const Color(0xFFFFB300)];
      case 'mentor':
        return [const Color(0xFF6F42C1), const Color(0xFF5A2D9C)];
      case 'expert':
        return [const Color(0xFFFD7E14), const Color(0xFFE56B00)];
      case 'challenger':
        return [const Color(0xFFFFC107), const Color(0xFFFF9800)];
      case 'achiever':
        return [const Color(0xFF28A745), const Color(0xFF1E7E34)];
      case 'explorer':
        return [const Color(0xFF007BFF), const Color(0xFF0056B3)];
      case 'newcomer':
      case 'جديد':
        return [const Color(0xFF808080), const Color(0xFF5A5A5A)];
      default:
        return [const Color(0xFF808080), const Color(0xFF5A5A5A)];
    }
  }

  // Hero Section with user info and gradient
  Widget _buildHeroSection() {
    final username = Hive.box('userBox').get('username') ?? 'User';
    final title = Hive.box('userBox').get('title') ?? 'Newcomer';

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            secondaryColor,
            accentColor2,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting and profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.military_tech_rounded,
                                color: Colors.amber[300],
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rank badge with dynamic colors
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _getRankGradientColors(title),
                      ),
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              _getRankGradientColors(title)[0].withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.military_tech_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Stats Cards (XP, Streak, etc.)
  Widget _buildStatsCards() {
    final xp = Hive.box('userBox').get('xp') ?? 0;
    final dayStreak = Hive.box('userBox').get('Day_Streak') ?? 0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.stars_rounded,
              label: 'Total XP',
              value: xp.toString(),
              color: Colors.amber,
              gradient: [Colors.amber[400]!, Colors.orange[400]!],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              icon: Icons.local_fire_department_rounded,
              label: 'Day Streak',
              value: dayStreak.toString(),
              color: Colors.deepOrange,
              gradient: [Colors.deepOrange[400]!, Colors.red[400]!],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cardColor,
            color.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // Fetch methods and other widgets remain the same...

  // Format time string to 12-hour format
  String _formatTime(String time) {
    try {
      final parsedTime = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('hh:mm a').format(parsedTime);
    } catch (e) {
      return 'Invalid Time';
    }
  }

  // Get background image for course card
  String _getCourseBackgroundImage(int index) {
    final images = [
      'assets/img/bg1.jpg',
      'assets/img/bg2.jpg',
      'assets/img/bg3.jpg',
      'assets/img/bg4.jpg',
      'assets/img/bg5.jpg',
      'assets/img/bg6.jpg',
      'assets/img/bg7.jpg',
      'assets/img/bg8.jpg',
    ];
    return images[index % images.length];
  }

  // Get color for event card based on type
  Color _getEventCardColor(String? type) {
    switch (type) {
      case 'Lecture':
        return primaryColor;
      case 'Assignment':
        return accentColor2;
      case 'Exam':
        return Colors.redAccent;
      default:
        return secondaryColor;
    }
  }

  Widget _buildSectionHeader(String title,
      {IconData? icon, VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                color: secondaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (onViewAll != null)
          InkWell(
            onTap: onViewAll,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 14,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: accentColor,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    if (_events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 50,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 12),
                Text(
                  'No tasks for today.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      physics: const BouncingScrollPhysics(),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        final color = _getEventCardColor(event['Type']);

        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            width: 220,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // Navigate to event details
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Event type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          event['Type'] ?? 'Event',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Event title
                      Expanded(
                        child: Text(
                          event['Title'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Time with icon
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _formatTime(event['StartTime'] ?? ''),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Color _getEventCardColor(String? type) {
  //   switch (type) {
  //     case 'Lecture':
  //       return primaryColor;
  //     case 'Assignment':
  //       return accentColor2;
  //     case 'Exam':
  //       return Colors.redAccent;
  //     default:
  //       return secondaryColor;
  //   }
  // }

  // Widget _buildCoursesList() {
  //   return SizedBox(
  Widget _buildCoursesSection() {
    if (courses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 50,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 12),
                Text(
                  'No recent courses.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      physics: const BouncingScrollPhysics(),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Hive.box('userBox').put('COId', coursesIndex[index]);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CourseContent()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image
                    Image.asset(
                      _getCourseBackgroundImage(index),
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                            Colors.black.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Book icon badge
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const Spacer(),
                          // Course title
                          Text(
                            courses[index],
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Arrow indicator
                          Row(
                            children: [
                              Text(
                                'View Content',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: 18,
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildQuizzesSection() {
    if (_recentQuizzes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.quiz_rounded,
                size: 50,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 12),
              Text(
                'No recent quizzes.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _recentQuizzes.map((quiz) {
        final score = quiz['Score'] ?? 0;
        final totalScore = quiz['TotalScore'] ?? 100;
        final percentage =
            totalScore > 0 ? (score / totalScore * 100).round() : 0;

        // Color based on performance
        Color getScoreColor() {
          if (percentage >= 80) return Colors.green;
          if (percentage >= 60) return accentColor;
          if (percentage >= 40) return Colors.orange;
          return Colors.red;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  // Navigate to quiz details
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Quiz icon with gradient
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              accentColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.quiz_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Quiz info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quiz['QuizTitle'] ?? 'Quiz ${quiz['QID']}',
                              style: TextStyle(
                                fontSize: 17,
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: getScoreColor().withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$percentage%',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: getScoreColor(),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$score / $totalScore',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Arrow icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: primaryColor,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Update fetch methods to handle loading states

  Future<void> _fetchTodaysSchedule() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final userID = Hive.box('userBox').get('id');
      final url =
          'https://alyibrahim.pythonanywhere.com/schedule?user_id=$userID&start_date=$today&end_date=$today';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _events = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _events = [];
      });
      print('Error: $e');
    }
  }

  Future<void> _fetchRecentCourses() async {
    try {
      final username = Hive.box('userBox').get('username');
      final response = await http.post(
        Uri.parse('https://alyibrahim.pythonanywhere.com/recentCourses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          courses = List<String>.from(data['courses']);
          coursesIndex = (data['CourseID'] as List)
              .map((item) => item['COId'].toString())
              .toList();
          _isLoadingCourses = false;
        });
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      setState(() {
        _isLoadingCourses = false;
      });
      print('Error: $e');
    }
  }

  Future<void> _fetchRecentQuizzes() async {
    try {
      final userID = Hive.box('userBox').get('id');
      final response = await http.get(
        Uri.parse(
            'https://alyibrahim.pythonanywhere.com/get_recent_quizzes?user_id=$userID'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _recentQuizzes = data['quizzes'];
            _isLoadingQuizzes = false;
          });
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load quizzes');
      }
    } catch (e) {
      setState(() {
        _isLoadingQuizzes = false;
        _recentQuizzes = [];
      });
      print('Error: $e');
    }
  }
}
