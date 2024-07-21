import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class DataAndPrivacy extends StatefulWidget {
  const DataAndPrivacy({super.key});

  @override
  State<DataAndPrivacy> createState() => _DataAndPrivacyState();
}

class _DataAndPrivacyState extends State<DataAndPrivacy> {
  void _back() {
    Navigator.pop(context);
  }

  Future<void> _handleDeleteYourAccount(AppProvider appProvider) async {
    try {
      bool reAuthSuccess = await _reAuth(appProvider);
      if (reAuthSuccess) {
        _deleteYourAccount(appProvider);
      }
    } catch (error) {
      _showSnackBar('Error Occured');
      throw Exception(
        error.toString(),
      );
    }
  }

  Future<void> _deleteYourAccount(AppProvider appProvider) async {
    try {
      bool? deleteAccount = false;
      deleteAccount = await Dialogs.showThreeButtonDialog(
          context,
          "Are you sure you want to delete your account? This action is irreversible!",
          "DELETE");
      if (deleteAccount == true) {
        await appProvider.deleteAccount();
      }
      _back();
      _back();
    } catch (error) {
      _showSnackBar('Error Occured');
      throw Exception(
        error.toString(),
      );
    }
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
  }

  Future<bool> _reAuth(AppProvider appProvider) async {
    try {
      String? password = await Dialogs.showPasswordDialog(context);
      if (password != null) {
        // await appProvider.reauthenticateWithCredential(password);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      _showSnackBar('Error Occured');
      // Log Here
      return false;
    }
  }

  _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_sharp),
        onPressed: () {
          _back();
        },
      ),
      title: const Text("Account Data"),
      centerTitle: false,
    );
  }

  _buildBody(AppProvider appProvider) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        ListTile(
          title: const Text("Delete Your Account"),
          subtitle: const Text("Delete your entire account and data"),
          onTap: () {
            _handleDeleteYourAccount(appProvider);
          },
          trailing: const Icon(Icons.chevron_right),
        ),
      ],
    );
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
