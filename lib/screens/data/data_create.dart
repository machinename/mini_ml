import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:mini_ml/models/data.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/services/api_services.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class DataCreate extends StatefulWidget {
  const DataCreate({super.key});

  @override
  State<DataCreate> createState() => _DataCreateState();
}

class _DataCreateState extends State<DataCreate> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _dataSetPath = "";
  String _dataSetPathShort = "";
  bool _isCreatePressed = false;
  DataType? _dataType;

  void _back() {
    Navigator.pop(context);
  }

  void _createData(AppProvider appProvider) async {
    try {
      Data data = Data(
        name: _nameController.text.trim(),
        description: _descriptionController.text,
        dataType: _dataType,
      );
      var projectId = appProvider.projectProvider.id;
      User? user = appProvider.auth.currentUser;

      if (user == null) {
        _showSnackBar("User Not Found");
        return;
      }

      appProvider.setIsLoading(true);
      bool resourceExist =
          await appProvider.checkForExisitingResource(projectId, data);
      if (resourceExist) {
        appProvider.setIsLoading(false);
        _showSnackBar("Data with the same name already exists!");
        return;
      }

      await APIServices()
          .createResource(projectId, data, user, dataPath: _dataSetPath);
      await appProvider.fetchResources(projectId);
      appProvider.setIsLoading(false);
      _back();
      _showSnackBar("Data Created Successfully");
    } catch (error) {
      appProvider.setIsLoading(false);
      _showSnackBar(error.toString());
      throw Exception(error.toString());
    }
  }

  void _showFilePicker(AppProvider appProvider) async {
    try {
      List<String>? allowedExtensions;
      if (_dataType == DataType.tabular) {
        allowedExtensions = [
          'csv',
        ];
      }
      //  else if (_dataType == DataSetType.image) {
      //   fileType = FileType.image;
      // } else if (_dataType == DataSetType.video) {
      //   fileType = FileType.video;
      // }
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        setState(() {
          _dataSetPath = file.path;
          _dataSetPathShort = file.path.split('/').last;
        });
      }
    } catch (error) {
      // throw ();
    } 
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
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
            vertical: Constants.getPaddingHorizontal(context),
          ),
          children: [
            Form(
              key: _formKey,
              child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Constants.getPaddingHorizontal(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        maxLength: _nameController.text.length > 35 ? 40 : null,
                        controller: _nameController,
                        validator: (value) {
                          if (_isCreatePressed) {
                            return Validators.nameValidator(value, "Data");
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) {
                          setState(
                            () {},
                          );
                        },
                      ),
                      SizedBox(
                        height: Constants.getPaddingVertical(context),
                      ),
                      TextFormField(
                          maxLength: _descriptionController.text.length > 75
                              ? 100
                              : null,
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_isCreatePressed) {
                              return Validators.descriptionValidator(
                                  value, "Data");
                            }
                            return null;
                          },
                          onChanged: (_) {
                            setState(
                              () {},
                            );
                          }),
                      SizedBox(height: Constants.getPaddingVertical(context)),
                      DropdownMenu<String>(
                        label: const Text('Type'),
                        width: MediaQuery.of(context).size.width * .94,
                        menuHeight: MediaQuery.of(context).size.height * .5,
                        requestFocusOnTap: true,
                        leadingIcon: const Icon(Icons.search),
                        onSelected: (selectedValue) {
                          if (selectedValue != null) {
                            switch (selectedValue) {
                              case 'image':
                                setState(() {
                                  // _dataType = DataSetType.image;
                                });
                                break;
                              case 'tabular':
                                setState(() {
                                  if (_dataType != DataType.tabular) {
                                    _dataSetPathShort = "";
                                    _dataSetPath = "";
                                  }
                                  _dataType = DataType.tabular;
                                });
                                break;
                              case 'text':
                                setState(() {
                                  // _dataType = DataSetType.text;
                                });
                                break;
                              case 'video':
                                setState(() {
                                  // _dataType = DataSetType.video;
                                });
                                break;
                              default:
                                throw ArgumentError(
                                    'Unknown ml_model_type: $selectedValue');
                            }
                          }
                        },
                        dropdownMenuEntries:
                            DataType.values.map<DropdownMenuEntry<String>>(
                          (entry) {
                            return DropdownMenuEntry<String>(
                                value: entry.name, label: entry.name);
                          },
                        ).toList(),
                      ),
                      SizedBox(
                          height: Constants.getPaddingVertical(context) - 2),
                    ],
                  )),
            ),
            ListTile(
                title: _dataType != null
                    ? Text(
                        '${_dataType.toString().split('.').last.replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match.group(0)!.toUpperCase())} File')
                    : const Text('Select Type First'),
                subtitle: Text('File: $_dataSetPathShort'),
                enabled: _dataType != null,
                onTap: () => _showFilePicker(appProvider),
                trailing: const Icon(Icons.file_upload))
          ])
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
      title: const Text("New Data"),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
          ),
          child: TextButton(
            onPressed: _nameController.text.isNotEmpty &&
                    _dataSetPath.isNotEmpty &&
                    _dataType != null
                ? () {
                    setState(
                      () {
                        _isCreatePressed = true;
                      },
                    );
                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      _createData(appProvider);
                    }
                  }
                : null,
            child: const Text('Create'),
          ),
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
