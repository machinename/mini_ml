import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/account/account_licenses.dart';
import 'package:mini_ml/utils/helpers.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountLegal extends StatefulWidget {
  const AccountLegal({super.key});

  @override
  State<AccountLegal> createState() => _AccountLegalState();
}

class _AccountLegalState extends State<AccountLegal> {
  void _back() {
    Navigator.pop(context);
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

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
  }

  _buildBody(AppProvider appProvider) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [
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
      title: const Text("Account Legal"),
      centerTitle: false,
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
