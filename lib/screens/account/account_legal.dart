import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/account/account_licenses.dart';
import 'package:mini_ml/utils/helpers.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Legal extends StatefulWidget {
  const Legal({super.key});

  @override
  State<Legal> createState() => _LegalState();
}

class _LegalState extends State<Legal> {
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
        path: 'machinename.dev/terms_of_service',
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
        path: 'machinename.dev/privacy_policy',
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
        ListTile(
          leading: const Icon(Icons.description_sharp),
          title: const Text("Terms of Service"),
          onTap: () => _pushToTermsOfService(),
          trailing: const Icon(Icons.chevron_right),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_sharp), 
          title: const Text("Privacy Policy"),
          onTap: () => _pushToPrivacyPolicy(),
          trailing: const Icon(Icons.chevron_right),
        ),
        ListTile(
          leading: const Icon(Icons.library_books_sharp),
          title: const Text("Licenses"),
          onTap: () => _pushToLicenses(),
          trailing: const Icon(Icons.chevron_right),
        ),
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
      title: const Text("Legal"),
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
