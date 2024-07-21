import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/data/manage_data.dart';
import 'package:provider/provider.dart';

class DataScreen extends StatelessWidget {
  const DataScreen({super.key});

  static final GlobalKey<RefreshIndicatorState> _dataRefreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  void _pushToManageData(BuildContext context, AppProvider appProvider) {
    Navigator.push(
        context,
        MaterialPageRoute(
            maintainState: false,
            allowSnapshotting: false,
            builder: (context) => const ManageData()));
  }

  Widget _buildBody(BuildContext context, AppProvider appProvider) {
    return Column(children: [
      const ListTile(
        title: Text('Data',
            style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 30)),
      ),
      Expanded(
          child: ListView.builder(
              itemCount: appProvider.projectProvider.data.length,
              itemBuilder: (context, index) {
                final data = appProvider.projectProvider.data[index];
                return ListTile(
                    title: Text(data.name),
                    subtitle: Text('Created at - ${data.createdAt}'),
                    onTap: () {
                      appProvider.projectProvider.currentData = data;
                      _pushToManageData(context, appProvider);
                    },
                    trailing: const Icon(Icons.chevron_right));
              })),
    ]);

    // ListView.builder(
    //     itemCount: appProvider.projectProvider.data.length,
    //     itemBuilder: (context, index) {
    //       final data = appProvider.projectProvider.data[index];
    //       return ListTile(
    //           title: Text(data.name),
    //           subtitle: Text('Created at - ${data.createdAt}'),
    //           onTap: () {
    //             appProvider.projectProvider.currentData = data;
    //             _pushToManageData(context, appProvider);
    //           },
    //           trailing: const Icon(Icons.chevron_right));
    //     });
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
