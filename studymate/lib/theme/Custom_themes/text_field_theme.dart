import 'package:flutter/material.dart';

class TTextFormFieldTheme {
  TTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecoration = InputDecorationTheme(
errorMaxLines: 2,
suffixIconColor: Colors.black,

labelStyle: const TextStyle().copyWith(fontSize: 12,color: Colors.black),
hintStyle: const TextStyle().copyWith(fontSize: 12,color: Colors.black),
errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
floatingLabelStyle: const TextStyle().copyWith(color: Colors.purple.withOpacity(0.47)),

border: const OutlineInputBorder().copyWith(
  borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(width: 1, color: Colors.grey),
),

enabledBorder: const OutlineInputBorder().copyWith(
  borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(width: 1, color: Colors.grey),
),

focusedBorder: const OutlineInputBorder().copyWith(
  borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(width: 1, color: Colors.black12),
),

focusedErrorBorder: const OutlineInputBorder().copyWith(
  borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(width: 1, color: Colors.orange),
),

errorBorder: const OutlineInputBorder().copyWith(
  borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(width: 1, color: Colors.red),
),
  );

  static InputDecorationTheme darkInputDecoration = InputDecorationTheme(
errorMaxLines: 2,
suffixIconColor: Colors.white,

labelStyle: const TextStyle().copyWith(fontSize: 12,color: Colors.white),
hintStyle: const TextStyle().copyWith(fontSize: 12,color: Colors.white),
errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
floatingLabelStyle: const TextStyle().copyWith(color: Colors.purple.withOpacity(0.47)),

border: const OutlineInputBorder().copyWith(
  borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(width: 1, color: Colors.grey),
),

enabledBorder: const OutlineInputBorder().copyWith(
  borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(width: 1, color: Colors.grey),
),

focusedBorder: const OutlineInputBorder().copyWith(
  borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(width: 1, color: Colors.black12),
),

focusedErrorBorder: const OutlineInputBorder().copyWith(
  borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(width: 1, color: Colors.orange),
),

errorBorder: const OutlineInputBorder().copyWith(
  borderRadius: BorderRadius.circular(10),
  borderSide: const BorderSide(width: 1, color: Colors.red),
),
  );
}
