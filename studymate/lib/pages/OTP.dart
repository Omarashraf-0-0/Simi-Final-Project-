import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OTP extends StatefulWidget {
  const OTP({Key? key}) : super(key: key);

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  // ألوان البراندينج
  final Color blue1 = const Color(0xFF1c74bb);
  final Color blue2 = const Color(0xFF165d96);
  final Color cyan1 = const Color(0xFF18bebc);
  final Color cyan2 = const Color(0xFF139896);
  final Color black = const Color(0xFF000000);
  final Color white = const Color(0xFFFFFFFF);

  final _formKey = GlobalKey<FormState>();
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  @override
  void dispose() {
    // تنظيف المتحكمات وعناصر الـ focus
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _submitOTP() {
    if (_formKey.currentState!.validate()) {
      String otpCode = _controllers.map((controller) => controller.text).join();
      // نفذ عملية التحقق من OTP هنا
      // على سبيل المثال، إرسال OTP إلى الخادم للتحقق
      print('OTP Entered: $otpCode');

      // لإظهار رسالة نجاح أو الانتقال إلى الصفحة التالية
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP Verified Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // يمكنك توجيه المستخدم إلى الصفحة التالية هنا
    }
  }

  @override
  Widget build(BuildContext context) {
    // حجم الشاشة للتصميم المتجاوب
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: blue2,
        title: Text(
          'Verify OTP',
          style: GoogleFonts.leagueSpartan(
            color: white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: size.height * 0.05),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // عنوان الصفحة
              Text(
                'Enter the 6-digit code sent to your email',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 18,
                  color: black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.04),
              // حقول إدخال OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return _buildOTPField(index);
                }),
              ),
              SizedBox(height: size.height * 0.04),
              // زر التحقق
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue2,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Verify',
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              // رابط لإعادة إرسال OTP
              TextButton(
                onPressed: () {
                  // نفذ عملية إعادة إرسال OTP هنا
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('OTP Resent Successfully!'),
                      backgroundColor: blue2,
                    ),
                  );
                },
                child: Text(
                  'Resend Code',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 16,
                    color: blue2,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return SizedBox(
      width: 50,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          counterText: '',
        ),
        style: GoogleFonts.leagueSpartan(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: black,
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '';
          }
          return null;
        },
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}