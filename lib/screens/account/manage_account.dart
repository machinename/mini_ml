import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/account/data_and_privacy.dart';
import 'package:mini_ml/screens/account/email.dart';
import 'package:mini_ml/screens/account/legal.dart';
import 'package:mini_ml/screens/account/password.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageAccount extends StatefulWidget {
  const ManageAccount({super.key});

  @override
  State<ManageAccount> createState() => _ManageAccountState();
}

class _ManageAccountState extends State<ManageAccount> {
  void _back() {
    Navigator.pop(context);
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

  void _pushToUpdateAccountEmail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Email(),
      ),
    );
  }

  void _pushToDataAndPrivacy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DataAndPrivacy(),
      ),
    );
  }

  void _pushToSecurity() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Security(),
      ),
    );
  }

  void _pushToLegal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Legal(),
      ),
    );
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
  }

  Future<bool> _reAuth(AppProvider appProvider) async {
    try {
      String? password = await Dialogs.showPasswordDialog(context);
      if (password != null) {
        await appProvider.reauthenticateWithCredential(password);
        return true;
      } else {
        return false;
      }
    } catch (error) {
      _showSnackBar('Error Occured');
      return false;
    }
  }

  _buildBody(AppProvider appProvider) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
        ListTile(
          // leading: const Icon(Icons.email_sharp),
          title: const Text("Email"),
          subtitle: Text(appProvider.auth.currentUser?.email ?? "N/A"),
          onTap: () {
            _pushToUpdateAccountEmail();
          },
          trailing: const Icon(Icons.chevron_right),
        ),
        ListTile(
          // leading: const Icon(Icons.lock_sharp),
          title: const Text("Security"),
          onTap: () {
            _pushToSecurity();
          },
          trailing: const Icon(Icons.chevron_right),
        ),
        ListTile(
          // leading: const Icon(Icons.security_sharp),
          title: const Text("Data & Privacy"),
          onTap: () {
            _pushToDataAndPrivacy();
          },
          trailing: const Icon(Icons.chevron_right),
        ),

        // ListTile(
        //   leading: const Icon(Icons.subscriptions_sharp),
        //   title: const Text("Subscription"),
        //   subtitle: Text(appProvider.subscriberProvider.subscriberTier
        //       .toString()
        //       .split('.')
        //       .last
        //       .replaceFirstMapped(
        //           RegExp(r'^[a-z]'), (match) => match.group(0)!.toUpperCase())),
        //   onTap: () => {
        //     _pushToSubscription(),
        //   },
        //   trailing: const Icon(Icons.chevron_right),
        // ),
        const ListTile(
          // leading: const Icon(Icons.storage_sharp),
          title: Text("Storage"),
          subtitle: Text('MB of 100 MB used'),
        ),
        ListTile(
          // leading: const Icon(Icons.notifications_sharp),
          title: const Text("Support"),
          onTap: () {
            _pushToSupport();
          },
          trailing: const Icon(Icons.chevron_right),
        ),
        ListTile(
          // leading: const Icon(Icons.settings_sharp),
          title: const Text("Legal"),
          onTap: () {
            _pushToLegal();
          },
          trailing: const Icon(Icons.chevron_right),
        ),

        // const ListTile(
        //   title: Text(
        //     "Settings",
        //     style: TextStyle(fontWeight: FontWeight.bold),
        //   ),
        // ),
      ],
    );
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
              // vertical: Constants.getPaddingVertical(context),
            ),
            child: TextButton(
              onPressed: () {
                _signOut(appProvider);
              },
              child: const Text("Sign Out"),
            )),
      ],
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
