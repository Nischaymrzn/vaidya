import 'package:flutter/material.dart';

class MyTextFormField extends StatefulWidget {
  const MyTextFormField({
    super.key,
    required this.text,
    this.controller,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.validationMessage = "Please enter some value",
    this.prefixIcon,
    this.obscureText = false,
    this.validator,
  });

  final String text;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String validationMessage;

  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText ? _isObscured : false,

      validator:
          widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return widget.validationMessage;
            }
            return null;
          },

      decoration: InputDecoration(
        hintText: widget.text,

        prefixIcon: widget.prefixIcon,

        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.black26),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF2D8CFF), width: 1.5),
        ),
      ),
    );
  }
}
