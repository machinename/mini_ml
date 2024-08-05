import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class AccountPhone extends StatefulWidget {
  const AccountPhone({super.key});

  @override
  State<AccountPhone> createState() => _AccountPhoneState();
}

class _AccountPhoneState extends State<AccountPhone> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isSavePressed = false;
  _exit() {
    Navigator.pop(context);
    Navigator.pop(context);
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
                _exit();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _updatePhone(AppProvider appProvider) async {
    try {
      var currentUser = appProvider.auth.currentUser;

      if (currentUser != null) {
        appProvider.setIsLoading(true);
        // await currentUser.updatePhoneNumber(phoneCredential)
        appProvider.setIsLoading(false);
        _showVerifyEmailDialog(appProvider);
      }
    } catch (error) {
      appProvider.setIsLoading(false);
      _showSnackBar(error.toString());
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
      title: const Text("Phone"),
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_sharp),
        onPressed: () {
          _exit();
        },
      ),
    );
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
          child: ListView(
            physics: const ClampingScrollPhysics(),
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  enabled: !appProvider.isLoading,
                  controller: _emailController,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: 'Email',
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
              SizedBox(height: Constants.getPaddingVertical(context) - 4),
              ElevatedButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero)),
                ),
                onPressed:
                    _emailController.text.isNotEmpty && !appProvider.isLoading
                        ? () {
                            setState(
                              () {
                                _isSavePressed = true;
                              },
                            );
                            if (_formKey.currentState != null &&
                                _formKey.currentState!.validate()) {
                              _updatePhone(appProvider);
                            }
                          }
                        : null,
                child: const Text('Update'),
              ),
            ],
          ))
    ]);
  }

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
