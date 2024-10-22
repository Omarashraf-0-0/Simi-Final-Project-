// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

class Textfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  const Textfield({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.transparent
            ),
        ),
        focusedBorder: OutlineInputBorder(
          
          borderSide: BorderSide(
            color: Color(0xff1c74bb),
            ),
        ),
        labelText: hintText,
        fillColor: Colors.grey[200],
        filled: true,
      ),
    );
  }
}