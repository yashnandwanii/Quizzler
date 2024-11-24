import 'package:flutter/material.dart';


class SignupBottom extends StatelessWidget {
  const SignupBottom({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('OR'),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Image(
              image: AssetImage('assets/google_logo.png'),
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
              'Sign In with Google',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text.rich(
            TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: 'LOGIN',
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
