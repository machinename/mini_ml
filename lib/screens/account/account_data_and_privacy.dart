import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/login/re_Auth.dart';
import 'package:provider/provider.dart';

class AccountDataAndPrivacy extends StatefulWidget {
  const AccountDataAndPrivacy({super.key});

  @override
  State<AccountDataAndPrivacy> createState() => _AccountDataAndPrivacyState();
}

class _AccountDataAndPrivacyState extends State<AccountDataAndPrivacy> {
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
            _pushToReAuth('delete');
          },
          trailing: const Icon(Icons.chevron_right)
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(appProvider)
        );
      }
    );
  }
}
