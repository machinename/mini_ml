import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/model/model_metrics.dart';
import 'package:mini_ml/utils/helpers.dart';
import 'package:provider/provider.dart';

class ModelEvaluation extends StatefulWidget {
  const ModelEvaluation({super.key});

  @override
  ModelEvaluationState createState() => ModelEvaluationState();
}

class ModelEvaluationState extends State<ModelEvaluation> {
  void _pushToMetric(String metric, String value) {
    Helpers.pushTo(context, Metrics(metric: metric, value: value));
  }

  void _back() {
    Navigator.pop(context);
  }

  _buildBody(AppProvider appProvider) {
    final metrics =
        appProvider.projectProvider.currentModel?.evaluationMetrics.entries;
    if (metrics == null) {
      return const Center(child: Text("No Evaluation Metrics Found"));
    } else {
      return ListView.builder(
          physics: const ClampingScrollPhysics(),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final String metric = metrics.elementAt(index).key;
            final String value = metrics.elementAt(index).value.toString();
            return ListTile(
              style: ListTileStyle.list,
              title: Text(metric.toUpperCase()),
              subtitle: Text(value),
              onTap: () => _pushToMetric(metric, value),
              trailing: const Icon(Icons.chevron_right),
            );
          });
    }
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
