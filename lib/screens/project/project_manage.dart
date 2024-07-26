import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/project/project_delete.dart';
import 'package:mini_ml/screens/project/project_description.dart';
import 'package:mini_ml/screens/project/project_name.dart';
import 'package:mini_ml/utils/helpers.dart';
import 'package:provider/provider.dart';

class ProjectManage extends StatefulWidget {
  const ProjectManage({super.key});

  @override
  State<ProjectManage> createState() => _ProjectManageState();
}

class _ProjectManageState extends State<ProjectManage> {
  void _back() {
    Navigator.pop(context);
  }

  void _pushToProjectDescription() {
    Helpers.pushTo(context, const ProjectDescription());
  }

  void _pushToProjectName() {
    Helpers.pushTo(context, const ProjectName());
  }

  void _pushToProjectDelete() {
    Helpers.pushTo(context, const ProjectDelete());
  }

  _buildBody(AppProvider appProvider) {
    return ListView(physics: const ClampingScrollPhysics(), children: [
      ListTile(
          trailing: const Icon(Icons.chevron_right),
          title: const Text("Name"),
          subtitle: Text(appProvider.projectProvider.name),
          onTap: () => _pushToProjectName()),
      ListTile(
          trailing: const Icon(Icons.chevron_right),
          title: const Text("Description"),
          subtitle: appProvider.projectProvider.description.isNotEmpty
              ? Text(appProvider.projectProvider.description)
              : null,
          onTap: () => _pushToProjectDescription()),
      ListTile(
          title: const Text("Resources"),
          subtitle: appProvider.projectProvider.data.length +
                      appProvider.projectProvider.models.length ==
                  1
              ? Text(
                  "${appProvider.projectProvider.data.length + appProvider.projectProvider.models.length} resource")
              : Text(
                  "${appProvider.projectProvider.data.length + appProvider.projectProvider.models.length} resources"))
    ]);
  }

  _buildAppBar(AppProvider appProvider) {
    return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _back(),
        ),
        title: const Text("Project"),
        centerTitle: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.delete_sharp),
              onPressed: () {
                _pushToProjectDelete();
              }),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(
          appBar: _buildAppBar(appProvider),
          body: appProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(appProvider));
    });
  }
}
