import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/account/account_display_name.dart';
import 'package:mini_ml/screens/account/account_legal.dart';
import 'package:mini_ml/screens/account/account_licenses.dart';
import 'package:mini_ml/screens/account/account_privacy_and_security.dart';
import 'package:mini_ml/screens/miscellaneous/re_auth.dart';
import 'package:mini_ml/screens/miscellaneous/support_screen.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/helpers.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'account_email.dart';

class AccountManage extends StatefulWidget {
  const AccountManage({super.key});

  @override
  State<AccountManage> createState() => _AccountManageState();
}

class _AccountManageState extends State<AccountManage> {
  void _back() {
    Navigator.pop(context);
  }

  void _exit() {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  void _pushToDisplayName() {
    Helpers.pushTo(context, const AccountDisplayName());
  }

  void _pushToReAuth(String route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReAuth(route: route),
      ),
    );
  }

  void _pushToPhone() {
    Helpers.pushTo(context, const AccountPrivacyAndSecurity());
  }

  void _pushToPrivacyAndSecurity() {
    Helpers.pushTo(context, const AccountPrivacyAndSecurity());
  }

  void _pushToLegal() {
    Helpers.pushTo(context, const AccountLegal());
  }

  void _pushToLicenses() {
    Helpers.pushTo(context, const AccountLicenses());
  }

  Future<void> _pushToTermsOfService() async {
    try {
      final Uri uri = Uri(
        scheme: 'https',
        path: 'machinename.dev/Mini ML - Terms of Service.pdf',
      );

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch ${uri.path}');
      }
    } catch (error) {
      _showSnackBar('Error Occured');
      throw Exception(
        error.toString(),
      );
    }
  }

  Future<void> _pushToPrivacyPolicy() async {
    try {
      final Uri uri = Uri(
        scheme: 'https',
        path: 'machinename.dev/Mini ML - Privacy Policy.pdf',
      );

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch ${uri.path}');
      }
    } catch (error) {
      _showSnackBar('Error Occured');
      throw Exception(
        error.toString(),
      );
    }
  }

  void _showSnackBar(String string, {Color? color}) {
    Dialogs.showSnackBar(context, string, color: color);
  }

  Future<void> _signOut(AppProvider appProvider) async {
    try {
      bool? isSignOut = await Dialogs.showConfirmDialog(
          context, "Are you sure you want to sign out?");
      if (isSignOut == true) {
        appProvider.signOut();
        appProvider.resetProviderState();
        _exit();
      }
    } catch (error) {
      _showSnackBar('Error Occured');

      throw Exception(
        error.toString(),
      );
    }
  }

  // Future<void> _pushToSupport() async {
  //   try {
  //     final Uri uri = Uri(
  //       scheme: 'https',
  //       path: 'machinename.dev/contact',
  //     );

  //     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
  //       throw Exception('Could not launch ${uri.path}');
  //     }
  //   } catch (error) {
  //     _showSnackBar('Error Occured');
  //     throw Exception(
  //       error.toString(),
  //     );
  //   }
  // }

  void _pushToSupport() {
    Helpers.pushTo(context, const SupportScreen());
  }

  Widget _buildBody(AppProvider appProvider) {
    String? providerDisplayName = appProvider.auth.currentUser!.displayName;
    var displayName = "";
    if (providerDisplayName != null) {
      displayName = providerDisplayName;
    }
    String? providerEmail = appProvider.auth.currentUser!.email;
    var email = "";
    if (providerEmail != null) {
      email = providerEmail;
    }
    String? providerPhoneNumber = appProvider.auth.currentUser!.phoneNumber;
    var phoneNumber = "";
    if (providerPhoneNumber != null) {
      phoneNumber = providerPhoneNumber;
    }

    return ListView(physics: const ClampingScrollPhysics(), children: [
      const ListTile(title: Text('Info')),
      ListTile(
          title: const Text("Display Name"),
          subtitle: displayName.isNotEmpty ? Text(displayName) : null,
          leading: const Icon(Icons.person_outlined),
          onTap: () => _pushToDisplayName(),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
        leading: const Icon(Icons.email_outlined),
        title: const Text("Email"),
        subtitle: email.isNotEmpty ? Text(email) : null,
        onTap: () => _pushToReAuth('email'),
        trailing: const Icon(Icons.chevron_right_sharp),
      ),
      ListTile(
        leading: const Icon(Icons.phone_outlined),
        title: const Text(
          "Phone",
        ),
        subtitle: phoneNumber.isNotEmpty ? Text(phoneNumber) : null,
        onTap: () => _pushToPhone(),
        trailing: const Icon(Icons.chevron_right_sharp),
      ),
      const ListTile(
          title: Text(
        'General',
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
      ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: const Text("Notifications"),
        onTap: () => _pushToPrivacyAndSecurity(),
        trailing: const Icon(Icons.chevron_right_sharp),
      ),
      ListTile(
          leading: const Icon(Icons.help_outline_outlined),
          title: const Text("Mini ML - Support"),
          onTap: () => _pushToSupport(),
          trailing: const Icon(Icons.chevron_right_sharp)),
      const ListTile(title: Text('Data & Security')),
      ListTile(
          leading: const Icon(Icons.fingerprint_outlined),
          title: const Text("Enable Biometric Authentication"),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.password_outlined),
          title: const Text("Password"),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text("Privacy"),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
      const Divider(),
      Column(children: [
        ListTile(
          title: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constants.getPaddingHorizontal(context) * 4,
            ),
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: "Mini ML's ",
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _pushToPrivacyPolicy();
                            },
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          )),
                      const TextSpan(text: ', '),
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _pushToTermsOfService();
                            },
                          text: 'Terms of Service',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          )),
                      const TextSpan(text: ', and '),
                      TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _pushToTermsOfService();
                            },
                          text: 'Open Source Software',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          )),
                      const TextSpan(text: '.'),
                    ])),
          ),
        ),
        const ListTile(
            title: Text('GitHub Twitter', textAlign: TextAlign.center)),
        const ListTile(
            title: Text('App Version - 1.00.0', textAlign: TextAlign.center))
      ]),
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
