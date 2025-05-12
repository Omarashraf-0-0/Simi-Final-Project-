import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:studymate/pages/UserUpdater.dart';

class PersonalSettings extends StatefulWidget {
  const PersonalSettings({super.key});

  @override
  _PersonalSettingsState createState() => _PersonalSettingsState();
}

class _PersonalSettingsState extends State<PersonalSettings> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final _userUpdater = UserUpdater(url: 'https://alyibrahim.pythonanywhere.com/update_user');

  // ألوان البراندينج
  const Color blue1 = Color(0xFF1c74bb);
  const Color blue2 = Color(0xFF165d96);
  const Color cyan1 = Color(0xFF18bebc);
  const Color cyan2 = Color(0xFF139896);
  const Color black = Color(0xFF000000);
  const Color white = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    // تهيئة المتحكمات بالقيم من Hive
    fullNameController.text = Hive.box('userBox').get('fullName') ?? '';
    phoneNumberController.text = Hive.box('userBox').get('phone_number') ?? '';
    dateOfBirthController.text = Hive.box('userBox').get('birthDate') ?? '';
    addressController.text = Hive.box('userBox').get('address') ?? '';
  }

  Future<void> updateData() async {
    final Map<String, dynamic> requestData = {
      'Query': 'update_user',
      'username': Hive.box('userBox').get('username'),
      'phone_number': phoneNumberController.text,
      'address': addressController.text,
      'fullName': fullNameController.text,
      'birthDate': dateOfBirthController.text,
    };

    await _userUpdater.updateUserData(
      requestData: requestData,
      context: context,
    );
  }

  // دالة اختيار التاريخ
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
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
    );
    if (pickedDate != null && pickedDate != initialDate) {
      setState(() {
        dateOfBirthController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  void dispose() {
    // التخلص من المتحكمات
    fullNameController.dispose();
    phoneNumberController.dispose();
    dateOfBirthController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Personal Settings',
          style: GoogleFonts.leagueSpartan(
            color: white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // العنوان
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Personal Information',
                  style: GoogleFonts.leagueSpartan(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // حقل الاسم الكامل
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // حقل رقم الهاتف
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              // حقل تاريخ الميلاد مع منتقي التاريخ
              TextField(
                controller: dateOfBirthController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              // حقل العنوان
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: const Icon(Icons.home),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // زر حفظ التغييرات
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue2,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
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
      ),
    );
  }
}