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
      _exit();
      appProvider.setIsLoading(false);
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
    if (appProvider.auth.currentUser == null) {
      return const Center(child: Text('User not found'));
    }
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
                        backgroundColor:
                            _deleteController.text == 'delete-account' &&
                                    !appProvider.isLoading
                                ? WidgetStateProperty.all(Colors.blue[800])
                                : WidgetStateProperty.all(Colors.grey[300]),
                        foregroundColor:
                            _deleteController.text == 'delete-account' &&
                                    !appProvider.isLoading
                                ? WidgetStateProperty.all(Colors.white)
                                : WidgetStateProperty.all(Colors.grey[500])),
                    onPressed: _deleteController.text == 'delete-account' &&
                            !appProvider.isLoading
                        ? () {
                            _deleteAccount(appProvider);
                          }
                        : null,
                    child: const Text('Delete'),
                  )
                ])
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
      // actions: [
      //   Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 4),
      //       child: TextButton(
      //         onPressed: _deleteController.text == 'delete-account' &&
      //                 !appProvider.isLoading
      //             ? () {
      //                 _deleteAccount(appProvider);
      //               }
      //             : null,
      //         child: const Text('Delete'),
      //       ))
      // ]
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
