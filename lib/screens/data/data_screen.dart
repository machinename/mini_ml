import 'package:flutter/material.dart';
import 'package:mini_ml/models/data.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/data/data_manage.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/utils/helpers.dart';
import 'package:provider/provider.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  String _searchText = "";
  final TextEditingController _searchController = TextEditingController();
  static final GlobalKey<RefreshIndicatorState> _dataRefreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  void _pushToDataManage(BuildContext context, AppProvider appProvider) {
    Helpers.pushTo(context, const DataManage());
  }

  Widget _buildBody(BuildContext context, AppProvider appProvider) {
    final List<Data> filteredItems = appProvider.projectProvider.data
        .where((Data item) =>
            item.name.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
    return Column(children: [
      const ListTile(
          title: Text('Data',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      if (appProvider.projectProvider.data.length > 1)
        Container(
            color: const Color.fromARGB(30, 135, 135, 135),
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Constants.getPaddingHorizontal(context),
                    vertical: 4),
                child: TextFormField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                        hintText: 'Search your data', border: InputBorder.none),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    }))),
      Expanded(
          child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final data = filteredItems[index];
                return ListTile(
                    leading: const Icon(Icons.data_array_outlined),
                    title: Text(data.name),
                    subtitle: Text('Created at - ${data.createdAt}'),
                    onTap: () {
                      appProvider.projectProvider.currentData = data;
                      _pushToDataManage(context, appProvider);
                    },
                    trailing: const Icon(Icons.chevron_right));
              })),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(
          body: RefreshIndicator(
              key: _dataRefreshIndicatorKey,
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
              child: _buildBody(context, appProvider)));
    });
  }
}
