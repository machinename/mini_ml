import 'package:flutter/material.dart';
import 'package:mini_ml/models/model.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/model/model_delete.dart';
import 'package:mini_ml/screens/model/model_description.dart';
import 'package:mini_ml/screens/model/model_evaluation.dart';
import 'package:mini_ml/screens/model/model_name.dart';
import 'package:mini_ml/utils/helpers.dart';
import 'package:provider/provider.dart';

import 'package:share_plus/share_plus.dart';

class ModelManage extends StatefulWidget {
  const ModelManage({super.key});

  @override
  State<ModelManage> createState() => _ModelManageState();
}

class _ModelManageState extends State<ModelManage> {
  void _back() {
    Navigator.pop(context);
  }

  void _downloadModel() {}

  void _shareModel() async {
    // if (await file.exists()) {
    await Share.share('');
    // } else {
    //   print('File does not exist');
    // }
  }

  void shareFile() async {}

  void _pushToModelName() {
    Helpers.pushTo(context, const ModelName());
  }

  void _pushToModelDescription() {
    Helpers.pushTo(context, const ModelDescription());
  }

  void _pushToModelDelete() {
    Helpers.pushTo(context, const ModelDelete());
  }

  void _pushToEvaluationMetrics() {
    Helpers.pushTo(context, const ModelEvaluation());
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

  _buildBody(AppProvider appProvider) {
    Model? model = appProvider.projectProvider.currentModel;
    if (model == null) {
      return const Center(child: Text("Model not found"));
    } else {
      return ListView(physics: const ClampingScrollPhysics(), children: [
        const ListTile(
          title: Text("Info"),
        ),
        ListTile(
          leading: const Icon(Icons.edit_note_sharp),
          title: const Text('Name'),
          subtitle: Text(model.name),
          trailing: const Icon(Icons.chevron_right),
          onTap: _pushToModelName,
        ),
        ListTile(
            leading: const Icon(Icons.description_sharp),
            title: const Text('Description'),
            trailing: const Icon(Icons.chevron_right),
            subtitle:
                model.description.isNotEmpty ? Text(model.description) : null,
            onTap: () => _pushToModelDescription()),
        ListTile(
            leading: _modelTypeIcon(appProvider),
            title: const Text('Model Type'),
            subtitle: Text(model.modelType
                .toString()
                .split('.')
                .last
                .replaceFirstMapped(RegExp(r'^[a-z]'),
                    (match) => match.group(0)!.toUpperCase()))),
        ListTile(
            leading: const Icon(Icons.data_array_sharp),
            title: const Text('Training Data'),
            subtitle: Text(model.dataName)),
        ListTile(
            leading: const Icon(Icons.label_sharp),
            title: const Text('Label'),
            subtitle: Text(model.label)),
        ListTile(
            leading: const Icon(Icons.list_sharp),
            title: const Text('Evaluation Metrics'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pushToEvaluationMetrics())
      ]);
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
              onPressed: () {
                _pushToModelDelete();
              }),
          IconButton(
              icon: const Icon(Icons.download_sharp),
              onPressed: () {
                // _downloadModel();
              }),
          IconButton(
              icon: const Icon(Icons.share_sharp),
              onPressed: () {
                _shareModel();
              }),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(
          appBar: _buildAppBar(appProvider), body: _buildBody(appProvider));
    });
  }
}
