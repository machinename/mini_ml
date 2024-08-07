import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class AccountDelete extends StatefulWidget {
  const AccountDelete({super.key});

  @override
  State<AccountDelete> createState() => _AccountDeleteState();
}

class _AccountDeleteState extends State<AccountDelete> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deleteController = TextEditingController();

  void _back() {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _exit() {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  void _deleteAccount(AppProvider appProvider) async {
    try {
      appProvider.setIsLoading(true);
      await appProvider.deleteAccount();
      appProvider.setIsLoading(false);
      _exit();
      _showSnackBar("Account deleted successfully.");
    } catch (error) {
      _showSnackBar(error.toString());
      throw Exception(
        error.toString(),
      );
    }
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
  }

  _buildBody(AppProvider appProvider) {
    return Stack(
      children: [
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
                const Text(
                    'This action is irreversible. To confirm type, "delete-account" in the box below.',
                    textAlign: TextAlign.start),
                SizedBox(height: Constants.getPaddingHorizontal(context)),
                Form(
                    key: _formKey,
                    child: TextFormField(
                        enabled: !appProvider.isLoading,
                        controller: _deleteController,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) {
                          setState(() {});
                        })),
              ],
            )),
      ],
    );
  }

  _buildAppBar(AppProvider appProvider) {
    return AppBar(
        title: const Text('Delete Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp),
          onPressed: () {
            _back();
          },
        ),
        centerTitle: false,
        actions: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                onPressed: _deleteController.text == 'delete-account' &&
                        !appProvider.isLoading
                    ? () {
                        _deleteAccount(appProvider);
                      }
                    : null,
                child: const Text('Delete'),
              ))
        ]);
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
