import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/account/account_delete.dart';
import 'package:mini_ml/screens/account/account_download.dart';
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

  void _pushToAccountEmail(AppProvider appProvider) {
    String email = appProvider.auth.currentUser!.email ?? "";
    Helpers.pushTo(context, AccountEmail(email: email));
  }

  void _pushToAccountDelete() {
    Helpers.pushTo(context, const AccountDelete());
  }

  void _pushToAccountDownload() {
    Helpers.pushTo(context, const AccountDownload());
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
        _pushToAccountEmail(appProvider);
      } else if (widget.route == 'delete') {
        _pushToAccountDelete();
      } else if (widget.route == 'download') {
        _pushToAccountDownload();
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
    return Stack(children: [
      if (appProvider.isLoading)
        const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      Padding(
          padding: EdgeInsets.symmetric(
            vertical: Constants.getPaddingVertical(context),
            horizontal: Constants.getPaddingHorizontal(context),
          ),
          child: ListView(physics: const ClampingScrollPhysics(), children: [
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
            SizedBox(height: Constants.getPaddingVertical(context)),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                  style: ButtonStyle(
                      foregroundColor: appProvider.isLoading
                          ? WidgetStateProperty.all(Colors.grey[300])
                          : WidgetStateProperty.all(Colors.blue[800])),
                  onPressed: !appProvider.isLoading
                      ? () {
                          _back();
                        }
                      : null,
                  child: const Text('Cancel')),
              SizedBox(width: Constants.getPaddingHorizontal(context)),
              TextButton(
                style: ButtonStyle(
                    backgroundColor: _passwordController.text.isNotEmpty &&
                            !appProvider.isLoading
                        ? WidgetStateProperty.all(Colors.blue[800])
                        : WidgetStateProperty.all(Colors.grey[300]),
                    foregroundColor: _passwordController.text.isNotEmpty &&
                            !appProvider.isLoading
                        ? WidgetStateProperty.all(Colors.white)
                        : WidgetStateProperty.all(Colors.grey[500])),
                onPressed: _passwordController.text.isNotEmpty &&
                        !appProvider.isLoading
                    ? () {
                        _reAuthUser(appProvider);
                      }
                    : null,
                child: const Text('Next'),
              )
            ])
          ]))
    ]);
  }

  _buildAppBar(AppProvider appProvider) {
    String message = '';
    if (widget.route == '') {
    } else {}

    switch (widget.route) {
      case 'email':
        message = 'Email';
        break;
      case 'delete':
        message = 'Delete Account';
        break;
      case 'download':
        message = 'Download Data';
        break;
      case 'password':
        message = 'Password';
        break;
      default:
        message = '';
    }
    return AppBar(
      // title: Text(message),
      title: const Text('Re-Authenticate'),
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
