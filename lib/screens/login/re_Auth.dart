import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/account/account_delete.dart';
import 'package:mini_ml/screens/account/account_email.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/helpers.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class ReAuth extends StatefulWidget {
  final String route;

  const ReAuth({
    required this.route,
    super.key,
  });

  @override
  State<ReAuth> createState() => _ReAuthState();
}

class _ReAuthState extends State<ReAuth> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _back() {
    Navigator.pop(context);
  }

  void _pushToAccountEmail() {
    Helpers.pushTo(context, const AccountEmail());
  }

  void _pushToAccountDelete() {
    Helpers.pushTo(context, const AccountDelete());
  }

  void _resetPassword(AppProvider appProvider) async {
    try {
      await appProvider.resetPassword();
      _back();
      _showSnackBar('Password Reset Link Sent');
    } catch (error) {
      _showSnackBar('Error Occured');
    }
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string, seconds: 3);
  }

  void _reAuthUser(AppProvider appProvider) async {
    try {
      appProvider.setIsLoading(true);
      await appProvider.reauthenticateWithCredential(_passwordController.text);
      appProvider.setIsLoading(false);
      if (widget.route == 'email') {
        _pushToAccountEmail();
      } else if (widget.route == 'delete') {
        _pushToAccountDelete();
      } else if (widget.route == 'password') {
        _resetPassword(appProvider);
      }
    } catch (error) {
      appProvider.setIsLoading(false);
      print(error.toString());
      _showSnackBar(error.toString());
    }
  }

  _buildBody(AppProvider appProvider) {
    String message = '';
    if (widget.route == '') {
    } else {}

    switch (widget.route) {
      case 'email':
        message = 'Please reauthenticate to update your email.';
        break;
      case 'delete':
        message = 'Reauthenticate to access account deletion.';
        break;
      case 'password':
        message = 'Please reauthenticate to update your password.';
        break;
      default:
        message = '';
    }
    return Stack(children: [
      if (appProvider.isLoading)
        const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ListView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: Constants.getPaddingHorizontal(context),
            vertical: Constants.getPaddingVertical(context),
          ),
          children: [
            Text(message, textAlign: TextAlign.left),
            SizedBox(height: Constants.getPaddingVertical(context)),
            Form(
                key: _formKey,
                child: TextFormField(
                    enabled: !appProvider.isLoading,
                    obscureText: _isPasswordVisible ? false : true,
                    controller: _passwordController,
                    decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                            icon: Icon(_isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            })),
                    onChanged: (_) {
                      setState(() {});
                    })),
            SizedBox(height: Constants.getPaddingVertical(context) - 4),
            ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero)),
              ),
              onPressed:
                  _passwordController.text.isNotEmpty && !appProvider.isLoading
                      ? () {
                          _reAuthUser(appProvider);
                        }
                      : null,
              child: const Text('Next'),
            )
          ])
    ]);
  }

  _buildAppBar(AppProvider appProvider) {
    return AppBar(
      title: const Text('Enter Password'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_sharp),
        onPressed: () {
          _back();
        },
      ),
      centerTitle: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return Scaffold(
          appBar: _buildAppBar(appProvider),
          body: _buildBody(appProvider),
        );
      },
    );
  }
}
