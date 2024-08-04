import 'package:flutter/material.dart';
import 'package:mini_ml/models/model.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/model/modal_manage.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:provider/provider.dart';

class ModelScreen extends StatefulWidget {
  const ModelScreen({super.key});

  @override
  ModelScreenState createState() => ModelScreenState();
}

class ModelScreenState extends State<ModelScreen> {
  String _searchText = "";
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _modelRefreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  void _pushToManageModel(AppProvider appProvider) {
    Navigator.push(
        context,
        MaterialPageRoute(
            maintainState: false, builder: (context) => const ModelManage()));
  }

  _buildBody(AppProvider appProvider) {
    final List<Model> filteredItems = appProvider.projectProvider.models
        .where((Model item) =>
            item.name.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    modelTypeIcon(model) {
      switch (model.modelType) {
        case ModelType.classification:
          return const Icon(Icons.category_outlined);
        case ModelType.computerVision:
          return const Icon(Icons.image_outlined);
        case ModelType.naturalLanguageProcessing:
          return const Icon(Icons.text_fields_outlined);
        case ModelType.regression:
          return const Icon(Icons.trending_up_outlined);
        case ModelType.timeSeriesForecasting:
          return const Icon(Icons.timeline_outlined);
        default:
          return null;
      }
    }

    return Column(
      children: [
        const ListTile(
            title: Text('Models',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24))),
        if (appProvider.projectProvider.models.length > 1)
          Container(
              color: const Color.fromARGB(30, 135, 135, 135),
              child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: Constants.getPaddingHorizontal(context),
                      vertical: 4),
                  child: TextFormField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                          hintText: 'Search your models',
                          border: InputBorder.none),
                      onChanged: (value) {
                        setState(() {
                          _searchText = value;
                        });
                      }))),
        Expanded(
            child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final model = filteredItems[index];
                  return ListTile(
                      leading: modelTypeIcon(model),
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
