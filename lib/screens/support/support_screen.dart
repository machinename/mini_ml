import 'package:flutter/material.dart';
import 'package:mini_ml/screens/support/support_account.dart';
import 'package:mini_ml/screens/support/support_data.dart';
import 'package:mini_ml/screens/support/support_project.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/helpers.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({
    super.key,
  });

  void _back(BuildContext context) {
    Navigator.pop(context);
  }

  void _pushToSupportAccount(BuildContext context) {
    Helpers.pushTo(context, const SupportAccount());
  }

  void _pushToSupportProject(BuildContext context) {
    Helpers.pushTo(context, const SupportProject());
  }

  void _pushToSupportData(BuildContext context) {
    Helpers.pushTo(context, const SupportData());
  }

  void _pushToSupportModel(BuildContext context) {
    Helpers.pushTo(context, const SupportProject());
  }

  Future<void> _pushToContactUs() async {
    try {
      final Uri uri = Uri(
        scheme: 'https',
        path: 'machinename.dev/contact',
      );
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch ${uri.path}');
      }
    } catch (error) {
      throw Exception(
        error.toString(),
      );
    }
  }


  _buildBody(BuildContext context) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      children: [

        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text("Account"),
          onTap: () => _pushToSupportAccount(context),
          trailing: const Icon(Icons.chevron_right),
        ),
        ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: const Text("Project"),
            onTap: () => _pushToSupportProject(context),
            trailing: const Icon(Icons.chevron_right)),
        ListTile(
            leading: const Icon(Icons.data_array_outlined),
            title: const Text("Data"),
            onTap: () => _pushToSupportData(context),
            trailing: const Icon(Icons.chevron_right)),
        ListTile(
            leading: const Icon(Icons.model_training_outlined),
            title: const Text("Model"),
            onTap: () => _pushToSupportModel(context),
            trailing: const Icon(Icons.chevron_right)),
        ListTile(
            leading: const Icon(Icons.chat_outlined),
            title: const Text("Contact Us"),
            onTap: () => _pushToContactUs(),
            trailing: const Icon(Icons.chevron_right)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Support"),
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_sharp),
              onPressed: () {
                _back(context);
              },
            ),
          ),
          body: _buildBody(context),
        );
  }
}
