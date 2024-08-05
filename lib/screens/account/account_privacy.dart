import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/miscellaneous/re_auth.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:provider/provider.dart';

class AccountPrivacy extends StatefulWidget {
  const AccountPrivacy({
    super.key,
  });

  @override
  State<AccountPrivacy> createState() =>
      _AccountPrivacyState();
}

class _AccountPrivacyState extends State<AccountPrivacy> {
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

  void _downloadData(AppProvider appProvider) async {
    try {
      appProvider.setIsLoading(true);
      // await appProvider.downloadData();
      appProvider.setIsLoading(false);
    } catch (error) {
      appProvider.setIsLoading(false);
      throw Exception(
        error.toString(),
      );
    }
  }

  _buildBody(AppProvider appProvider) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Constants.getPaddingHorizontal(context),
      ),
      children: [


        ListTile(
            title: const Text("Download Your Data"),
            subtitle: const Text("Download all of your data"),
            onTap: () {
              _pushToReAuth('delete');
            },
            trailing: const Icon(Icons.chevron_right)),
                    ListTile(
            title: const Text("Delete Your Account"),
            subtitle: const Text("Delete your entire account and data"),
            onTap: () {
              _downloadData(appProvider);
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
            title: const Text("Privacy"),
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
