import 'package:flutter/material.dart';
import 'package:mini_ml/models/project.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class ProjectDescription extends StatefulWidget {
  const ProjectDescription({super.key});

  @override
  State<ProjectDescription> createState() => _ProjectDescriptionState();
}

class _ProjectDescriptionState extends State<ProjectDescription> {
  bool _isCreatePressed = false;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();

  void _back() {
    Navigator.pop(context);
  }

  Future<void> _handleUpdateProjectDescription(AppProvider appProvider) async {
    try {
      Project project = appProvider.projectProvider;
      bool? isSave = await Dialogs.showConfirmDialog(
          context, 'Are you sure you want to update the project description?');
      if (isSave == true) {
        project.description = _descriptionController.text.trim();
        await appProvider.updateProject(project);
        await appProvider.fetchProjects();
        _back();
      }
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  _buildBody(AppProvider appProvider) {
    return ListView(
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
                          _descriptionController.text.length > 75 ? 100 : null,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Enter Project Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_isCreatePressed) {
                          return Validators.descriptionValidator(
                              value, "Project");
                        }
                        return null;
                      },
                      onChanged: (_) {
                        setState(
                          () {},
                        );
                      }),
                  SizedBox(height: Constants.getPaddingVertical(context))
                ]))
      ],
    );
  }

  _buildAppBar(AppProvider appProvider) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          _back();
        },
      ),
      title: const Text("Project Description"),
      centerTitle: false,
      actions: [
        TextButton(
          onPressed: _descriptionController.text.isNotEmpty
              ? () {
                  setState(
                    () {
                      _isCreatePressed = true;
                    },
                  );
                  if (_formKey.currentState != null &&
                      _formKey.currentState!.validate()) {
                    _handleUpdateProjectDescription(appProvider);
                  }
                }
              : null,
          child: const Text("Save"),
        ),
      ],
    );
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
