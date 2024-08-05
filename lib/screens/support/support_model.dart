import 'package:flutter/material.dart';
import 'package:mini_ml/utils/constants.dart';

class SupportModel extends StatelessWidget {
  const SupportModel({super.key});

  Widget _buildBody(BuildContext context) {
    return ListView(physics: const ClampingScrollPhysics(), children: [
    //   const ListTile(
    //     leading: Icon(Icons.model_training_outlined),
    //     title: Text('Model resources are created from your data resources after training. Below are some tips on how to manage your models.'),
    //   ),
    //  Padding(padding: EdgeInsets.symmetric(horizontal: Constants.getPaddingHorizontal(context)), child: const Divider()),
      ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Creating a model resource'),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text("Editing a model resource name"),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text("Editing a model resource description"),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Deleting a model resource'),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Model - Support"),
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
