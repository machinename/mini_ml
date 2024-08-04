import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/miscellaneous/re_auth.dart';
import 'package:mini_ml/screens/miscellaneous/support_builder.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:provider/provider.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({
    super.key,
  });

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  void _back() {
    Navigator.pop(context);
  }

  void _pushToSupportBuilder(String route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupportBuilder(route: route),
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
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text("Account"),
          onTap: () => _pushToSupportBuilder('account'),
          trailing: const Icon(Icons.chevron_right),
        ),
        ListTile(
            leading: const Icon(Icons.account_tree_outlined),
            title: const Text("Project"),
            onTap: () => _pushToSupportBuilder('project'),
            trailing: const Icon(Icons.chevron_right)),
        ListTile(
            leading: const Icon(Icons.data_array_outlined),
            title: const Text("Data"),
            onTap: () => _pushToSupportBuilder('data'),
            trailing: const Icon(Icons.chevron_right)),
        ListTile(
            leading: const Icon(Icons.model_training_outlined),
            title: const Text("Model"),
            onTap: () => _pushToSupportBuilder('model'),
            trailing: const Icon(Icons.chevron_right)),
        ListTile(
            leading: const Icon(Icons.chat_outlined),
            title: const Text("Contact Us"),
            onTap: () => (),
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
            title: const Text("Mini ML - Support"),
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
