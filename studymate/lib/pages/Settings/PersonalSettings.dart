import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:studymate/pages/UserUpdater.dart';

class PersonalSettings extends StatefulWidget {
  const PersonalSettings({super.key});

  @override
  _PersonalSettingsState createState() => _PersonalSettingsState();
}

class _PersonalSettingsState extends State<PersonalSettings>
    with SingleTickerProviderStateMixin {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool _isLoading = false;

  // Brand colors
  final Color primaryColor = const Color(0xFF1c74bb);
  final Color secondaryColor = const Color(0xFF165d96);
  final Color accentColor = const Color(0xFF18bebc);
  final Color backgroundColor = const Color(0xFFF5F7FA);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _userUpdater =
      UserUpdater(url: 'https://alyibrahim.pythonanywhere.com/update_user');

  @override
  void initState() {
    super.initState();
    // تهيئة المتحكمات بالقيم من Hive
    fullNameController.text = Hive.box('userBox').get('fullName') ?? '';
    phoneNumberController.text = Hive.box('userBox').get('phone_number') ?? '';
    dateOfBirthController.text = Hive.box('userBox').get('birthDate') ?? '';
    addressController.text = Hive.box('userBox').get('address') ?? '';

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  bool _isPhoneValid(String phone) {
    return phone.isEmpty || RegExp(r'^[0-9+\-\(\)\s]{10,15}$').hasMatch(phone);
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> updateData() async {
    // Validation
    if (fullNameController.text.isEmpty) {
      _showErrorSnackBar('Please enter your full name');
      return;
    }

    if (!_isPhoneValid(phoneNumberController.text)) {
      _showErrorSnackBar('Please enter a valid phone number');
      return;
    }

    setState(() => _isLoading = true);

    final Map<String, dynamic> requestData = {
      'Query': 'update_user',
      'username': Hive.box('userBox').get('username'),
      'phone_number': phoneNumberController.text,
      'address': addressController.text,
      'fullName': fullNameController.text,
      'birthDate': dateOfBirthController.text,
    };

    try {
      await _userUpdater.updateUserData(
        requestData: requestData,
        context: context,
      );
      _showSuccessSnackBar('Personal information updated successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to update information');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // دالة اختيار التاريخ
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate =
        DateTime.now().subtract(const Duration(days: 6570)); // 18 years ago
    if (dateOfBirthController.text.isNotEmpty) {
      final parsedDate = DateTime.tryParse(dateOfBirthController.text);
      if (parsedDate != null) {
        initialDate = parsedDate;
      }
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Select your birth date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: secondaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        dateOfBirthController.text =
            pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    dateOfBirthController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Modern App Bar with Gradient
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
                                Icons.tune_rounded,
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
                                  const Text(
                                    'Personal Settings',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Customize your preferences',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w400,
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

              // Form Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information Card
                        _buildSectionCard(
                          title: 'Basic Information',
                          icon: Icons.badge_rounded,
                          iconColor: const Color(0xFF667eea),
                          children: [
                            _buildModernTextField(
                              controller: fullNameController,
                              label: 'Full Name',
                              icon: Icons.person_rounded,
                              iconColor: const Color(0xFF667eea),
                            ),
                            const SizedBox(height: 16),
                            _buildModernTextField(
                              controller: phoneNumberController,
                              label: 'Phone Number',
                              icon: Icons.phone_rounded,
                              iconColor: const Color(0xFF667eea),
                              keyboardType: TextInputType.phone,
                              suffixIcon: phoneNumberController.text.isNotEmpty
                                  ? Icon(
                                      _isPhoneValid(phoneNumberController.text)
                                          ? Icons.check_circle
                                          : Icons.error,
                                      color: _isPhoneValid(
                                              phoneNumberController.text)
                                          ? Colors.green
                                          : Colors.red,
                                    )
                                  : null,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Additional Details Card
                        _buildSectionCard(
                          title: 'Additional Details',
                          icon: Icons.info_rounded,
                          iconColor: const Color(0xFF4facfe),
                          children: [
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: _buildModernTextField(
                                  controller: dateOfBirthController,
                                  label: 'Date of Birth',
                                  icon: Icons.cake_rounded,
                                  iconColor: const Color(0xFF4facfe),
                                  suffixIcon: const Icon(
                                    Icons.calendar_today_rounded,
                                    color: Color(0xFF4facfe),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildModernTextField(
                              controller: addressController,
                              label: 'Address',
                              icon: Icons.home_rounded,
                              iconColor: const Color(0xFF4facfe),
                              maxLines: 3,
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

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
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Updating information...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: secondaryColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 15,
          color: secondaryColor,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: iconColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: TextStyle(
            color: iconColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (value) {
          // Trigger rebuild for validation
          setState(() {});
        },
      ),
    );
  }
}
