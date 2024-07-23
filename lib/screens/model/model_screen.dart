  import 'package:flutter/material.dart';
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
    return Column(
      children: [
        const ListTile(
          title: Text('Models',
              style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 30)),
        ),
        Expanded(
            child: ListView.builder(
                itemCount: appProvider.projectProvider.models.length,
                itemBuilder: (context, index) {
                  final model = appProvider.projectProvider.models[index];
                  return ListTile(
                    leading: const Icon(Icons.model_training_sharp),
                      style: ListTileStyle.list,
                      title: Text(model.name),
                      subtitle: Text('Created at - ${model.createdAt}'),
                      onTap: () {
                        appProvider.projectProvider.currentModel = model;
                        _pushToManageModel(appProvider);
                      },
                      trailing: const Icon(Icons.chevron_right));
                })),
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
