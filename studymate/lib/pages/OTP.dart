import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:async'; // Import for Timer
import 'dart:convert'; // Import for JSON decoding if needed
import '../Classes/User.dart';
import '../Pop-ups/PopUps_Failed.dart';
import '../Pop-ups/PopUps_Success.dart';
import '../pages/LoginPage.dart';

class OTP extends StatefulWidget {
  final Student? user;
  const OTP({super.key, this.user});

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

  String _serverOTP = ''; // Variable to store the OTP from the server
  Timer? _timer;
  int _start = 60; // Timer start value in seconds
  bool _isOTPLoaded = false; // Flag to check if OTP is loaded
  bool _isTimerRunning = false; // Flag to check if timer is running
  bool _isResendEnabled = false; // Flag to enable/disable resend button

  @override
  void initState() {
    super.initState();
    _fetchOTP(); // Fetch OTP when the page loads
  }

  @override
  void dispose() {
    // تنظيف المتحكمات وعناصر الـ focus
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel(); // Cancel the timer
    super.dispose();
  }

  // Modified _submitOTP function
  void _submitOTP() async {
    if (_formKey.currentState!.validate()) {
      String otpCode = _controllers.map((controller) => controller.text).join();
      // Check if the entered OTP matches the server OTP
      if (otpCode == _serverOTP) {
        // OTP is correct
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP Verified Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Call registerCollegeInfo() to register the user
        await registerCollegeInfo();
        // The registration function handles navigation and popups
      } else {
        // OTP is incorrect
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The OTP is wrong. Try resending it.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> registerCollegeInfo() async {
    final String url = 'https://alyibrahim.pythonanywhere.com/register';

    final Map<String, dynamic> data = {
      'username': widget.user?.username,
      'password': widget.user?.password,
      'fullName': widget.user?.fullName,
      'role': widget.user?.role,
      'email': widget.user?.email,
      'phoneNumber': widget.user?.phoneNumber,
      'address': widget.user?.address,
      'gender': widget.user?.gender,
      'college': widget.user?.collage, // Ensure correct field name
      'university': widget.user?.university,
      'major': widget.user?.major,
      'term_level': 1,
      'pfp': widget.user?.pfp,
      'xp': 0,
      'level': 1,
      'title': 'newbie',
      'registrationNumber': widget.user?.registrationNumber,
      'birthDate': widget.user?.birthDate,
    };
    final body = jsonEncode(data);
    print(body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
        // Navigate back to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
        // Optionally, you can show a success popup
        showSuccessPopup(
          context,
          'Registration Successful',
          'Your account has been created successfully!',
          'Continue',
        );
      } else {
        final responseData = json.decode(response.body);
        showFailedPopup(
          context,
          'Registration Failed',
          responseData['message'],
          'Continue',
        );
      }
    } catch (error) {
      print(error);
      showFailedPopup(
        context,
        'Registration Failed',
        'Failed to register: $error',
        'Continue',
      );
    }
  }

  void _fetchOTP() async {
    try {
      final Map<String, dynamic> requestBody = {
        'fullname': widget.user?.fullName,
        'email': widget.user?.email,
      };
      final response = await http.post(
        Uri.parse('https://alyibrahim.pythonanywhere.com/Send_OTP'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        // Extract the OTP from the JSON response
        setState(() {
          _serverOTP = jsonResponse['OTP']; // Store the OTP from the server
          _isOTPLoaded = true;
          _startTimer(); // Start the timer after OTP is received
          _isResendEnabled =
              false; // Disable resend button while timer is running
        });
        print('OTP Received from Server: $_serverOTP');
      } else {
        print('Failed to fetch OTP. Status code: ${response.statusCode}');
        // Handle error accordingly
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to receive OTP from server.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error fetching OTP: $e');
      // Handle error accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while fetching OTP.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startTimer() {
    _start = 180;
    _isTimerRunning = true;
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (mounted) {
          setState(() {
            if (_start == 0) {
              _timer?.cancel();
              _isTimerRunning = false;
              _isResendEnabled = true; // Enable resend button
            } else {
              _start--;
            }
          });
        }
      },
    );
  }

  void _resendOTP() {
    // Clear the OTP fields
    for (var controller in _controllers) {
      controller.clear();
    }
    // Fetch OTP again
    _fetchOTP();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP Resent Successfully!'),
        backgroundColor: blue2,
      ),
    );
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
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08, vertical: size.height * 0.05),
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
              SizedBox(height: size.height * 0.02),
              // Timer display
              _isTimerRunning
                  ? Text(
                      'Time remaining: $_start secs',
                      style: GoogleFonts.leagueSpartan(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(height: size.height * 0.02),
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
                  onPressed: _isOTPLoaded ? _submitOTP : null,
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
                onPressed: _isResendEnabled
                    ? () {
                        _resendOTP();
                      }
                    : null,
                child: Text(
                  'Resend Code',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 16,
                    color: _isResendEnabled ? blue2 : Colors.grey,
                    decoration: _isResendEnabled
                        ? TextDecoration.underline
                        : TextDecoration.none,
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
        enabled: _isOTPLoaded, // Disable input fields until OTP is loaded
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
