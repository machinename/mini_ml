import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/project/projects.dart';
import 'package:mini_ml/utils/helpers.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  final GlobalKey<RefreshIndicatorState> _dashboardRefreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  void _pushToSearchProjects(BuildContext context) {
    Helpers.pushTo(context, const Projects());
  }

  void _resendEmail(AppProvider appProvider) {
    try {
      appProvider.setIsLoading(true);
      appProvider.sendEmailVerification();
      appProvider.setIsLoading(false);
    } catch (error) {
      appProvider.setIsLoading(false);
      _showSnackBar(error.toString());
    }
  }

  void _fetchAppData(AppProvider appProvider) {
    try {
      appProvider.setIsLoading(true);
      appProvider.refreshUserToken();
      appProvider.setIsLoading(false);
    } catch (error) {
      appProvider.setIsLoading(false);
      _showSnackBar(error.toString());
    }
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
  }

  Widget _projectMessage(AppProvider appProvider) {
    if (appProvider.projects.isEmpty) {
      return const Text("Let's get started by creating a project");
    } else if (appProvider.projects.length == 1) {
      return Text("${appProvider.projects.length} project");
    } else {
      return Text("${appProvider.projects.length} projects");
    }
  }

  Widget _buildBody(AppProvider appProvider) {
    String? displayName = appProvider.auth.currentUser?.displayName;
    bool emailVerified = false;
    var currentUser = appProvider.auth.currentUser;
    if (currentUser != null) {
      emailVerified = currentUser.emailVerified;
      print("Is email verified $emailVerified");
    }

    return ListView(physics: const ClampingScrollPhysics(), children: [
      const ListTile(
          title: Text('Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24))),
      // ListTile(title: _welcomeMessage(context, appProvider)),
      ListTile(
          enabled: !appProvider.isLoading,
          leading: const Icon(Icons.account_tree_sharp),
          title: const Text("Projects"),
          subtitle: _projectMessage(appProvider),
          onTap: () => _pushToSearchProjects(context),
          trailing: const Icon(Icons.chevron_right_sharp)),
      if (emailVerified == false)
        Column(children: [
          ListTile(
              enabled: !appProvider.isLoading,
              leading: const Icon(Icons.email_sharp),
              title: const Text('Resend Verification Email'),
              onTap: () => _resendEmail(appProvider),
              trailing: const Icon(Icons.chevron_right_sharp)),
          ListTile(
            enabled: !appProvider.isLoading,
            leading: const Icon(Icons.warning_sharp, color: Colors.red),
            title: const Text('Verify your email address!'),
            trailing: TextButton(
                onPressed: () => _fetchAppData(appProvider),
                child: const Text('Refresh')),
          )
        ])
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(
          body: RefreshIndicator(
              key: _dashboardRefreshIndicatorKey,
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
    });
  }
}
