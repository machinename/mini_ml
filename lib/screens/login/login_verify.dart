import 'package:flutter/material.dart';
import 'package:mini_ml/utils/constants.dart';

class LoginVerify extends StatelessWidget {
  const LoginVerify({super.key});

  _exit(BuildContext context) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  _buildBody(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Constants.getPaddingHorizontal(context)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Verify your email address to enjoy mini ML features!',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Constants.getPaddingVertical(context)),
              ElevatedButton(
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero)),
                  ),
                  onPressed: () => _exit(context),
                  child: const Text('Continue'))
            ]));
  }

  _buildAppBar(BuildContext context) {
    return AppBar(
        leading: IconButton(
            icon: const Icon(Icons.clear_sharp),
            onPressed: () {
              _exit(context);
            }),
        title: const Text('LoginVerify Email'),
        automaticallyImplyLeading: false,
        centerTitle: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(context), body: _buildBody(context));
  }
}
