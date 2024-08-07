import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mini_ml/models/project.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/services/api_services.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class ProjectCreate extends StatefulWidget {
  const ProjectCreate({
    super.key,
  });

  @override
  State<ProjectCreate> createState() => _ProjectCreateState();
}

class _ProjectCreateState extends State<ProjectCreate> {
  bool _isCreatePressed = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _back() {
    Navigator.pop(context);
  }

  void _exit() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _handleProjectCreate(AppProvider appProvider) async {
    try {
      Project project = Project(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      User? user = appProvider.auth.currentUser;

      if (user == null) {
        _showErrorDialog('Auth Error', 'Please login to create a project');
        appProvider.signOut();
        return;
      }

      bool projectExist = await appProvider.checkForExistingProject(project);
      if (projectExist) {
        _showSnackBar("Project already exists");
        return;
      } else {
        appProvider.setIsLoading(true);
        await APIServices().createProject(project, user);
        await appProvider.fetchProjects(projectName: project.name);
        appProvider.setIsLoading(false);
        _showSnackBar("New project:  ${project.name} added to database.",
            color: Colors.green);
        _exit();
      }
    } catch (error) {
      appProvider.setIsLoading(false);
      _showSnackBar(error.toString(), color: Colors.red);
    }
  }

  void _showSnackBar(String message, {Color? color}) {
    Dialogs.showSnackBar(context, message, color: color);
  }

  void _showErrorDialog(String title, String message) {
    Dialogs.showMessageDialog(context, title, message);
  }

  _buildBody(AppProvider appProvider) {
    return Stack(children: [
      if (appProvider.isLoading)
        const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Constants.getPaddingHorizontal(context),
              vertical: Constants.getPaddingVertical(context)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                          enabled: appProvider.isLoading == false,
                          maxLength:
                              _nameController.text.length > 30 ? 40 : null,
                          controller: _nameController,
                          validator: (value) {
                            if (_isCreatePressed) {
                              return Validators.nameValidator(value, 'Project');
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                              labelText: 'Name', border: OutlineInputBorder()),
                          onChanged: (_) {
                            setState(() {});
                          }),
                      SizedBox(height: Constants.getPaddingVertical(context)),
                      TextFormField(
                          enabled: appProvider.isLoading == false,
                          maxLength: _descriptionController.text.length > 75
                              ? 100
                              : null,
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder()),
                          validator: (value) {
                            if (_isCreatePressed) {
                              return Validators.descriptionValidator(
                                  value, "Project");
                            }
                            return null;
                          },
                          onChanged: (_) {
                            setState(() {});
                          }),
                      SizedBox(
                          height: Constants.getPaddingVertical(context) - 4),
                      ElevatedButton(
                        onPressed: _nameController.text.isNotEmpty &&
                                !appProvider.isLoading
                            ? () {
                                setState(() {
                                  _isCreatePressed = true;
                                });
                                if (_formKey.currentState != null &&
                                    _formKey.currentState!.validate()) {
                                  _handleProjectCreate(appProvider);
                                }
                              }
                            : null,
                        style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero)),
                        ),
                        child: const Text('Create'),
                      )
                    ]))
          ]))
    ]);
  }

  _buildAppBar(AppProvider appProvider) {
    return AppBar(
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _back();
          }),
      title: const Text("New Project"),
      centerTitle: false,
      // actions: [
      //   Padding(
      //       padding: const EdgeInsets.symmetric(horizontal: 4),
      //       child: TextButton(
      //           onPressed:
      //               _nameController.text.isNotEmpty && !appProvider.isLoading
      //                   ? () {
      //                       setState(() {
      //                         _isCreatePressed = true;
      //                       });
      //                       if (_formKey.currentState != null &&
      //                           _formKey.currentState!.validate()) {
      //                         _handleProjectCreate(appProvider);
      //                       }
      //                     }
      //                   : null,
      //           child: const Text('Create')))
      // ]
    );
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
