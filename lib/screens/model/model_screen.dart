import 'package:flutter/material.dart';
import 'package:mini_ml/models/model.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/model/modal_manage.dart';
import 'package:provider/provider.dart';

class ModelScreen extends StatefulWidget {
  const ModelScreen({super.key});

  @override
  ModelScreenState createState() => ModelScreenState();
}

class ModelScreenState extends State<ModelScreen> {
  final GlobalKey<RefreshIndicatorState> _modelRefreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  void _pushToManageModel(AppProvider appProvider) {
    Navigator.push(
        context,
        MaterialPageRoute(
            maintainState: false, builder: (context) => const ModelManage()));
  }

  _buildBody(AppProvider appProvider) {
    _modelTypeIcon(model) {
      switch (model.modelType) {
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

    return Column(
      children: [
        const ListTile(
          title: Text('Models',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          trailing: Icon(Icons.search_sharp),
        ),
        Expanded(
            child: ListView.builder(
                itemCount: appProvider.projectProvider.models.length,
                itemBuilder: (context, index) {
                  final model = appProvider.projectProvider.models[index];
                  return ListTile(
                      leading: _modelTypeIcon(model),
                      style: ListTileStyle.list,
                      title: Text(model.name),
                      subtitle: Text('Created at - ${model.createdAt}'),
                      onTap: () {
                        appProvider.projectProvider.currentModel = model;
                        _pushToManageModel(appProvider);
                      },
                      trailing: const Icon(Icons.chevron_right_sharp));
                }))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return Scaffold(
            body: RefreshIndicator(
                key: _modelRefreshIndicatorKey,
                strokeWidth: 3.0,
                onRefresh: () async {
                  if (appProvider.projectProvider.name.isEmpty) {
                    await appProvider.fetchAppData();
                  } else {
                    print(
                        'Fetching data for project: ${appProvider.projectProvider.name}');
                    await appProvider
                        .fetchResources(appProvider.projectProvider.id);
                  }
                },
                child: _buildBody(appProvider)));
      },
    );
  }
}
