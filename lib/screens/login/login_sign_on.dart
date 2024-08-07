import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/login/login_forgot_password.dart';
import 'package:mini_ml/screens/login/login_verify.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/helpers.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginSignOn extends StatefulWidget {
  final String mode;

  const LoginSignOn({
    required this.mode,
    super.key,
  });

  @override
  State<LoginSignOn> createState() => _LoginSignOnState();
}

class _LoginSignOnState extends State<LoginSignOn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isSignIn = true;
  bool _isSignInUpPressed = false;

  @override
  void initState() {
    super.initState();
    _isSignIn = widget.mode == 'sign_in';
  }

  void _back() {
    Navigator.pop(context);
  }

  void _pushToForgotPassword() {
    Helpers.pushTo(context, const LoginForgotPassword());
  }

  void _pushToVerfiy() {
    Helpers.pushTo(context, const LoginVerify());
  }

  void _showSnackBar(String string, {Color? color}) {
    Dialogs.showSnackBar(context, string, color: color);
  }

  void _loginSignOn(AppProvider appProvider) async {
    appProvider.resetProviderState();
    try {
      if (_isSignIn) {
        appProvider.setIsLoading(true);
        await appProvider.signIn(
            _emailController.text, _passwordController.text);
        await appProvider.fetchAppData();

        appProvider.setIsLoading(false);
        _back();
      } else {
        appProvider.setIsLoading(true);
        await appProvider.signUp(
            _emailController.text, _passwordController.text);
        await appProvider.sendEmailVerification();
        appProvider.setIsLoading(false);
        _pushToVerfiy();
      }
    } catch (error) {
      appProvider.setIsLoading(false);
      _showSnackBar(error.toString(), color: Colors.red);
    }
  }

  void _switchModes() {
    _emailController.text = '';
    _passwordController.text = '';
    _isSignIn = !_isSignIn;
  }

  Future<void> _pushToTermsOfService() async {
    try {
      final Uri uri = Uri(
        scheme: 'https',
        path: 'machinename.dev/Mini ML - Terms of Service.pdf',
      );

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch ${uri.path}');
      }
    } catch (error) {
      _showSnackBar('Error Occured');
      throw Exception(
        error.toString(),
      );
    }
  }

  Future<void> _pushToPrivacyPolicy() async {
    try {
      final Uri uri = Uri(
        scheme: 'https',
        path: 'machinename.dev/Mini ML - Privacy Policy.pdf',
      );

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch ${uri.path}');
      }
    } catch (error) {
      _showSnackBar('Error Occured');
      throw Exception(
        error.toString(),
      );
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
              horizontal: Constants.getPaddingHorizontal(context),
              vertical: Constants.getPaddingVertical(context)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        enabled: !appProvider.isLoading,
                        validator: (value) {
                          if (_isSignInUpPressed) {
                            return Validators.emailValidator(value);
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          // floatingLabelBehavior:
                          //     FloatingLabelBehavior.always
                        ),
                        onChanged: (_) {
                          setState(
                            () {},
                          );
                        },
                      ),
                      SizedBox(
                        height: Constants.getPaddingVertical(context),
                      ),
                      TextFormField(
                          obscureText: _isPasswordVisible ? false : true,
                          controller: _passwordController,
                          enabled: !appProvider.isLoading,
                          validator: !_isSignIn
                              ? (value) {
                                  if (_isSignInUpPressed) {
                                    return Validators.passwordValidator(value,
                                        confirmPassword:
                                            _passwordConfirmController.text);
                                  }
                                  return null;
                                }
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(
                                  () {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  },
                                );
                              },
                            ),
                          ),
                          onChanged: (_) {
                            setState(() {});
                          }),
                      if (!_isSignIn)
                        Column(children: [
                          SizedBox(
                              height: Constants.getPaddingVertical(context)),
                          TextFormField(
                              enabled: !appProvider.isLoading,
                              obscureText: _isPasswordVisible ? false : true,
                              controller: _passwordConfirmController,
                              decoration: const InputDecoration(
                                labelText: 'Confirm Password',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) {
                                setState(() {});
                              })
                        ])
                    ])),
            SizedBox(height: Constants.getPaddingVertical(context)),
            _isSignIn
                ? GestureDetector(
                    onTap: () {
                      _pushToForgotPassword();
                    },
                    child: Container(
                        // color: Colors.black,
                        alignment: Alignment.center,
                        child: const Text(
                          'Forgot Password?',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.blue),
                        )),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Constants.getPaddingHorizontal(context),
                    ),
                    child: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                            text:
                                'By tapping Create Account, you acknowledge that you have read the ',
                            style: const TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _pushToPrivacyPolicy();
                                    },
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue,
                                  )),
                              const TextSpan(text: ' and agree to the '),
                              TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _pushToTermsOfService();
                                    },
                                  text: 'Terms of Service',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.blue,
                                  )),
                              const TextSpan(text: '.')
                            ]))),
            SizedBox(height: Constants.getPaddingVertical(context) - 2),
            _isSignIn
                ? ElevatedButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero)),
                    ),
                    onPressed: _emailController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty &&
                            !appProvider.isLoading
                        ? () {
                            setState(
                              () {
                                _isSignInUpPressed = true;
                              },
                            );
                            if (_formKey.currentState != null &&
                                _formKey.currentState!.validate()) {
                              _loginSignOn(appProvider);
                            }
                          }
                        : null,
                    child: const Text('Log In'),
                  )
                : ElevatedButton(
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero)),
                    ),
                    onPressed: _emailController.text.isNotEmpty &&
                            _passwordController.text.isNotEmpty &&
                            _passwordConfirmController.text.isNotEmpty &&
                            !appProvider.isLoading
                        ? () {
                            setState(
                              () {
                                _isSignInUpPressed = true;
                              },
                            );
                            if (_formKey.currentState != null &&
                                _formKey.currentState!.validate()) {
                              _loginSignOn(appProvider);
                            }
                          }
                        : null,
                    child: const Text('Create Account'))
          ]))
    ]);
  }

  _buildAppBar() {
    return AppBar(
        title: _isSignIn ? const Text('Sign In') : const Text('Sign Up'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_sharp),
            onPressed: () {
              _back();
            }),
        centerTitle: false,
        actions: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      _switchModes();
                    });
                  },
                  child: Text(_isSignIn ? 'Sign Up' : 'Sign In')))
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(appBar: _buildAppBar(), body: _buildBody(appProvider));
    });
  }
}
