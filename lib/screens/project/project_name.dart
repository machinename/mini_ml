import 'package:flutter/material.dart';
import 'package:mini_ml/models/project.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class ProjectName extends StatefulWidget {
  const ProjectName({super.key});

  @override
  State<ProjectName> createState() => _ProjectNameState();
}

class _ProjectNameState extends State<ProjectName> {
  bool _isSavePressed = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  void _back() {
    Navigator.pop(context);
  }

  _buildAppBar(AppProvider appProvider) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          _back();
        },
      ),
      title: const Text("Project Name"),
      centerTitle: false,
      // actions: [
      //   TextButton(
      //     onPressed: _nameController.text.isNotEmpty
      //         ? () {
      //             setState(
      //               () {
      //                 _isSavePressed = true;
      //               },
      //             );
      //             if (_formKey.currentState != null &&
      //                 _formKey.currentState!.validate()) {
      //               _handleUpdateProjectName(appProvider);
      //             }
      //           }
      //         : null,
      //     child: const Text('Save'),
      //   ),
      // ],
    );
  }

  _buildBody(AppProvider appProvider) {
    return Stack(children: [
      if (appProvider.isLoading)
        const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ListView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: Constants.getPaddingHorizontal(context),
          vertical: Constants.getPaddingVertical(context),
        ),
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              enabled: !appProvider.isLoading,
              maxLength: _nameController.text.length > 35 ? 40 : null,
              controller: _nameController,
              validator: (value) {
                if (_isSavePressed) {
                  return Validators.nameValidator(value, 'Project');
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Enter Project Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(
                  () {},
                );
              },
            ),
          ),
          SizedBox(height: Constants.getPaddingVertical(context) - 4),
          ElevatedButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero)),
            ),
            onPressed: _nameController.text.isNotEmpty
                ? () {
                    setState(
                      () {
                        _isSavePressed = true;
                      },
                    );
                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      _handleUpdateProjectName(appProvider);
                    }
                  }
                : null,
            child: const Text('Update'),
          ),
        ],
      )
    ]);
  }

  Future<void> _handleUpdateProjectName(AppProvider appProvider) async {
    try {
      Project project = appProvider.projectProvider;
      bool? isSave = await Dialogs.showConfirmDialog(
          context, 'Are you sure you want to update the project name?');
      if (isSave == true) {
        appProvider.setIsLoading(true);
        project.name = _nameController.text.trim();
        await appProvider.updateProject(project);
        await appProvider.fetchProjects();
        appProvider.setIsLoading(false);
        _back();
      }
    } catch (error) {
      appProvider.setIsLoading(false);
      throw Exception(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(
        appBar: _buildAppBar(appProvider),
        body: _buildBody(appProvider),
      );
    });
  }
}
