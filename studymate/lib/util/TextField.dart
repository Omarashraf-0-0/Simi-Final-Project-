import 'package:flutter/material.dart';

class Textfield extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;
  final TextInputType? keyboardType;
  final TextStyle? hintStyle;
  bool toggleVisability;
  final bool isDateField;
  final bool isTimeField;
  final bool isFutureDate;

  Textfield({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor = Colors.grey,
    this.borderColor = Colors.blue,
    this.borderRadius = 15.0,
    this.keyboardType,
    this.hintStyle,
    this.toggleVisability = true,
    this.isDateField = false,
    this.isTimeField = false,
    this.isFutureDate = false,
  });

  @override
  State<Textfield> createState() => _TextfieldState();
}

class _TextfieldState extends State<Textfield> {
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900), // Earliest selectable date
      lastDate: widget.isFutureDate ? DateTime(2101) : DateTime.now(), // Latest selectable date (today)
    );

    if (pickedDate != null) {
      setState(() {
        widget.controller.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }


  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        widget.controller.text = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !widget.toggleVisability,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.hintText,
        hintStyle: widget.hintStyle ?? TextStyle(color: Colors.grey),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  widget.toggleVisability
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    widget.toggleVisability = !widget.toggleVisability;
                  });
                },
              )
            : widget.suffixIcon,
        fillColor: widget.fillColor?.withOpacity(0.2),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: widget.borderColor!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide:
              BorderSide(color: widget.borderColor ?? Color(0xff1c74bb)),
        ),
      ),
      onTap: widget.isDateField
          ? () {
              _selectDate(context); // Show date picker if it's a date field
            }
          : widget.isTimeField
              ? () {
                  _selectTime(context); // Show time picker if it's a time field
                }
              : null,
    );
  }
}
