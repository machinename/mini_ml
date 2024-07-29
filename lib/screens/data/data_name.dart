import 'package:flutter/material.dart';
import 'package:mini_ml/models/data.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class DataName extends StatefulWidget {
  const DataName({super.key});

  @override
  State<DataName> createState() => _DataNameState();
}

class _DataNameState extends State<DataName> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  bool _isUpdatePressed = false;

  _back() {
    Navigator.pop(context);
  }

  void _showUpdateDataNameDialog(AppProvider appProvider) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm'),
          content: const Text('Are you sure you want to update the name?'),
          actions: [
            TextButton(
              onPressed: () {
                _back();
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                _back();
                _handleUpdateDataName(appProvider);
              },
              child: const Text('YES'),
            ),
          ],
        );
      },
    );
  }

  void _handleUpdateDataName(AppProvider appProvider) async {
    try {
      Data? data = appProvider.projectProvider.currentData;

      if (data == null) {
        _showSnackBar("Data not found");
        return;
      }

      data.name = _nameController.text.trim();
      String projectId = appProvider.projectProvider.id;
      await appProvider.updateResource(projectId, data);
      await appProvider.fetchResources(projectId);
      _back();
    } catch (error) {
      _showSnackBar("Error updating data name: ${error.toString()}");
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
                  maxLength: _nameController.text.length > 35 ? 40 : null,
                  controller: _nameController,
                  validator: (value) {
                    if (_isUpdatePressed) {
                      return Validators.nameValidator(value, "Data");
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter Data Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  })),
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
                        _isUpdatePressed = true;
                      },
                    );
                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      _showUpdateDataNameDialog(appProvider);
                    }
                  }
                : null,
            child: const Text('Update'),
          ),
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
      title: const Text("Data Name"),
      centerTitle: false,
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.symmetric(
      //       horizontal: 4,
      //     ),
      //     child: TextButton(
      //       onPressed: _nameController.text.isNotEmpty
      //           ? () {
      //               setState(
      //                 () {
      //                   _isUpdatePressed = true;
      //                 },
      //               );
      //               if (_formKey.currentState != null &&
      //                   _formKey.currentState!.validate()) {
      //                 _showUpdateDataNameDialog(appProvider);
      //               }
      //             }
      //           : null,
      //       child: const Text('Update Name'),
      //     ),
      //   ),
      // ],
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
