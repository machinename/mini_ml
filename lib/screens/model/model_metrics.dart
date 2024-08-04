import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/metrics_definitions.dart';
import 'package:provider/provider.dart';

class Metrics extends StatelessWidget {
  final String metric;
  final String value;
  const Metrics({super.key, required this.metric, required this.value});

  void _back(BuildContext context) {
    Navigator.pop(context);
  }

  _buildBody(AppProvider appProvider) {
    final String definition =
        MetricsDefinitions().fetchMetricDefinition(metric);
    return ListView(physics: const ClampingScrollPhysics(), children: [
      ListTile(
        title: Text(definition),
      )
    ]);
  }

  _buildAppBar(BuildContext context, AppProvider appProvider) {
    return AppBar(
      leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp),
          onPressed: () {
            _back(context);
          }),
      // title: Text(metric[0].toUpperCase() + metric.substring(1)),
      title: Text(metric.toUpperCase()),
      centerTitle: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(
          appBar: _buildAppBar(context, appProvider),
          body: _buildBody(appProvider));
    });
  }
}
