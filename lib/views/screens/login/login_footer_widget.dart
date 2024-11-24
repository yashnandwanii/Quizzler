import 'package:flutter/material.dart';


class login_footer_widget extends StatelessWidget {
  const login_footer_widget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('OR'),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Image(
              image:  AssetImage('assets/google_logo.png'),
              height: 20,
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {},
            label: const Text(
              'Sign in with Google',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        TextButton(
          onPressed: () {},
          child: const Text.rich(
            TextSpan(
              text: 'Don\'t have an account? ',
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: 'Sign Up',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
