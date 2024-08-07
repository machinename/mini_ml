import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/miscellaneous/re_auth.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:provider/provider.dart';

class AccountPrivacyAndSecurity extends StatefulWidget {
  const AccountPrivacyAndSecurity({
    super.key,
  });

  @override
  State<AccountPrivacyAndSecurity> createState() =>
      _AccountPrivacyAndSecurityState();
}

class _AccountPrivacyAndSecurityState extends State<AccountPrivacyAndSecurity> {
  void _back() {
    Navigator.pop(context);
  }

  void _pushToReAuth(String route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReAuth(route: route),
      ),
    );
  }

  _buildBody(AppProvider appProvider) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Constants.getPaddingHorizontal(context),
      ),
      children: [
        const ListTile(
          title: Text("Enable biometric authentication"),
        ),
        ListTile(
          title: const Text("Send Password Reset Link"),
          onTap: () => _pushToReAuth('password'),
          trailing: const Icon(Icons.chevron_right),
        ),
        ListTile(
            title: const Text("Delete Your Account"),
            subtitle: const Text("Delete your entire account and data"),
            onTap: () {
              _pushToReAuth('delete');
            },
            trailing: const Icon(Icons.chevron_right)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Account Security"),
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_sharp),
              onPressed: () {
                _back();
              },
            ),
          ),
          body: _buildBody(appProvider),
        );
      },
    );
  }
}
