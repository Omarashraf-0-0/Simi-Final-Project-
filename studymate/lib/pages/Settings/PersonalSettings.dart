import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:studymate/pages/UserUpdater.dart';
import 'package:studymate/theme/app_constants.dart';

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
        dateOfBirthController.text =
            pickedDate.toLocal().toString().split(' ')[0];
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
      appBar: AppConstants.buildAppBar(
        title: 'Personal Settings',
        leading: AppConstants.buildBackButton(context),
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
                  style: AppConstants.cardTitle.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // حقل الاسم الكامل
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // حقل رقم الهاتف
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              // حقل تاريخ الميلاد مع منتقي التاريخ
              TextField(
                controller: dateOfBirthController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 20),
              // حقل العنوان
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // زر حفظ التغييرات
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlueDark,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: AppConstants.subtitle.copyWith(
                      color: AppConstants.textOnPrimary,
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
