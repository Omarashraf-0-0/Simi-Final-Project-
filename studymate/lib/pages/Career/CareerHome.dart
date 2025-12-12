// Import necessary packages
import 'package:flutter/material.dart';
import 'CareerJob.dart'; // Import the CareerJob page
import 'CV.dart';
import '../../theme/app_constants.dart';

class CareerHome extends StatefulWidget {
  const CareerHome({super.key});

  @override
  _CareerHomeState createState() => _CareerHomeState();
}

class _CareerHomeState extends State<CareerHome>
    with SingleTickerProviderStateMixin {
  String? selectedBox; // To keep track of the selected box
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildFloatingIcon(IconData icon, int delay) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 10 * _animationController.value - 5),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 35,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Career Center',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.info_outline, color: Colors.white, size: 24),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gradient Header with Icons
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1c74bb),
                    Color(0xFF165d96),
                    Color(0xFF18bebc),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1c74bb).withOpacity(0.4),
                    blurRadius: 25,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 35),
                  child: Column(
                    children: [
                      // Animated Icons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFloatingIcon(Icons.business_center, 0),
                          _buildFloatingIcon(Icons.school, 200),
                          _buildFloatingIcon(Icons.trending_up, 400),
                        ],
                      ),
                      SizedBox(height: 25),
                      // Title with gradient text effect
                      Text(
                        'Start Your',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Career Journey',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Choose your path to success',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1c74bb), Color(0xFF18bebc)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.explore_rounded,
                        color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Choose Your Path',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1c74bb),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
            // Two enhanced cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // First card: Find a Job
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedBox = 'Find a Job';
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: selectedBox == 'Find a Job' ? 365 : 320,
                          decoration: BoxDecoration(
                            gradient: selectedBox == 'Find a Job'
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF1c74bb),
                                      Color(0xFF4a90e2),
                                    ],
                                  )
                                : null,
                            color: selectedBox != 'Find a Job'
                                ? Colors.white
                                : null,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: selectedBox == 'Find a Job'
                                  ? Color(0xFF1c74bb)
                                  : Colors.grey.shade300,
                              width: selectedBox == 'Find a Job' ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: selectedBox == 'Find a Job'
                                    ? Color(0xFF1c74bb).withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.2),
                                blurRadius:
                                    selectedBox == 'Find a Job' ? 25 : 12,
                                offset: Offset(
                                    0, selectedBox == 'Find a Job' ? 12 : 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: selectedBox == 'Find a Job'
                                        ? Colors.white.withOpacity(0.25)
                                        : Color(0xFF1c74bb).withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: selectedBox == 'Find a Job'
                                            ? Colors.white.withOpacity(0.3)
                                            : Color(0xFF1c74bb)
                                                .withOpacity(0.2),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.work_rounded,
                                    size: 50,
                                    color: selectedBox == 'Find a Job'
                                        ? Colors.white
                                        : Color(0xFF1c74bb),
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Find a Job',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: selectedBox == 'Find a Job'
                                        ? Colors.white
                                        : Color(0xFF2c3e50),
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Search and apply\nfor your dream job',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: selectedBox == 'Find a Job'
                                        ? Colors.white.withOpacity(0.95)
                                        : Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                ),
                                if (selectedBox == 'Find a Job') ...[
                                  SizedBox(height: 18),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_rounded,
                                            color: Colors.white, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'Selected',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Second card: Create a CV
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedBox = 'Create a CV';
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: selectedBox == 'Create a CV' ? 365 : 320,
                          decoration: BoxDecoration(
                            gradient: selectedBox == 'Create a CV'
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF18bebc),
                                      Color(0xFF4ecdc4),
                                    ],
                                  )
                                : null,
                            color: selectedBox != 'Create a CV'
                                ? Colors.white
                                : null,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: selectedBox == 'Create a CV'
                                  ? Color(0xFF18bebc)
                                  : Colors.grey.shade300,
                              width: selectedBox == 'Create a CV' ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: selectedBox == 'Create a CV'
                                    ? Color(0xFF18bebc).withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.2),
                                blurRadius:
                                    selectedBox == 'Create a CV' ? 25 : 12,
                                offset: Offset(
                                    0, selectedBox == 'Create a CV' ? 12 : 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: selectedBox == 'Create a CV'
                                        ? Colors.white.withOpacity(0.25)
                                        : Color(0xFF18bebc).withOpacity(0.12),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: selectedBox == 'Create a CV'
                                            ? Colors.white.withOpacity(0.3)
                                            : Color(0xFF18bebc)
                                                .withOpacity(0.2),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.description_rounded,
                                    size: 50,
                                    color: selectedBox == 'Create a CV'
                                        ? Colors.white
                                        : Color(0xFF18bebc),
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Create a CV',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: selectedBox == 'Create a CV'
                                        ? Colors.white
                                        : Color(0xFF2c3e50),
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Build your\nprofessional CV',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: selectedBox == 'Create a CV'
                                        ? Colors.white.withOpacity(0.95)
                                        : Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                ),
                                if (selectedBox == 'Create a CV') ...[
                                  SizedBox(height: 18),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_rounded,
                                            color: Colors.white, size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'Selected',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
            const SizedBox(height: 40),
            // Enhanced Continue button with better design
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 1000),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 65,
                  decoration: BoxDecoration(
                    gradient: selectedBox != null
                        ? LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF1c74bb),
                              Color(0xFF165d96),
                            ],
                          )
                        : null,
                    color: selectedBox == null ? Colors.grey.shade300 : null,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: selectedBox != null
                        ? [
                            BoxShadow(
                              color: Color(0xFF1c74bb).withOpacity(0.5),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: selectedBox != null
                          ? () {
                              // Handle navigation based on selection
                              if (selectedBox == 'Find a Job') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CareerJob()),
                                );
                              } else if (selectedBox == 'Create a CV') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CV()),
                                );
                              }
                            }
                          : null,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selectedBox != null)
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.rocket_launch_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            SizedBox(width: selectedBox != null ? 12 : 0),
                            Text(
                              selectedBox != null
                                  ? 'Get Started'
                                  : 'Select an Option',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: selectedBox != null
                                    ? Colors.white
                                    : Colors.grey.shade500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (selectedBox != null) ...[
                              SizedBox(width: 12),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Info Section
            if (selectedBox != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          selectedBox == 'Find a Job'
                              ? Color(0xFF1c74bb).withOpacity(0.1)
                              : Color(0xFF18bebc).withOpacity(0.1),
                          selectedBox == 'Find a Job'
                              ? Color(0xFF1c74bb).withOpacity(0.05)
                              : Color(0xFF18bebc).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selectedBox == 'Find a Job'
                            ? Color(0xFF1c74bb).withOpacity(0.3)
                            : Color(0xFF18bebc).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: selectedBox == 'Find a Job'
                                ? Color(0xFF1c74bb).withOpacity(0.15)
                                : Color(0xFF18bebc).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.lightbulb_outline_rounded,
                            color: selectedBox == 'Find a Job'
                                ? Color(0xFF1c74bb)
                                : Color(0xFF18bebc),
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedBox == 'Find a Job'
                                    ? 'Job Search Tips'
                                    : 'CV Building Tips',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: selectedBox == 'Find a Job'
                                      ? Color(0xFF1c74bb)
                                      : Color(0xFF18bebc),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                selectedBox == 'Find a Job'
                                    ? 'Explore opportunities matching your skills'
                                    : 'Create a professional CV that stands out',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }
}
