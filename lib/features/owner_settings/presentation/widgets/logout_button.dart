import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(

        onPressed: onPressed,

        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(
            color: Colors.redAccent,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        child: const Text(
          "Sign Out as Admin",
        ),
      ),
    );
  }
}