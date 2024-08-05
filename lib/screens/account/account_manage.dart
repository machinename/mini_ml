import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/account/account_display_name.dart';
// import 'package:mini_ml/screens/account/account_phone.dart';
import 'package:mini_ml/screens/account/account_privacy.dart';
import 'package:mini_ml/screens/miscellaneous/re_auth.dart';
import 'package:mini_ml/screens/support/support_screen.dart';
import 'package:mini_ml/utils/constants.dart';
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

  void _exit() {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  void _pushToDisplayName(AppProvider appProvider) {
    String displayName = appProvider.auth.currentUser!.displayName ?? "";
    Helpers.pushTo(context, AccountDisplayName(displayName: displayName));
  }

  void _pushToReAuth(String route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReAuth(route: route),
      ),
    );
  }

  // void _pushToPhone() {
  //   Helpers.pushTo(context, const AccountPhone());
  // }

  void _pushToPrivacy() {
    Helpers.pushTo(context, const AccountPrivacy());
  }

  void _pushToOpenSourceSoftware() async {
    try {
      // final Uri uri = Uri(
      //   scheme: 'https',
      //   path: 'machinename.dev/Mini ML - Open Source Software.pdf',
      // );

      // if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      //   throw Exception('Could not launch ${uri.path}');
      // }
    } catch (error) {
      _showSnackBar('Error Occured');
      throw Exception(
        error.toString(),
      );
    }
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
    // String? providerPhoneNumber = appProvider.auth.currentUser!.phoneNumber;
    // var phoneNumber = "";
    // if (providerPhoneNumber != null) {
    //   phoneNumber = providerPhoneNumber;
    // }

    return ListView(physics: const ClampingScrollPhysics(), children: [
      const ListTile(
          title: Text(
        'Info',
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
      ListTile(
          title: const Text("Display Name"),
          subtitle: displayName.isNotEmpty ? Text(displayName) : null,
          leading: const Icon(Icons.person_outlined),
          onTap: () => _pushToDisplayName(appProvider),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
        leading: const Icon(Icons.email_outlined),
        title: const Text("Email"),
        subtitle: email.isNotEmpty ? Text(email) : null,
        onTap: () => _pushToReAuth('email'),
        trailing: const Icon(Icons.chevron_right_sharp),
      ),
      // ListTile(
      //   leading: const Icon(Icons.phone_outlined),
      //   title: const Text(
      //     "Phone",
      //   ),
      //   subtitle: phoneNumber.isNotEmpty ? Text(phoneNumber) : null,
      //   onTap: () => _pushToPhone(),
      //   trailing: const Icon(Icons.chevron_right_sharp),
      // ),

      const ListTile(
          title: Text('Data & Security',
              style: TextStyle(fontWeight: FontWeight.bold))),
      // ListTile(
      //     leading: const Icon(Icons.fingerprint_outlined),
      //     title: const Text("Enable Biometric Authentication"),
      //     onTap: () => (),
      //     trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.password_outlined),
          title: const Text("Password"),
          onTap: () => _pushToReAuth('password'),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text("Privacy"),
          onTap: () => _pushToPrivacy(),
          trailing: const Icon(Icons.chevron_right_sharp)),
      //           const ListTile(
      //     title: Text(
      //   'General',
      //   style: TextStyle(fontWeight: FontWeight.bold),
      // )),
      // ListTile(
      //   leading: const Icon(Icons.notifications_outlined),
      //   title: const Text("Notifications"),
      //   onTap: () => (),
      //   trailing: const Icon(Icons.chevron_right_sharp),
      // ),
      // ListTile(
      //     leading: const Icon(Icons.help_outline_outlined),
      //     title: const Text("Mini ML - Support"),
      //     onTap: () => _pushToSupport(),
      //     trailing: const Icon(Icons.chevron_right_sharp)),
      Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Constants.getPaddingHorizontal(context)),
          child: const Divider()),
      Column(children: [
        SizedBox(height: Constants.getPaddingVertical(context) * 1.5),
        RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _pushToPrivacyPolicy();
                  },
                text: 'PRIVACY POLICY',
                style: const TextStyle(
                  color: Colors.blue,
                ),
                children: [
                  const TextSpan(
                      text: ' / ',
                      style: TextStyle(
                        color: Colors.blue,
                      )),
                  TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _pushToTermsOfService();
                        },
                      text: 'TERMS OF SERVICE',
                      style: const TextStyle(
                        color: Colors.blue,
                      )),
                ])),
        SizedBox(height: Constants.getPaddingVertical(context) * 1.5),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _pushToOpenSourceSoftware();
              },
            text: 'OPEN SOURCE SOFTWARE',
            style: const TextStyle(
              color: Colors.blue,
            ),
          ),
        ),
        SizedBox(height: Constants.getPaddingVertical(context) * 1.5),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                _pushToSupport();
              },
            text: 'SUPPORT',
            style: const TextStyle(
              color: Colors.blue,
            ),
          ),
        ),
        SizedBox(height: Constants.getPaddingVertical(context) * 1.5),
        RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _signOut(appProvider);
                },
              text: 'LOG OUT',
              style: const TextStyle(
                color: Colors.blue,
              ),
            )),
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
      // actions: [
      //   Padding(
      //       padding: const EdgeInsets.symmetric(
      //         horizontal: 4,
      //       ),
      //       child: TextButton(
      //           onPressed: () {
      //             _signOut(appProvider);
      //           },
      //           child: const Text("LOG OUT")))
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
