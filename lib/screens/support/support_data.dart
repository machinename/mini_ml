import 'package:flutter/material.dart';
import 'package:mini_ml/utils/constants.dart';

class SupportData extends StatelessWidget {
  const SupportData({super.key});

  Widget _buildBody(BuildContext context) {
    return ListView(physics: const ClampingScrollPhysics(), children: [
      // const ListTile(
      //   leading: Icon(Icons.account_tree_outlined, size: 40),
      // ),
      // const ListTile(
      //   leading: Icon(Icons.data_array_outlined),
      //   title: Text('Data resources are files that you upload to your project for '
      //       'training models. Below are some tips on how to manage your data.'),
      // ),
      // Padding(padding: EdgeInsets.symmetric(horizontal: Constants.getPaddingHorizontal(context)), child: const Divider()),
      ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Creating a data resource'),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text("Editing a data resource name"),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text("Editing a data resource description"),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Deleting a data resource'),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Data - Support"),
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_sharp),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: _buildBody(context));
  }
}
