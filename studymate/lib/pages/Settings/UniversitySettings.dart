import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:studymate/pages/UserUpdater.dart';

class Universitysettings extends StatefulWidget {
  const Universitysettings({super.key});

  @override
  _UniversitysettingsState createState() => _UniversitysettingsState();
}

class _UniversitysettingsState extends State<Universitysettings>
    with SingleTickerProviderStateMixin {
  String? selectedUniversity;
  String? selectedCollege;
  String? selectedMajor;
  String? selectedTermLevel;

  final TextEditingController registrationNumberController =
      TextEditingController();

  bool _isLoading = false;
  late AnimationController _animationController;

  // Brand colors
  final Color primaryColor = const Color(0xFF1c74bb);
  final Color secondaryColor = const Color(0xFF165d96);
  final Color accentColor = const Color(0xFF18bebc);
  final Color backgroundColor = const Color(0xFFF5F7FA);

  final List<String> universities = ['AAST', 'AUC', 'GUC', 'MIU', 'MSA'];
  final List<String> colleges = [
    'Engineering',
    'Business',
    'Computing',
    'Media',
    'Pharmacy'
  ];
  final List<String> majors = [
    'Computer Science',
    'Business Administration',
    'Media',
    'Pharmacy',
    'Engineering'
  ];
  final List<String> termLevels = [
    'Prep',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10'
  ];

  final _userUpdater =
      UserUpdater(url: 'https://alyibrahim.pythonanywhere.com/update_user');

  final RegExp inputRegExp = RegExp(r'^[a-zA-Z0-9]+$');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..forward();

    // Initialize the variables from Hive
    selectedUniversity = Hive.box('userBox').get('university');
    selectedCollege = Hive.box('userBox').get('college');
    selectedMajor = Hive.box('userBox').get('major');
    selectedTermLevel = '${Hive.box('userBox').get('term_level')}';
    registrationNumberController.text =
        Hive.box('userBox').get('Registration_Number') ?? '';
  }

  bool validateInput(String input) {
    return inputRegExp.hasMatch(input);
  }

  Future<void> updateData() async {
    final username = Hive.box('userBox').get('username');
    if (!validateInput(username) ||
        !validateInput(registrationNumberController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Invalid input'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final Map<String, dynamic> requestData = {
      'username': username,
      'university': selectedUniversity,
      'college': selectedCollege,
      'major': selectedMajor,
      'term_level': selectedTermLevel,
      'Registration_Number': registrationNumberController.text,
    };

    await _userUpdater.updateUserData(
      requestData: requestData,
      context: context,
    );

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    registrationNumberController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Modern Gradient Header
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      secondaryColor,
                      accentColor,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'University Settings',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Manage your academic information',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
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
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _animationController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // University Information Card
                    _buildSectionCard(
                      context: context,
                      title: 'University Information',
                      icon: Icons.school_rounded,
                      color: Color(0xFF667eea),
                      children: [
                        _buildModernDropdown(
                          context: context,
                          label: 'University',
                          icon: Icons.school,
                          iconColor: Color(0xFF667eea),
                          value: selectedUniversity,
                          items: universities,
                          onChanged: (value) =>
                              setState(() => selectedUniversity = value),
                        ),
                        SizedBox(height: 16),
                        _buildModernDropdown(
                          context: context,
                          label: 'College',
                          icon: Icons.account_balance,
                          iconColor: Color(0xFF667eea),
                          value: selectedCollege,
                          items: colleges,
                          onChanged: (value) =>
                              setState(() => selectedCollege = value),
                        ),
                        SizedBox(height: 16),
                        _buildModernDropdown(
                          context: context,
                          label: 'Major',
                          icon: Icons.menu_book,
                          iconColor: Color(0xFF667eea),
                          value: selectedMajor,
                          items: majors,
                          onChanged: (value) =>
                              setState(() => selectedMajor = value),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Academic Details Card
                    _buildSectionCard(
                      context: context,
                      title: 'Academic Details',
                      icon: Icons.assignment_rounded,
                      color: Color(0xFFf5576c),
                      children: [
                        _buildModernDropdown(
                          context: context,
                          label: 'Term Level',
                          icon: Icons.bar_chart,
                          iconColor: Color(0xFFf5576c),
                          value: selectedTermLevel,
                          items: termLevels,
                          displayMapping: (value) =>
                              value == 'Prep' ? 'Preparatory' : 'Term $value',
                          onChanged: (value) =>
                              setState(() => selectedTermLevel = value),
                        ),
                        SizedBox(height: 16),
                        _buildModernTextField(
                          controller: registrationNumberController,
                          label: 'Registration Number',
                          icon: Icons.confirmation_num,
                          iconColor: Color(0xFFf5576c),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Save Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, accentColor],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : updateData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save_rounded,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDropdown({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color iconColor,
    required String? value,
    required List<String> items,
    String Function(String)? displayMapping,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: iconColor.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: iconColor.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: iconColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(displayMapping != null ? displayMapping(item) : item),
        );
      }).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
      icon: Icon(Icons.arrow_drop_down_rounded, color: iconColor),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: iconColor.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: iconColor.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: iconColor, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
