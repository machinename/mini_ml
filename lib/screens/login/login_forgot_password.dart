import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class LoginForgotPassword extends StatefulWidget {
  const LoginForgotPassword({
    super.key,
  });

  @override
  State<LoginForgotPassword> createState() => _LoginForgotPasswordState();
}

class _LoginForgotPasswordState extends State<LoginForgotPassword> {
  bool _isSendPressed = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  _back() {
    Navigator.pop(context);
  }

  void _forgotPassword(AppProvider appProvider) async {
    try {
      await appProvider.auth
          .sendPasswordResetEmail(email: _emailController.text);
    } catch (error) {
      _showSnackBar(error.toString());
    }
  }

  _showConfirmEmailDialog(AppProvider appProvider) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Confirm Email'),
              content: Text(
                  'Confirm ${_emailController.text} is the correct email?'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      _back();
                    },
                    child: const Text('CANCEL')),
                TextButton(
                    onPressed: () {
                      _forgotPassword(appProvider);
                      _back();
                    },
                    child: const Text('YES'))
              ]);
        });
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
  }

  _buildBody(AppProvider appProvider) {
    return ListView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(
            horizontal: Constants.getPaddingHorizontal(context),
            vertical: Constants.getPaddingVertical(context)),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (_isSendPressed) {
                      return Validators.emailValidator(value);
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder()),
                  onChanged: (_) {
                    setState(
                      () {},
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: Constants.getPaddingVertical(context) - 4),
          ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero)),
              ),
              onPressed: _emailController.text.isNotEmpty
                  ? () {
                      setState(() {
                        _isSendPressed = true;
                      });
                      if (_formKey.currentState != null &&
                          _formKey.currentState!.validate()) {
                        _showConfirmEmailDialog(appProvider);
                      }
                    }
                  : null,
              child: const Text('Send'))
        ]);
  }

  _buildAppBar() {
    return AppBar(
        title: const Text('Forgot Password'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_sharp),
            onPressed: () {
              _back();
            }),
        centerTitle: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(appBar: _buildAppBar(), body: _buildBody(appProvider));
    });
  }
}
