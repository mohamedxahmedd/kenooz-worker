import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {}, child: Image.asset('assets/images/google_button.png'));
  }
}
