import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  static final GlobalKey<RefreshIndicatorState> _dashboardRefreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Widget _welcomeMessage(BuildContext context, AppProvider appProvider) {
    return const Text(
      'Welcome to mini ML!',
      textAlign: TextAlign.start,
    );
  }

  _buildBody(BuildContext context, AppProvider appProvider) {
    String? displayName = appProvider.auth.currentUser?.displayName;
    return Column(children: [
      const ListTile(
        title: Text('Dashboard', style: TextStyle(fontSize: 30)),
      ),
      ListTile(title: _welcomeMessage(context, appProvider)),
      Expanded(
          child: ListView(physics: const ClampingScrollPhysics(), children: [
        Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Constants.getPaddingHorizontal(context),
                vertical: Constants.getPaddingVertical(context)),
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    // color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(10)),
                child: const Column(children: [
                  ListTile(
                      title: Text('mini ML status',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.start)),
                  ListTile(
                      leading:
                          Icon(Icons.check_circle_sharp, color: Colors.green),
                      title: Text('mini ML services report normal status'))
                ]))),
        ListTile(
          title: const Text(
            'Projects',
          ),
          subtitle: Text(appProvider.projects.length.toString()),
        ),
      ])),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(body: _buildBody(context, appProvider));
    });
  }
}
