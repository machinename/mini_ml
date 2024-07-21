import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/project/project_description.dart';
import 'package:mini_ml/screens/project/project_name.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class ManageProject extends StatefulWidget {
  const ManageProject({super.key});

  @override
  State<ManageProject> createState() => _ManageProjectState();
}

class _ManageProjectState extends State<ManageProject> {
  bool _showDeleteDialog = false;

  void _back() {
    Navigator.pop(context);
  }

  void _deleteProject(AppProvider appProvider) async {
    try {
      var project = appProvider.projectProvider;
      await appProvider.deleteProject(project);
      await appProvider.fetchProjects();
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  Future<String?> _showDeleteProjectDialog(
      BuildContext context, AppProvider appProvider) {
    final TextEditingController projectController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title:
                  Text('Delete project: ${appProvider.projectProvider.name}'),
              content: !_showDeleteDialog
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Are you sure you want to delete the project "${appProvider.projectProvider.name}"?',
                          textAlign: TextAlign.left,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'To confirm, type "${appProvider.projectProvider.name}" in the box below.',
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(
                            height: Constants.getPaddingVertical(context) - 4),
                        Form(
                          key: formKey,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            controller: projectController,
                            onChanged: (_) {
                              setState(
                                () {},
                              );
                            },
                          ),
                        ),
                        SizedBox(
                            height: Constants.getPaddingVertical(context) - 4),
                        Text(
                          'This will permanently delete the project "${appProvider.projectProvider.name}" and all of its assoicated resources.',
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
              actions: [
                // if (!_showDeleteDialog)
                TextButton(
                  onPressed: !_showDeleteDialog
                      ? () {
                          setState(() {
                            _showDeleteDialog = true;
                          });
                        }
                      : null,
                  child: const Text('YES'),
                ),
                TextButton(
                  onPressed:
                      projectController.text == appProvider.projectProvider.name
                          ? () {
                              _deleteProject(appProvider);
                            }
                          : null,
                  child: const Text('DELETE'),
                ),
                TextButton(
                  onPressed: () {
                    // setState(() {
                    //   _showDeleteDialog = false;
                    // });
                    Navigator.of(context).pop(null);
                    // _back();
                  },
                  child: const Text('CANCEL'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _pushToProjectDescription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProjectDescription(),
      ),
    );
  }

  void _pushToProjectName() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProjectName(),
      ),
    );
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
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
              : const Text('N/A'),
          onTap: () => _pushToProjectDescription()),
      ListTile(
        title: const Text("Resources"),
        subtitle: Text(
            "${appProvider.projectProvider.data.length + appProvider.projectProvider.models.length} resources"),
      ),
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
                setState(() {
                  _showDeleteDialog = false;
                });
                _showDeleteProjectDialog(context, appProvider);
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
