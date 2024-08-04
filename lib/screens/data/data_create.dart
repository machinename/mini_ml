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
  final TextEditingController _typeController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _typeFocusNode = FocusNode();

  String _dataSetPath = "";
  String _dataSetPathShort = "";

  DataType? _dataType;

  Widget? _fileTypeIcon;

  bool _isCreatePressed = false;

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _typeFocusNode.dispose();
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
        _showSnackBar("User Not Found", color: Colors.red);
        return;
      }

      appProvider.setIsLoading(true);
      bool resourceExist =
          await appProvider.checkForExistingResource(projectId, data);
      if (resourceExist) {
        appProvider.setIsLoading(false);
        _showSnackBar("Data with the same name already exists!",
            color: Colors.red);
        return;
      }

      await APIServices()
          .createResource(projectId, data, user, dataPath: _dataSetPath);
      await appProvider.fetchResources(projectId);
      appProvider.setIsLoading(false);
      _back();
      _showSnackBar("Data resource '${data.name}' has been created.",
          color: Colors.green);
    } catch (error) {
      appProvider.setIsLoading(false);
      _showSnackBar(error.toString(), color: Colors.red);
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

  void _showSnackBar(String string, {Color? color}) {
    Dialogs.showSnackBar(context, string, color: color);
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
            vertical: Constants.getPaddingVertical(context),
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
                        maxLength: _nameController.text.length > 30 ? 40 : null,
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
                    ],
                  )),
            ),
            Center(
                child: DropdownMenu<String>(
              focusNode: _typeFocusNode,
              controller: _typeController,
              enableSearch: !appProvider.isLoading,
              label: const Text('Type'),
              width: MediaQuery.of(context).orientation == Orientation.portrait
                  ? MediaQuery.of(context).size.width * .94
                  : MediaQuery.of(context).size.width * .88,
              menuHeight: MediaQuery.of(context).size.height * .5,
              enabled: !appProvider.isLoading,
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
                      _typeFocusNode.unfocus();
                      throw ArgumentError(
                          'Unknown ml_model_type: $selectedValue');
                  }
                }
                _typeFocusNode.unfocus();
              },
              enableFilter: true,
              dropdownMenuEntries: DataType.values
                  .map<DropdownMenuEntry<String>>(
                    (entry) => DropdownMenuEntry<String>(
                        value: entry.name, label: entry.name),
                  )
                  .toList(),
            )),
            SizedBox(height: Constants.getPaddingVertical(context)),
            ListTile(
                leading: _fileTypeIcon,
                title: _dataSetPathShort.isNotEmpty
                    ? Text(_dataSetPathShort)
                    : const Text('Select a file'),
                enabled: _dataType != null,
                onTap: () => _showFilePicker(appProvider),
                trailing: const Icon(Icons.file_upload)),
            SizedBox(height: Constants.getPaddingVertical(context) - 2),
            Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.getPaddingHorizontal(context),
                ),
                child: ElevatedButton(
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
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero)),
                  ),
                  child: const Text('Create'),
                ))
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
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.symmetric(
      //       horizontal: 4,
      //     ),
      //     child: TextButton(
      //       onPressed: _nameController.text.isNotEmpty &&
      //               _dataSetPath.isNotEmpty &&
      //               _dataType != null
      //           ? () {
      //               setState(
      //                 () {
      //                   _isCreatePressed = true;
      //                 },
      //               );
      //               if (_formKey.currentState != null &&
      //                   _formKey.currentState!.validate()) {
      //                 _createData(appProvider);
      //               }
      //             }
      //           : null,
      //       child: const Text('Create'),
      //     ),
      //   ),
      // ],
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
