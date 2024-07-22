import 'package:flutter/material.dart';
import 'sign_on.dart';

class Login extends StatelessWidget {
  const Login({
    super.key,
  });

  _pushToSignOnScreen(BuildContext context, String mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignOn(
          mode: mode,
        ),
      ),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
       const Text('mini ML', textAlign: TextAlign.center ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                _pushToSignOnScreen(context, 'sign_in');
              },
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () {
                _pushToSignOnScreen(context, 'sign_up');
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody(context));
  }
}
