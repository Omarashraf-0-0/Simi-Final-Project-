import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../Pop-ups/StylishPopup.dart';

class UserUpdater {
  final String url;

  // Constructor to set the update endpoint
  UserUpdater({required this.url});

  Future<void> saveProfileImageToHive(File imageFile) async {
    try {
      // Read the image as bytes
      final bytes = await imageFile.readAsBytes();

      // Convert bytes to Base64 string
      final base64String = base64Encode(bytes);

      // Store the Base64 string in Hive
      await Hive.box('userBox').put('profileImageBase64', base64String);

      print('Profile image saved successfully!');
    } catch (e) {
      print('Error saving profile image: $e');
    }
  }

  Future<void> uploadImageToServer(
      File imageFile, String serverUrl, String username) async {
    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(serverUrl));

      // Attach the file
      request.files.add(await http.MultipartFile.fromPath(
        'image', // The key to match on the Flask server
        imageFile.path,
      ));

      // Add other fields if needed
      request.fields['username'] = username;

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully!');
        // Optional: Decode and use the response from the server
        var responseBody = await response.stream.bytesToString();
        print('Server Response: $responseBody');
        saveProfileImageToHive(imageFile);
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
        print('Response: ${await response.stream.bytesToString()}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  // Method to validate data
  Future<bool> validateData(
      Map<String, dynamic> data, BuildContext context) async {
    if (data['username'] == null || data['username'].isEmpty) {
      await StylishPopup.error(
          context: context,
          title: 'Error',
          message: 'Username cannot be empty.');
      return false;
    }
    if (data['password'] != null &&
        data['confirmPassword'] != null &&
        data['password'] != data['confirmPassword']) {
      await StylishPopup.error(
          context: context, title: 'Error', message: 'Passwords do not match.');
      return false;
    }
    return true;
  }

  // Generic update method
  Future<void> updateUserData({
    required Map<String, dynamic> requestData,
    required BuildContext context,
  }) async {
    // Remove confirmPassword as it's for validation only
    requestData.remove('confirmPassword');

    // Validate input
    if (!await validateData(requestData, context)) return;

    // Prepare request body
    final Map<String, dynamic> requestBody = requestData;
    try {
      // Send POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        // Update only the fields provided in the request body to the Hive box
        final userBox = Hive.box('userBox');
        requestBody.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            userBox.put(key, value);
          }
        });

        await StylishPopup.success(
            context: context,
            title: 'Done Successfully',
            message: 'Your data has been updated successfully.');
      } else {
        await StylishPopup.error(
            context: context,
            title: 'Update Failed',
            message: 'Failed to update data: ${response.body}');
      }
    } catch (error) {
      print(error);
      await StylishPopup.warning(
          context: context,
          title: 'Network Error',
          message: 'An error occurred: $error');
    }
  }

  // To update the profile page
  Future<void> updateProfilePicture(
      {required BuildContext context,
      required String base64Image, // The decoded picture as a Base64 string
      required String username}) async {
    // Prepare the request body with the Base64 string
    final Map<String, dynamic> requestBody = {
      'username': username,
      'profile_picture': base64Image,
    };

    try {
      // Send POST request to update the profile picture
      final response = await http.post(
        Uri.parse('$url/updatePFP'), // Assuming the route is '/updatePFP'
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        // Handle success (e.g., show success popup)
        await StylishPopup.success(
            context: context,
            title: 'Profile Picture Updated',
            message: 'Your profile picture has been updated successfully.');
      } else {
        // Handle failure (e.g., show failed popup)
        await StylishPopup.error(
            context: context,
            title: 'Update Failed',
            message: 'Failed to update profile picture: ${response.body}');
      }
    } catch (error) {
      // Handle error (e.g., show warning popup)
      await StylishPopup.warning(
          context: context,
          title: 'Network Error',
          message: 'An error occurred: $error');
    }
  }
}
