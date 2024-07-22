import 'package:flutter/material.dart';
import 'package:mini_ml/models/data.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class ModelDescription extends StatefulWidget {
  const ModelDescription({super.key});

  @override
  State<ModelDescription> createState() => _ModelDescriptionState();
}

class _ModelDescriptionState extends State<ModelDescription> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isUpdatePressed = false;

  _back() {
    Navigator.pop(context);
  }

  void _handleUpdateModelDescription(AppProvider appProvider) async {
    try {
      Data? data = appProvider.projectProvider.currentData;

      if (data == null) {
        _showSnackBar("Data not found");
        return;
      }
      bool? isSave = await Dialogs.showConfirmDialog(
          context, 'Are you sure you want to update the project name?');

      if (isSave == true) {
        data.description = _descriptionController.text.trim();
        String projectId = appProvider.projectProvider.id;
        await appProvider.updateResource(projectId, data);
        await appProvider.fetchResources(projectId);
        _back();
      }
    } catch (error) {
      _showSnackBar("Error updating model description: ${error.toString()}");
    }
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
  }

  Widget _buildBody(AppProvider appProvider) {
    return ListView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: Constants.getPaddingHorizontal(context),
          vertical: Constants.getPaddingVertical(context),
        ),
        children: [
          Form(
              key: _formKey,
              child: TextFormField(
                  maxLength:
                      _descriptionController.text.length > 35 ? 40 : null,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  controller: _descriptionController,
                  validator: (value) {
                    if (_isUpdatePressed) {
                      return Validators.descriptionValidator(value, "Model");
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  }))
        ]);
  }

  _buildAppBar(AppProvider appProvider) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          _back();
        },
      ),
      title: const Text("Model Description"),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
          ),
          child: TextButton(
            onPressed: _descriptionController.text.isNotEmpty
                ? () {
                    setState(
                      () {
                        _isUpdatePressed = true;
                      },
                    );
                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      _handleUpdateModelDescription(appProvider);
                    }
                  }
                : null,
            child: const Text('Update'),
          ),
        ),
      ],
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
