import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class AccountDisplayName extends StatefulWidget {
  final String displayName;
  const AccountDisplayName({super.key, required this.displayName});

  @override
  State<AccountDisplayName> createState() => _AccountDisplayNameState();
}

class _AccountDisplayNameState extends State<AccountDisplayName> {
  final _formKey = GlobalKey<FormState>();
  bool _isSavePressed = false;
  bool _isDisplayNameEmpty = true;
  bool _showRemoveButton = true;
  String _newDisplayName = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.displayName.isEmpty) {
        _showRemoveButton = false;
      }
    });
  }

  _back() {
    Navigator.pop(context);
  }

  void _updateDisplayName(AppProvider appProvider, {bool? clear}) async {
    try {
      var currentUser = appProvider.auth.currentUser;

      if (currentUser != null) {
        appProvider.setIsLoading(true);

        if (clear != null && clear) {
          await currentUser.updateDisplayName(null);
        } else {
          await currentUser.updateDisplayName(_newDisplayName);
        }
        _back();
        appProvider.setIsLoading(false);
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
            vertical: Constants.getPaddingVertical(context),
            horizontal: Constants.getPaddingHorizontal(context),
          ),
          child: ListView(
            physics: const ClampingScrollPhysics(),
            children: [
              Form(
                  key: _formKey,
                  child: TextFormField(
                      initialValue: widget.displayName,
                      enabled: !appProvider.isLoading,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                          labelText: 'Display Name',
                          border: OutlineInputBorder()),
                      validator: (value) {
                        if (_isSavePressed) {
                          return Validators.displayNameValidator(value);
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _newDisplayName = value;
                        setState(() {
                          _isDisplayNameEmpty = _newDisplayName.isEmpty;
                        });
                        print("New Display Name - $_newDisplayName");
                      })),
              SizedBox(height: Constants.getPaddingVertical(context)),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                if (_showRemoveButton)
                  TextButton(
                      style: ButtonStyle(
                          foregroundColor: appProvider.isLoading
                              ? WidgetStateProperty.all(Colors.grey[300])
                              : WidgetStateProperty.all(Colors.blue[800])),
                      onPressed: !appProvider.isLoading
                          ? () {
                              _updateDisplayName(appProvider, clear: true);
                            }
                          : null,
                      child: const Text('Remove')),
                SizedBox(width: Constants.getPaddingHorizontal(context)),
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
                        backgroundColor: _newDisplayName.toLowerCase() !=
                                    widget.displayName.toLowerCase() &&
                                !_isDisplayNameEmpty &&
                                !appProvider.isLoading
                            ? WidgetStateProperty.all(Colors.blue[800])
                            : WidgetStateProperty.all(Colors.grey[300]),
                        foregroundColor: _newDisplayName.toLowerCase() !=
                                    widget.displayName.toLowerCase() &&
                                !_isDisplayNameEmpty &&
                                !appProvider.isLoading
                            ? WidgetStateProperty.all(Colors.white)
                            : WidgetStateProperty.all(Colors.grey[500])),
                    onPressed: _newDisplayName.toLowerCase() !=
                                widget.displayName.toLowerCase() &&
                            !_isDisplayNameEmpty &&
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
                    child: const Text('Save'))
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
