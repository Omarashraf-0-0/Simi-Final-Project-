import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class Job {
  final String title;
  final String company;
  final String location;
  final String description;
  final String redirectUrl;
  final String contractType;
  final String category;

  Job({
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.redirectUrl,
    required this.contractType,
    required this.category,
  });
}

class CareerJob extends StatefulWidget {
  const CareerJob({super.key});

  @override
  _CareerJobState createState() => _CareerJobState();
}

class _CareerJobState extends State<CareerJob> {
  String jobType = 'All';
  String workMode = 'All';
  String countryCode = 'us';
  String countryName = 'United States';
  String profession = '';
  List<Job> jobs = [];
  bool isLoading = false;

  final String appId = '33a454df';
  final String appKey = '1805cb4c51d733cbe670bcab85c8818f';

  Map<String, String> countries = {
    'Australia': 'au',
    'Austria': 'at',
    'Belgium': 'be',
    'Brazil': 'br',
    'Canada': 'ca',
    'France': 'fr',
    'Germany': 'de',
    'India': 'in',
    'Italy': 'it',
    'Mexico': 'mx',
    'Netherlands': 'nl',
    'New Zealand': 'nz',
    'Poland': 'pl',
    'Russia': 'ru',
    'Singapore': 'sg',
    'South Africa': 'za',
    'Switzerland': 'ch',
    'United Kingdom': 'gb',
    'United States': 'us',
  };

  List<String> workModes = ['All', 'Remote', 'Onsite', 'Hybrid'];
  List<String> jobTypes = ['All', 'Internship', 'Entry Level'];

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchJobs() async {
    setState(() {
      isLoading = true;
    });

    String whatQuery = profession;
    if (jobType != 'All') {
      whatQuery = '$profession $jobType';
    }
    if (workMode != 'All') {
      whatQuery = '$whatQuery $workMode';
    }

    String apiUrl = 'https://api.adzuna.com/v1/api/jobs/$countryCode/search/1'
        '?app_id=$appId'
        '&app_key=$appKey'
        '&what=${Uri.encodeComponent(whatQuery)}';

    print('API URL: $apiUrl');

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent': 'YourAppName/1.0',
        },
      );
      print('Response Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response Data: $data');
        List<Job> fetchedJobs = [];
        for (var item in data['results']) {
          // Handle null values safely
          String company = '';
          if (item['company'] != null &&
              item['company']['display_name'] != null) {
            company = item['company']['display_name'];
          }

          String location = '';
          if (item['location'] != null &&
              item['location']['display_name'] != null) {
            location = item['location']['display_name'];
          }

          String category = '';
          if (item['category'] != null && item['category']['label'] != null) {
            category = item['category']['label'];
          }

          fetchedJobs.add(Job(
            title: item['title'] ?? 'No Title',
            company: company.isEmpty ? 'Unknown Company' : company,
            location: location.isEmpty ? 'Location Not Specified' : location,
            description: item['description'] ?? 'No description available',
            redirectUrl: item['redirect_url'] ?? '',
            contractType: item['contract_type'] ?? '',
            category: category,
          ));
        }
        setState(() {
          jobs = fetchedJobs;
          isLoading = false;
        });
      } else {
        print('Failed to load jobs');
        print('Response Body: ${response.body}');
        setState(() {
          isLoading = false;
        });
        // Show error message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load jobs. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget buildJobList() {
    if (jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.work_off_outlined,
                size: 60,
                color: Color(0xFF165d96).withOpacity(0.3),
              ),
              SizedBox(height: 15),
              Text(
                'No jobs found',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF165d96),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try adjusting your search',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        Job job = jobs[index];
        return Container(
          margin: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => _showJobDetails(job),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF1c74bb).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.work_outline,
                            color: Color(0xFF1c74bb),
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF165d96),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                job.company,
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job.location,
                            style: GoogleFonts.leagueSpartan(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (job.contractType.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color(0xFF18bebc).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              job.contractType,
                              style: GoogleFonts.leagueSpartan(
                                fontSize: 12,
                                color: Color(0xFF18bebc),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
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

  void _showJobDetails(Job job) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xFF1c74bb).withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1c74bb),
                        Color(0xFF165d96),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.work,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          job.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(Icons.business, 'Company', job.company),
                        SizedBox(height: 15),
                        _buildDetailRow(
                            Icons.location_on, 'Location', job.location),
                        if (job.contractType.isNotEmpty) ...[
                          SizedBox(height: 15),
                          _buildDetailRow(Icons.work_outline, 'Contract Type',
                              job.contractType),
                        ],
                        if (job.category.isNotEmpty) ...[
                          SizedBox(height: 15),
                          _buildDetailRow(
                              Icons.category, 'Category', job.category),
                        ],
                        SizedBox(height: 20),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1c74bb),
                            fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          job.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                            fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            side:
                                BorderSide(color: Color(0xFF1c74bb), width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1c74bb),
                              fontWeight: FontWeight.bold,
                              fontFamily:
                                  GoogleFonts.leagueSpartan().fontFamily,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1c74bb),
                                Color(0xFF165d96),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF1c74bb).withOpacity(0.4),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                if (job.redirectUrl.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('No application link available'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.pop(context);
                                Uri url = Uri.parse(job.redirectUrl);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  print('Could not launch ${job.redirectUrl}');
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Could not open job link'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.open_in_new,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Apply Now',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: GoogleFonts.leagueSpartan()
                                            .fontFamily,
                                      ),
                                    ),
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF1c74bb).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Color(0xFF1c74bb),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                  fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1c74bb);
    const Color secondaryColor = Color(0xFF165d96);
    const Color accentColor = Color(0xFF18bebc);
    const Color backgroundColor = Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Modern Gradient AppBar
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryColor, secondaryColor, accentColor],
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
                            Icons.work_outline_rounded,
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
                                'Find a Job',
                                style: GoogleFonts.leagueSpartan(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Discover your career path',
                                style: GoogleFonts.leagueSpartan(
                                  color: Colors.white70,
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
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profession Field
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Profession',
                      hintText: 'e.g., Engineer, Doctor',
                      hintStyle: GoogleFonts.leagueSpartan(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      labelStyle: GoogleFonts.leagueSpartan(
                        color: Color(0xFF1c74bb),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      floatingLabelStyle: GoogleFonts.leagueSpartan(
                        color: Color(0xFF1c74bb),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      prefixIcon:
                          Icon(Icons.work_outline, color: Color(0xFF1c74bb)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Color(0xFF1c74bb), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    onChanged: (value) {
                      profession = value;
                    },
                  ),
                  SizedBox(height: 16),
                  // Job Type Field
                  DropdownButtonFormField<String>(
                    value: jobType,
                    decoration: InputDecoration(
                      labelText: 'Job Type',
                      labelStyle: GoogleFonts.leagueSpartan(
                        color: Color(0xFF1c74bb),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      floatingLabelStyle: GoogleFonts.leagueSpartan(
                        color: Color(0xFF1c74bb),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(Icons.business_center_outlined,
                          color: Color(0xFF1c74bb)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Color(0xFF1c74bb), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    items: jobTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        jobType = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // Work Mode Field
                  DropdownButtonFormField<String>(
                    value: workMode,
                    decoration: InputDecoration(
                      labelText: 'Work Mode',
                      labelStyle: GoogleFonts.leagueSpartan(
                        color: Color(0xFF1c74bb),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      floatingLabelStyle: GoogleFonts.leagueSpartan(
                        color: Color(0xFF1c74bb),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(Icons.laptop_mac_outlined,
                          color: Color(0xFF1c74bb)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Color(0xFF1c74bb), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    items: workModes.map((mode) {
                      return DropdownMenuItem<String>(
                        value: mode,
                        child: Text(mode),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        workMode = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // Country Field
                  DropdownButtonFormField<String>(
                    value: countryName,
                    menuMaxHeight: MediaQuery.of(context).size.height * 0.25,
                    decoration: InputDecoration(
                      labelText: 'Country',
                      labelStyle: GoogleFonts.leagueSpartan(
                        color: Color(0xFF1c74bb),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      floatingLabelStyle: GoogleFonts.leagueSpartan(
                        color: Color(0xFF1c74bb),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      prefixIcon:
                          Icon(Icons.public_outlined, color: Color(0xFF1c74bb)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Color(0xFF1c74bb), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    style: GoogleFonts.leagueSpartan(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    items: countries.keys.map((country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        countryName = value!;
                        countryCode = countries[countryName]!;
                      });
                    },
                  ),
                  SizedBox(height: 24),
                  // Search Button
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1c74bb),
                          Color(0xFF165d96),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF1c74bb).withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: fetchJobs,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search, color: Colors.white, size: 24),
                              SizedBox(width: 10),
                              Text(
                                'Search Jobs',
                                style: GoogleFonts.leagueSpartan(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Jobs List
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF1c74bb),
                      ),
                    )
                  else
                    buildJobList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
