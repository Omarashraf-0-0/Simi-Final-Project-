import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON decoding
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // To open URLs

// Define a Job class
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
  // User selections
  String jobType = 'All'; // Internship, Entry Level, All
  String workMode = 'All'; // Remote, Onsite, Hybrid, All
  String countryCode = 'us'; // Default country code
  String countryName = 'United States'; // Default country name
  String profession = ''; // Profession or job title (e.g., 'Engineer', 'Doctor')
  List<Job> jobs = [];
  bool isLoading = false;

  // Adzuna API credentials
  final String appId = '33a454df';
  final String appKey = '1805cb4c51d733cbe670bcab85c8818f';

  // List of supported countries
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

  // List of work modes
  List<String> workModes = ['All', 'Remote', 'Onsite', 'Hybrid'];

  // List of job types
  List<String> jobTypes = ['All', 'Internship', 'Entry Level'];

  @override
  void initState() {
    super.initState();
  }

  // Function to fetch jobs from Adzuna API
  Future<void> fetchJobs() async {
    setState(() {
      isLoading = true;
    });

    // Build the search query by combining profession and job type
    String whatQuery = profession;
    if (jobType != 'All') {
      whatQuery = '$profession $jobType';
    }
    if (workMode != 'All') {
      whatQuery = '$whatQuery $workMode';
    }

    // Build the API URL
    String apiUrl = 'https://api.adzuna.com/v1/api/jobs/$countryCode/search/1'
        '?app_id=$appId'
        '&app_key=$appKey'
        '&what=${Uri.encodeComponent(whatQuery)}';

    print('API URL: $apiUrl'); // For debugging

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'User-Agent': 'YourAppName/1.0', // Replace with your app's name and version
        },
      );
      print('Response Status Code: ${response.statusCode}'); // For debugging
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response Data: $data'); // For debugging
        List<Job> fetchedJobs = [];
        for (var item in data['results']) {
          fetchedJobs.add(Job(
            title: item['title'] ?? '',
            company: item['company']['display_name'] ?? '',
            location: item['location']['display_name'] ?? '',
            description: item['description'] ?? '',
            redirectUrl: item['redirect_url'] ?? '',
            contractType: item['contract_type'] ?? '',
            category: item['category']['label'] ?? '',
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
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Widget to build job list
  Widget buildJobList() {
    if (jobs.isEmpty) {
      return const Center(child: Text('No jobs found.'));
    } else {
      return ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          Job job = jobs[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(job.title),
              subtitle: Text('${job.company} - ${job.location}'),
              onTap: () {
                // Open job details or redirect URL
                _showJobDetails(job);
              },
            ),
          );
        },
      );
    }
  }

  void _showJobDetails(Job job) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            job.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.leagueSpartan().fontFamily,
            ),
          ),
          content: SingleChildScrollView(
            // Wrap content in SingleChildScrollView
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company: ${job.company}',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Location: ${job.location}',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  job.description,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                // Redirect to job application URL
                Navigator.pop(context);
                Uri url = Uri.parse(job.redirectUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  print('Could not launch ${job.redirectUrl}');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF165D96),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Apply',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontFamily: GoogleFonts.leagueSpartan().fontFamily,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find a Job',
          style: TextStyle(
            fontFamily: 'League Spartan',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF165D96),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profession Input Field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Profession (e.g., Engineer, Doctor)',
                prefixIcon: Icon(Icons.work),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
              ),
              onChanged: (value) {
                profession = value;
              },
            ),
            const SizedBox(height: 20),
            // Job Type Selection
            DropdownButtonFormField<String>(
              value: jobType,
              decoration: const InputDecoration(
                labelText: 'Job Type',
                prefixIcon: Icon(Icons.work_outline),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
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
            const SizedBox(height: 20),
            // Work Mode Selection
            DropdownButtonFormField<String>(
              value: workMode,
              decoration: const InputDecoration(
                labelText: 'Work Mode',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
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
            const SizedBox(height: 20),
            // Country Selection using DropdownButtonFormField with menuMaxHeight
            DropdownButtonFormField<String>(
              value: countryName,
              menuMaxHeight: MediaQuery.of(context).size.height * 0.25,
              decoration: const InputDecoration(
                labelText: 'Country',
                prefixIcon: Icon(Icons.public),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(8),
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
            const SizedBox(height: 20),
            // Search Button
            ElevatedButton(
              onPressed: fetchJobs,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF165D96),
                padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Search Jobs',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'League Spartan',
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Display Jobs
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : buildJobList(),
            ),
          ],
        ),
      ),
    );
  }
}