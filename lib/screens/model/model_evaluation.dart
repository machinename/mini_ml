import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:provider/provider.dart';

class ModelEvaluation extends StatefulWidget {
  const ModelEvaluation({super.key});

  @override
  ModelEvaluationState createState() => ModelEvaluationState();
}

class ModelEvaluationState extends State<ModelEvaluation> {
  void _back() {
    Navigator.pop(context);
  }

  _buildBody(AppProvider appProvider) {
    final metrics =
        appProvider.projectProvider.currentModel?.evaluationMetrics.entries;
    if (metrics == null) {
      return const Center(child: Text("No Evaluation Metrics Found"));
    }

    ListView.builder(
        itemCount: metrics.length,
        itemBuilder: (context, index) {
          return ListTile(
              leading: const Icon(Icons.model_training_sharp),
              style: ListTileStyle.list,
              title: Text(metrics.elementAt(index).key),
              subtitle: Text(
                metrics.elementAt(index).value.toString(),
              ));
        });
  }

  _buildAppBar(AppProvider appProvider) {
    return AppBar(
      leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp),
          onPressed: () {
            _back();
          }),
      title: const Text('Evaluation Metrics'),
      centerTitle: false,
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
