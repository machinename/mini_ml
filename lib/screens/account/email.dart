import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class Email extends StatefulWidget {
  const Email({super.key});

  @override
  State<Email> createState() => _EmailState();
}

class _EmailState extends State<Email> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final bool _isSavePressed = false;

  _back() {
    Navigator.pop(context);
  }

  _exitEmailDialog() {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _showUpdateEmailDialog(AppProvider appProvider) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to update the email?'),
          actions: [
            TextButton(
              onPressed: () {
                _back();
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                _back();
                _updateEmail(appProvider);
              },
              child: const Text('YES'),
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailDialog(AppProvider appProvider) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Verify'),
          content: const Text("Please verify your new email to update."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _exitEmailDialog();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _updateEmail(AppProvider appProvider) async {
    try {
      var currentUser = appProvider.auth.currentUser;
      if (currentUser != null) {
        await currentUser.verifyBeforeUpdateEmail(_emailController.text);
        _showVerifyEmailDialog(appProvider);
      }
    } catch (error) {
      _showSnackBar('Error Occured');
      // Log Here
      throw Exception(
        error.toString(),
      );
    }
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
  }

  _buildAppBar() {
    return AppBar(
      title: const Text("Email"),
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          _back();
        },
      ),
    );
  }

  _buildBody(AppProvider appProvider) {
    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Constants.getPaddingHorizontal(context),
            vertical: Constants.getPaddingVertical(context)),
        child: ListView(
          physics: const ClampingScrollPhysics(),
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  labelText: 'Enter Account Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_isSavePressed) {
                    return Validators.emailValidator(value);
                  }
                  return null;
                },
                onChanged: (_) {
                  setState(
                    () {},
                  );
                },
              ),
            ),
          ],
        ));
  }

  // Widget _buildBody(AppProvider appProvider) {
  //   return ListView(
  //     physics: const ClampingScrollPhysics(),
  //     padding: EdgeInsets.symmetric(
  //       horizontal: Constants.getPaddingHorizontal(context),
  //       vertical: Constants.getPaddingVertical(context),
  //     ),
  //     children: [
  // Form(
  //   key: _formKey,
  //   child: TextFormField(
  //     controller: _emailController,
  //     keyboardType: TextInputType.multiline,
  //     decoration: const InputDecoration(
  //       labelText: 'Enter Account Email',
  //       border: OutlineInputBorder(),
  //     ),
  //     validator: (value) {
  //       if (_isSavePressed) {
  //         return Validators.emailValidator(value);
  //       }
  //       return null;
  //     },
  //     onChanged: (_) {
  //       setState(
  //         () {},
  //       );
  //     },
  //   ),
  // ),
  //       SizedBox(
  //         height: Constants.getPaddingVertical(context),
  //       ),
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           SizedBox(
  //             height: Constants.getPaddingVertical(context),
  //           ),
  // ElevatedButton(
  //   onPressed: _emailController.text.isNotEmpty &&
  //           (_formKey.currentState?.validate() ?? false)
  //       ? () => _showUpdateEmailDialog(appProvider)
  //       : null,
  //   child: const Text('Save'),
  // ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(appProvider),
        );
      },
    );
  }
}
