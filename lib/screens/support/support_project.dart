import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:provider/provider.dart';

class SupportProject extends StatelessWidget {
  const SupportProject({super.key});

  Widget _buildBody(BuildContext context, AppProvider appProvider) {
    return ListView(physics: const ClampingScrollPhysics(), children: [
      // const ListTile(
      //   leading: Icon(Icons.account_tree_outlined, size: 40),
      // ),
      // const ListTile(
      //   leading: Icon(Icons.account_tree_outlined),
      //   title: Text('Projects are containers for your resources. Below are '
      //       'some tips on how to manage your projects.'),
      // ),
      // Padding(padding: EdgeInsets.symmetric(horizontal: Constants.getPaddingHorizontal(context)), child: const Divider()),
      ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Creating a project'),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Editing a project name'),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Editing a project description'),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Deleting a project description'),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Project - Support"),
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_sharp),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: _buildBody(context, appProvider));
    });
  }
}
