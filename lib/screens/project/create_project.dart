import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mini_ml/models/project.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/services/api_services.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class CreateProject extends StatefulWidget {
  const CreateProject({
    super.key,
  });

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
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

  void _handleCreateProject(AppProvider appProvider) async {
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

      appProvider.setIsLoading(true);
      bool projectExist = await appProvider.checkForExisitingProject(project);
      if (projectExist) {
        appProvider.setIsLoading(false);
        _showSnackBar("Project Already Exists");
        return;
      } else {
        await APIServices().createProject(project, user);
        await appProvider.fetchProjects(projectName: project.name);
        appProvider.setIsLoading(false);
        _showSnackBar("Project Created Successfully");
        _exit();
      }
    } catch (error) {
      appProvider.setIsLoading(false);
      _showSnackBar(error.toString());
    }
  }

  void _showSnackBar(String message) {
    Dialogs.showSnackBar(context, message);
  }

  void _showErrorDialog(String title, String message) {
    Dialogs.showMessageDialog(context, title, message);
  }

  _buildBody(AppProvider appProvider) {
    return appProvider.isLoading
        ? const Center(child: CircularProgressIndicator.adaptive())
        : ListView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: Constants.getPaddingHorizontal(context),
              vertical: Constants.getPaddingVertical(context),
            ),
            children: [
                Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                              maxLength:
                                  _nameController.text.length > 35 ? 40 : null,
                              controller: _nameController,
                              validator: (value) {
                                if (_isCreatePressed) {
                                  return Validators.nameValidator(
                                      value, 'Project');
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder()),
                              onChanged: (_) {
                                setState(() {});
                              }),
                          SizedBox(
                              height: Constants.getPaddingVertical(context)),
                          TextFormField(
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
                              })
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
        actions: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                  onPressed: _nameController.text.isNotEmpty
                      ? () {
                          setState(() {
                            _isCreatePressed = true;
                          });
                          if (_formKey.currentState != null &&
                              _formKey.currentState!.validate()) {
                            _handleCreateProject(appProvider);
                          }
                        }
                      : null,
                  child: const Text('Create')))
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
