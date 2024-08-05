import 'package:flutter/material.dart';
import 'login_sign_on.dart';

class Login extends StatelessWidget {
  const Login({
    super.key,
  });

  _pushToSignOnScreen(BuildContext context, String mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginSignOn(
          mode: mode,
        ),
      ),
    );
  }

  _buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // const Image(image: AssetImage('assets/images/logo.png')),
        const Text('Mini ML', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)) ,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                _pushToSignOnScreen(context, 'sign_in');
              },
              child: const Text('Sign In', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                _pushToSignOnScreen(context, 'sign_up');
              },
              child: const Text('Sign Up', style: TextStyle(color: Colors.black)),
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
