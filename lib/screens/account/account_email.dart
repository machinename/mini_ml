import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class AccountEmail extends StatefulWidget {
  const AccountEmail({super.key});

  @override
  State<AccountEmail> createState() => _AccountEmailState();
}

class _AccountEmailState extends State<AccountEmail> {
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

  void _updateEmail(AppProvider appProvider) async {
    try {
      var currentUser = appProvider.auth.currentUser;

      if (currentUser != null) {
        appProvider.setIsLoading(true);
        await currentUser.verifyBeforeUpdateEmail(_emailController.text);
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
      title: const Text("Email"),
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
              vertical: Constants.getPaddingVertical(context),
              horizontal: Constants.getPaddingHorizontal(context)),
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
              SizedBox(height: Constants.getPaddingVertical(context)),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                    style: ButtonStyle(
                        foregroundColor: appProvider.isLoading
                            ? WidgetStateProperty.all(Colors.grey[300])
                            : WidgetStateProperty.all(Colors.blue[800])),
                    onPressed: !appProvider.isLoading
                        ? () {
                            _exit();
                          }
                        : null,
                    child: const Text('Cancel')),
                SizedBox(width: Constants.getPaddingHorizontal(context)),
                TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          _emailController.text.isEmpty || appProvider.isLoading
                              ? WidgetStateProperty.all(Colors.grey[300])
                              : WidgetStateProperty.all(Colors.blue[800]),
                      foregroundColor:
                          _emailController.text.isEmpty || appProvider.isLoading
                              ? WidgetStateProperty.all(Colors.grey[500])
                              : WidgetStateProperty.all(Colors.white)),
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
                                _updateEmail(appProvider);
                              }
                            }
                          : null,
                  child: const Text('Update'),
                ),
              ])
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
