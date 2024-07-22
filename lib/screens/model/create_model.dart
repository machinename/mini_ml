import 'package:flutter/material.dart';
import 'package:mini_ml/models/model.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/model/train_model.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/validators.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class CreateModel extends StatefulWidget {
  const CreateModel({super.key});

  @override
  State<CreateModel> createState() => _CreateModelState();
}

class _CreateModelState extends State<CreateModel> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isCreatePressed = false;
  String _dataId = '';
  String _dataName = '';
  String _dataType = '';
  ModelType? _modelType;

  void _back() {
    Navigator.pop(context);
  }

  void _handleNext(AppProvider appProvider) async {
    try {
      Model model = Model(
        name: _nameController.text,
        dataId: _dataId,
        dataName: _dataName,
        description: _descriptionController.text,
        modelType: _modelType,
      );

      var dataVariables = appProvider.projectProvider.data
          .firstWhere((element) => element.id == _dataId)
          .variables;

      var projectId = appProvider.projectProvider.id;

      bool resourceExist =
          await appProvider.checkForExisitingResource(projectId, model);
      if (resourceExist) {
        _showSnackBar("Model with the same name already exists!");
        return;
      } else {
        print(_dataId);

        _pushToCreateModelSettings(dataVariables, model);
      }
    } catch (error) {
      _showSnackBar(error.toString());
    }
  }

  void _pushToCreateModelSettings(
    Map<String, dynamic> dataVariables,
    Model model,
  ) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TrainModel(
                  dataVariables: dataVariables,
                  mode: 'create',
                  model: model,
                )));
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
  }

  _buildBody(AppProvider appProvider) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      // padding: EdgeInsets.symmetric(
      //     horizontal: Constants.getPaddingHorizontal(context),
      //     vertical: Constants.getPaddingVertical(context)),
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Constants.getPaddingHorizontal(context),
                vertical: Constants.getPaddingVertical(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  maxLength: _nameController.text.length > 35 ? 40 : null,
                  controller: _nameController,
                  enabled: appProvider.projectProvider.data.isNotEmpty,
                  validator: (value) {
                    if (_isCreatePressed) {
                      return Validators.nameValidator(value, "Model");
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                ),
                SizedBox(
                  height: Constants.getPaddingVertical(context),
                ),
                TextFormField(
                    maxLength:
                        _descriptionController.text.length > 75 ? 100 : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    enabled: appProvider.projectProvider.data.isNotEmpty,
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_isCreatePressed) {
                        return Validators.descriptionValidator(value, "Model");
                      }
                      return null;
                    },
                    onChanged: (_) {
                      setState(
                        () {},
                      );
                    }),
                SizedBox(height: Constants.getPaddingVertical(context)),
                // appProvider.projectProvider.data.isEmpty
                //     ? TextFormField(
                //         decoration: const InputDecoration(
                //           labelText: 'Add A Data Resource To Create Model',
                //           border: OutlineInputBorder(),
                //         ),
                //         onChanged: null,
                //         // enabled: false,
                //       )
                //     :

                DropdownMenu<String>(
                  label: const Text('Select Data'),
                  width: MediaQuery.of(context).size.width * .94,
                  menuHeight: MediaQuery.of(context).size.height * .5,
                  requestFocusOnTap: true,
                  enabled: appProvider.projectProvider.data.isNotEmpty,
                  leadingIcon: appProvider.projectProvider.data.isEmpty
                      ? null
                      : const Icon(Icons.search),
                  onSelected: (selectedValue) {
                    if (selectedValue != null) {
                      print(
                        selectedValue
                            .split(',')[1]
                            .split('.')
                            .last
                            .replaceFirstMapped(
                              RegExp(r'^(.)'),
                              (match) => match.group(0)!.toUpperCase(),
                            ),
                      );
                      String dataSetValue =
                          selectedValue.split(',')[1].split('.').last;
                      switch (dataSetValue) {
                        case 'image':
                          setState(() {
                            _dataType = 'image';
                          });
                          break;
                        case 'tabular':
                          setState(() {
                            _dataType = 'tabular';
                          });
                          break;
                        case 'text':
                          setState(() {
                            _dataType = 'text';
                          });
                          break;
                        case 'video':
                          setState(() {
                            _dataType = 'video';
                          });
                          break;

                        default:
                          throw ArgumentError(
                              'Unknown ml_model_type: $selectedValue');
                      }
                      _dataId = selectedValue.split(',')[0];
                      _dataName = selectedValue.split(',')[2];
                    }
                  },
                  dropdownMenuEntries: appProvider.projectProvider.data
                      .map<DropdownMenuEntry<String>>(
                        (entry) => DropdownMenuEntry<String>(
                          value: '${entry.id},${entry.dataType},${entry.name}',
                          label:
                              "${entry.name}: ${entry.dataType.toString().split('.').last.replaceFirstMapped(
                                    RegExp(r'^(.)'),
                                    (match) => match.group(0)!.toUpperCase(),
                                  )}",
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        ListTile(
          title: const Text('Classification - Coming Soon'),
          subtitle: const Text('To predict categories, etc.'),
          // enabled: _dataType == 'tabular',
          enabled: false,
          selected: _modelType == ModelType.classification,
          selectedColor: Colors.amber,
          onTap: () {
            setState(() {
              _modelType = ModelType.classification;
            });
          },
        ),
        ListTile(
          title: const Text('Computer Vison - Coming Soon'),
          subtitle: const Text('To predict objects using images, videos, etc.'),
          // enabled: _dataType == 'image' || _dataType == 'video',
          enabled: false,
          onTap: () {
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('Natural Language Processing - Coming Soon'),
          subtitle: const Text('To predict sentiment, language, etc.'),
          // enabled: _dataType == 'text',
          enabled: false,
          selected: _modelType == ModelType.naturalLanguageProcessing,
          selectedColor: Colors.amber,
          onTap: () {
            setState(() {
              _modelType = ModelType.naturalLanguageProcessing;
            });
          },
        ),
        ListTile(
          title: const Text('Regression'),
          subtitle: const Text('To predict continuous numeric values'),
          enabled: _dataType == 'tabular',
          selected: _modelType == ModelType.regression,
          selectedColor: Colors.amber,
          onTap: () {
            setState(() {
              _modelType = ModelType.regression;
            });
          },
        ),
        ListTile(
          title: const Text('Time Series Forecasting - Coming Soon'),
          subtitle:
              const Text('To predict future values based on time series data'),
          // enabled: _dataType == 'tabular',
          enabled: false,
          selected: _modelType == ModelType.timeSeriesForecasting,
          selectedColor: Colors.amber,
          onTap: () {
            setState(() {
              _modelType = ModelType.timeSeriesForecasting;
            });
          },
        ),
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
      title: const Text("New Model"),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
          ),
          child: TextButton(
            onPressed: _formKey.currentState != null &&
                    _formKey.currentState!.validate() &&
                    // _nameController.text.isNotEmpty &&
                    _dataId.isNotEmpty &&
                    _modelType != null
                ? () {
                    setState(
                      () {
                        _isCreatePressed = true;
                      },
                    );
                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      _handleNext(appProvider);
                    }
                  }
                : null,
            child: const Text('Next'),
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
