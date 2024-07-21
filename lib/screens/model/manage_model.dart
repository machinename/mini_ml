import 'package:flutter/material.dart';
import 'package:mini_ml/models/model.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class ManageModel extends StatefulWidget {
  const ManageModel({super.key});

  @override
  State<ManageModel> createState() => _ManageModelState();
}

class _ManageModelState extends State<ManageModel> {
  void _back() {
    Navigator.pop(context);
  }

  void _pushToModelName() {
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => ModelName(model: widget.model)));
  }

  void _pushToModelDescription() {
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => ModelDescription(model: widget.model)));
  }
  _modelTypeIcon(AppProvider appProvider) {
    switch (appProvider.projectProvider.currentModel?.modelType) {
      case ModelType.classification:
        return const Icon(Icons.category);
      case ModelType.computerVision:
        return const Icon(Icons.image);
      case ModelType.naturalLanguageProcessing:
        return const Icon(Icons.text_fields);
      case ModelType.regression:
        return const Icon(Icons.trending_up);
      case ModelType.timeSeriesForecasting:
        return const Icon(Icons.timeline);
      default:
        return null;
    }
  }

  _handleDeleteModel(AppProvider appProvider) async {
    try {
      bool? isDeleteModel = await Dialogs.showConfirmDialog(context,
          "Are you sure you want to delete your model? This action is irreversible!");
      if (isDeleteModel == true) {
        Model? model = appProvider.projectProvider.currentModel;
        if (model == null) {
          _showSnackBar("Model not found");
          return;
        }
        var projectId = appProvider.projectProvider.id;
        await appProvider.deleteResource(projectId, model);
        await appProvider.fetchResources(projectId);
        _back();
        _showSnackBar("Model Deleted Successfully");
      } else {
        _back();
      }
    } catch (error) {
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
    Model? model = appProvider.projectProvider.currentModel;
    if (model == null) {
      return const Center(
        child: Text("Model not found"),
      );
    } else {
      return Column(
        children: [
          ListTile(
            title: const Text('Name'),
            subtitle: Text(model.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pushToModelName,
          ),
          ListTile(
              title: const Text('Description'),
              trailing: const Icon(Icons.chevron_right),
              subtitle: model.description.isNotEmpty
                  ? Text(model.description)
                  : const Text('N/A'),
              onTap: () => _pushToModelDescription()),
          ListTile(
            leading: _modelTypeIcon(appProvider),
            title: const Text('Model Type'),
            subtitle: Text(model.modelType
                .toString()
                .split('.')
                .last
                .replaceFirstMapped(RegExp(r'^[a-z]'),
                    (match) => match.group(0)!.toUpperCase())),
          ),
          ListTile(
            leading: const Icon(Icons.data_array),
            title: const Text('Data Name'),
            subtitle: Text(model.dataName),
          ),
          ListTile(
            leading: const Icon(Icons.label),
            title: const Text('Label'),
            subtitle: Text(model.label),
          ),
          ListTile(
            leading: const Icon(Icons.timeline),
            title: const Text('Evaluation Metrics'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => (),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Predict'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => (),
          ),
          ListTile(
            leading: const Icon(Icons.model_training),
            title: const Text('Train'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => (),
          ),
        ],
      );
    }
  }

  _buildAppBar(AppProvider appProvider) {
    return AppBar(
      leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp),
          onPressed: () {
            _back();
          }),
      title: const Text('Manage Model'),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_sharp),
          onPressed: () => _handleDeleteModel(appProvider),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(
          appBar: _buildAppBar(appProvider), body: _buildBody(appProvider));
    });
  }
}
