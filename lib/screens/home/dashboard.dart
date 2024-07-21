import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  _buildBody(BuildContext context, AppProvider appProvider) {
    String? displayName = appProvider.auth.currentUser?.displayName;
    return Column(children: [
      const ListTile(
        title: Text('Dashboard',
            style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 30)),
      ),
      // const ListTile(
      //     title: Text('Welcome! Create a new project to get started')),
      Expanded(
          child: ListView(children: const [
        // Padding(
        //   padding: EdgeInsets.only(
        //       top: 80, left: Constants.getPaddingHorizontal(context)),
        //   child: displayName != null && displayName.isNotEmpty
        //       ? Text('Welcome, ${appProvider.auth.currentUser?.displayName}!',
        //           style: const TextStyle(fontSize: 40),
        //           textAlign: TextAlign.center)
        //       : const Text('Welcome!',
        //           style: TextStyle(fontSize: 40), textAlign: TextAlign.center),
        // )
      ]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return Scaffold(
          body: appProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _buildBody(context, appProvider),
        );
      },
    );
  }
}
