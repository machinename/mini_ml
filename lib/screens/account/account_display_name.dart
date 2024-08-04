import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class AccountDisplayName extends StatefulWidget {
  const AccountDisplayName({super.key});

  @override
  State<AccountDisplayName> createState() => _AccountDisplayNameState();
}

class _AccountDisplayNameState extends State<AccountDisplayName> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _displayNameController = TextEditingController();
  bool _isSavePressed = false;

  _back() {
    Navigator.pop(context);
  }

  void _updateDisplayName(AppProvider appProvider) async {
    try {
      var currentUser = appProvider.auth.currentUser;

      if (currentUser != null) {
        appProvider.setIsLoading(true);
        await currentUser.updateDisplayName(_displayNameController.text);
        appProvider.setIsLoading(false);
        _back();
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
      title: const Text("Display Name"),
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_sharp),
        onPressed: () {
          _back();
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
                  controller: _displayNameController,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_isSavePressed) {
                      return Validators.nameValidator(value, "Display Name");
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
                onPressed: _displayNameController.text.isNotEmpty &&
                        !appProvider.isLoading
                    ? () {
                        setState(
                          () {
                            _isSavePressed = true;
                          },
                        );
                        if (_formKey.currentState != null &&
                            _formKey.currentState!.validate()) {
                          _updateDisplayName(appProvider);
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
