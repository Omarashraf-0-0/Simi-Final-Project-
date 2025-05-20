class Student {
  String? fullName;
  String? username;
  String? password;
  int? id;
  int? age;
  String? birthDate;
  String? role;
  String? email;
  String? phoneNumber;
  String? address;
  String? gender;
  String? collage;
  String? university;
  String? major;
  int? term_level;
  String? pfp;
  int? xp;
  int? level;
  String? title;
  String? registrationNumber;
  Student._internal();
  // 2. The single static instance
  static final Student _instance = Student._internal();

  // 3. Factory constructor to return the same instance
  factory Student() {
    return _instance;
  }
  void initialize({
    String? username,
    String? password,
    String? fullName,
    String? role,
    String? email,
    String? phoneNumber,
    String? address,
    String? gender,
    String? collage,
    String? university,
    String? major,
    int? term_level,
    String? pfp,
    int? xp,
    int? level,
    String? title,
    String? registrationNumber,
    String? birthDate,
  }) {
    this.username = username;
    this.password = password;
    this.fullName = fullName;
    this.role = role;
    this.email = email;
    this.phoneNumber = phoneNumber;
    this.address = address;
    this.gender = gender;
    this.collage = collage;
    this.university = university;
    this.major = major;
    this.term_level = term_level;
    this.pfp = pfp;
    this.xp = xp;
    this.level = level;
    this.title = title;
    this.registrationNumber = registrationNumber;
    this.birthDate = birthDate;
  }

}