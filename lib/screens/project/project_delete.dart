import 'package:flutter/material.dart';
import 'package:mini_ml/models/project.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class ProjectDelete extends StatefulWidget {
  const ProjectDelete({super.key});

  @override
  State<ProjectDelete> createState() => _ProjectDeleteState();
}

class _ProjectDeleteState extends State<ProjectDelete> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deleteController = TextEditingController();

  void _back() {
    Navigator.pop(context);
  }

  void _exit() {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  void _deleteProject(AppProvider appProvider) async {
    try {
      Project project = appProvider.projectProvider;
      appProvider.setIsLoading(true);
      await appProvider.deleteProject(project);
      await appProvider.fetchProjects();
      appProvider.setIsLoading(false);
      _exit();
      _showSnackBar(
          "Project '${project.name}' and of if resources have been deleted.");
      appProvider.clearProjectProvider();
    } catch (error) {
      appProvider.setIsLoading(false);
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
    return Stack(
      children: [
        if (appProvider.isLoading)
          const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Constants.getPaddingHorizontal(context),
                vertical: Constants.getPaddingVertical(context)),
            child: ListView(
              physics: const ClampingScrollPhysics(),
              children: [
                Text(
                    'This action is irreversible. To confirm type, "${appProvider.projectProvider.name}" in the box below.',
                    textAlign: TextAlign.start),
                SizedBox(height: Constants.getPaddingHorizontal(context)),
                Form(
                    key: _formKey,
                    child: TextFormField(
                        enabled: !appProvider.isLoading,
                        controller: _deleteController,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) {
                          setState(() {});
                        })),
                SizedBox(height: Constants.getPaddingVertical(context) - 4),
                ElevatedButton(
                  onPressed: _deleteController.text ==
                              appProvider.projectProvider.name &&
                          !appProvider.isLoading
                      ? () {
                          _deleteProject(appProvider);
                        }
                      : null,
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero)),
                  ),
                  child: const Text('Delete'),
                )
              ],
            )),
      ],
    );
  }

  _buildAppBar(AppProvider appProvider) {
    return AppBar(
      title: const Text('Delete Project'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_sharp),
        onPressed: () {
          _back();
        },
      ),
      centerTitle: false,
      // actions: [
      //   Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 4),
      //       child: TextButton(
      //         onPressed: _deleteController.text ==
      //                     appProvider.projectProvider.name &&
      //                 !appProvider.isLoading
      //             ? () {
      //                 _deleteProject(appProvider);
      //               }
      //             : null,
      //         child: const Text('Delete'),
      //       ))
      // ]
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
