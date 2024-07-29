import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/account/account_data_and_privacy.dart';
import 'package:mini_ml/screens/account/account_legal.dart';
import 'package:mini_ml/screens/account/account_security.dart';
import 'package:mini_ml/screens/login/re_auth.dart';
import 'package:mini_ml/utils/helpers.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountManage extends StatefulWidget {
  const AccountManage({super.key});

  @override
  State<AccountManage> createState() => _AccountManageState();
}

class _AccountManageState extends State<AccountManage> {
  void _back() {
    Navigator.pop(context);
  }

  void _pushToReAuth(String route) {
    Helpers.pushTo(context, ReAuth(route: route));
  }

  void _pushToDataAndPrivacy() {
    Helpers.pushTo(context, const AccountDataAndPrivacy());
  }

  void _pushToSecurity() {
    Helpers.pushTo(context, const AccountSecurity());
  }

  void _pushToLegal() {
    Helpers.pushTo(context, const Legal());
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
  }

  Future<void> _signOut(AppProvider appProvider) async {
    try {
      bool? isSignOut = await Dialogs.showConfirmDialog(
          context, "Are you sure you want to sign out?");
      if (isSignOut == true) {
        appProvider.signOut();
        _back();
      }
    } catch (error) {
      _showSnackBar('Error Occured');

      throw Exception(
        error.toString(),
      );
    }
  }

  Future<void> _pushToSupport() async {
    try {
      final Uri uri = Uri(
          scheme: 'mailto',
          path: 'support@machinename.dev',
          queryParameters: {
            'subject': 'Support Request',
            'body': 'Please describe your issue here',
          });

      if (!await launchUrl(uri,
          mode: LaunchMode.externalNonBrowserApplication)) {
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
    return ListView(physics: const ClampingScrollPhysics(), children: [
      const ListTile(title: Text("Info")),
      ListTile(
          leading: const Icon(Icons.email_sharp),
          title: const Text("Email"),
          subtitle: Text(appProvider.auth.currentUser?.email ?? "N/A"),
          onTap: () => _pushToReAuth('email'),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.lock_sharp),
          title: const Text("Security"),
          onTap: () => _pushToSecurity(),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
        leading: const Icon(Icons.privacy_tip_sharp),
        title: const Text("Data & Privacy"),
        onTap: () => _pushToDataAndPrivacy(),
        trailing: const Icon(Icons.chevron_right_sharp),
      ),
      ListTile(
        leading: const Icon(Icons.storage_sharp),
        title: const Text("Storage"),
        subtitle:
            Text('${appProvider.userStorageInMegaBytes} MB of 100 MB used'),
      ),
      const ListTile(title: Text("About")),
      ListTile(
          leading: const Icon(Icons.help_sharp),
          title: const Text("Support"),
          onTap: () => _pushToSupport(),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.info_sharp),
          title: const Text("Legal"),
          onTap: () => _pushToLegal(),
          trailing: const Icon(Icons.chevron_right_sharp))
    ]);
  }

  _buildAppBar(AppProvider appProvider) {
    return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp),
          onPressed: () {
            _back();
          },
        ),
        title: const Text("Account"),
        centerTitle: false,
        actions: [
          Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              child: TextButton(
                  onPressed: () {
                    _signOut(appProvider);
                  },
                  child: const Text("Sign Out")))
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
