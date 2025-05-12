import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studymate/pages/LoginPage.dart';
import '../../Classes/User.dart';
import '../CollageInformatio.dart';

class RegisterPage extends StatefulWidget {
  final User user;
  const RegisterPage({
    super.key,
    required this.user,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  // ألوان البراندينج
 static  const Color blue1 = Color(0xFF1c74bb);
 static  const Color blue2 = Color(0xFF165d96);
 static  const Color cyan1 = Color(0xFF18bebc);
 static const Color cyan2 = Color(0xFF139896);
 static const Color black = Color(0xFF000000);
 static const Color white = Color(0xFFFFFFFF);

  final _formKey = GlobalKey<FormState>(); // مفتاح النموذج للتحقق

  @override
  void dispose() {
    // التخلص من المتحكمات
    fullNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  void validateAndProceed() {
    if (_formKey.currentState!.validate()) {
      widget.user.fullName = fullNameController.text;
      widget.user.phoneNumber = phoneController.text;
      widget.user.role = 'student';
      widget.user.address = addressController.text;
      widget.user.birthDate = birthDateController.text;

      // الانتقال إلى الصفحة التالية
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CollageInformation(
            user: widget.user,
          ),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Select your birth date',
    );
    if (pickedDate != null) {
      setState(() {
        birthDateController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // حجم الشاشة للتصميم المتجاوب
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: size.height * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // زر العودة
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: size.height * 0.02),
              // العنوان
              Center(
                child: Column(
                  children: [
                    Text(
                      'Almost There!',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Personal Information',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.04),
              // نموذج التسجيل
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // حقل الاسم الكامل
                    TextFormField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    // حقل رقم الهاتف
                    TextFormField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number.';
                        } else if (!RegExp(r'^(010|011|012|015)\d{8}$').hasMatch(value)) {
                          return 'Phone number must be 11 digits and start with 010, 011, 012, or 015.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    // حقل تاريخ الميلاد مع منتقي التاريخ
                    TextFormField(
                      controller: birthDateController,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your date of birth.';
                        }
                        DateTime dob = DateTime.parse(value);
                        if (dob.isAfter(DateTime.now())) {
                          return 'Date of birth must be in the past.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.025),
                    // حقل العنوان
                    TextFormField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
                        prefixIcon: const Icon(Icons.home_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: size.height * 0.04),
                    // زر التالي
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: validateAndProceed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue2,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Next',
                          style: GoogleFonts.leagueSpartan(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.05),
              // لديك حساب بالفعل؟
              Center(
                child: Column(
                  children: [
                    Text(
                      'Already have an account?',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 16,
                        color: black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {
                        // الرجوع إلى صفحة تسجيل الدخول
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: blue2, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 16,
                          color: blue2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}