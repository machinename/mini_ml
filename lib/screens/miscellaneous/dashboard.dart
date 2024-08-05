import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/support/support_screen.dart';
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

  void _pushToSupport() {
    Helpers.pushTo(context, const SupportScreen());
  }

  void _resendEmail(AppProvider appProvider) async {
    try {
      bool? resendEmail = await Dialogs.showConfirmDialog(
          context, "Are you sure you want to resend the email verification?");

      if (resendEmail != null && resendEmail == true) {
        appProvider.setIsLoading(true);
        appProvider.sendEmailVerification();
        appProvider.setIsLoading(false);
        _showSnackBar(
            'Email verification has been sent to the email address on file.');
      }
    } catch (error) {
      appProvider.setIsLoading(false);
      _showSnackBar(error.toString());
    }
  }

  void _refreshUser(AppProvider appProvider) async {
    try {
      appProvider.setIsLoading(true);
      if (appProvider.auth.currentUser != null) {
        await appProvider.auth.currentUser?.reload();
      } else {
        _showSnackBar('User email has been verified.', color: Colors.red);
      }
      appProvider.setIsLoading(false);
      var currentUser = appProvider.auth.currentUser;
      if (currentUser != null) {
        bool emailVerified = currentUser.emailVerified;
        if (emailVerified) {
          _showSnackBar('User email has been verified.', color: Colors.green);
        } else {
          _showSnackBar('User email has not been verified.', color: Colors.red);
        }
      }
    } catch (error) {
      appProvider.setIsLoading(false);
      _showSnackBar(error.toString());
    }
  }

  void _showSnackBar(String string, {Color? color}) {
    Dialogs.showSnackBar(context, string, color: color);
  }

  Widget _buildBody(AppProvider appProvider) {
    if(appProvider.auth.currentUser == null) {
      return const Center(child: Text('User not found'));
    }

    String displayName = '';
    var currentUserDisplayName = appProvider.auth.currentUser?.displayName;
    if (currentUserDisplayName != null) {
      displayName = currentUserDisplayName;
    }

    bool emailVerified = false;
    var currentUser = appProvider.auth.currentUser;
    if (currentUser != null) {
      emailVerified = currentUser.emailVerified;
    }

    return Stack(children: [
      
      if (appProvider.isLoading)
        const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ListView(physics: const ClampingScrollPhysics(), children: [
        const ListTile(
            title: Text('Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24))),
                
        if(displayName.isNotEmpty)
        ListTile(title:Text('Hello, $displayName!') ),
        ListTile(
          leading: const Icon(Icons.account_tree_outlined),
          title: const Text("Projects"),
          subtitle: appProvider.projects.length == 1
              ? Text("${appProvider.projects.length} project")
              : Text("${appProvider.projects.length} projects"),
        ),
        ListTile(
          leading: const Icon(Icons.cloud_outlined),
          title: const Text("Storage"),
          subtitle:
              Text('${appProvider.userStorageInMegaBytes} MB of 100 MB used'),
        ),
        // ListTile(
        //   enabled: !appProvider.isLoading,
        //   leading: const Icon(Icons.help_outline_outlined),
        //   title: const Text("Support"),
        //   onTap: () => _pushToSupport(),
        //   trailing: const Icon(Icons.chevron_right_sharp),
        // ),
        if (emailVerified == false)
          Column(children: [
            ListTile(
                enabled: !appProvider.isLoading,
                leading: const Icon(Icons.email_outlined),
                title: const Text('Resend Verification Email'),
                onTap: () => _resendEmail(appProvider),
                
                
                trailing: const Icon(Icons.chevron_right_sharp)),
            ListTile(
              enabled: !appProvider.isLoading,
              leading:  Icon(Icons.warning_outlined, color: Colors.red[800]),
              title: const Text('Verify your email address!'),
              trailing: TextButton(
                          style: ButtonStyle(
                      foregroundColor: appProvider.isLoading
                          ? WidgetStateProperty.all(Colors.grey[300])
                          : WidgetStateProperty.all(Colors.blue[800])),
                  onPressed: () => _refreshUser(appProvider),
                  child: const Text('Refresh')),
            )
          ])
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
                  // await appProvider.fetchAppData();
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
