import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/account/account_manage.dart';
import 'package:mini_ml/screens/data/data_create.dart';
import 'package:mini_ml/screens/home/dashboard.dart';
import 'package:mini_ml/screens/data/data_screen.dart';
import 'package:mini_ml/screens/model/model_screen.dart';
import 'package:mini_ml/screens/model/modal_create.dart';
import 'package:mini_ml/screens/project/project_create.dart';
import 'package:mini_ml/screens/project/project_manage.dart';
import 'package:mini_ml/screens/project/projects.dart';
import 'package:mini_ml/utils/helpers.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentTabIndex = 0;

  final List<Widget> _pages = const [
    Dashboard(),
    ModelScreen(),
    DataScreen(),
  ];

  void _pushToDataCreate() {
    Helpers.pushTo(context, const DataCreate());
  }

  void _pushToCreateProject() {
    Helpers.pushTo(context, const ProjectCreate());
  }

  void _pushToCreateModel() {
    Helpers.pushTo(context, const ModalCreate());
  }

  void _pushToManageProject() {
    Helpers.pushTo(context, const ProjectManage());
  }

  void _pushToAccountScreen() {
    Helpers.pushTo(context, const AccountManage());
  }

  void _pushToSearchProjects() {
    Helpers.pushTo(context, const Projects());
  }

  _buildBody() {
    return _pages[_currentTabIndex];
  }

  _buildAppBar(BuildContext context, AppProvider appProvider) {
    return AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        // titleSpacing: 2,
        // leading: const Icon(Icons.cloud_sharp),
        title: ListTile(
            title: const Text('Project',
                style: TextStyle(fontWeight: FontWeight.w300)),
            subtitle: Row(children: [
              Text(appProvider.projectProvider.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              // const Icon(Icons.arrow_drop_down)
            ]),
            // trailing: appProvider.projectProvider.name.isNotEmpty
            //     ? const Icon(Icons.chevron_right_sharp)
            //     : null,
            onTap: appProvider.projectProvider.name.isNotEmpty
                ? () => _pushToManageProject()
                : null),
        centerTitle: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.search_sharp),
              onPressed: () => _pushToSearchProjects()),
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (appProvider.auth.currentUser?.emailVerified == false) {
                  Dialogs.showMessageDialog(context, "Email Verification",
                      "Please verify your email address to create a project!");
                } else {
                  _pushToCreateProject();
                }
              }),
          IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () => _pushToAccountScreen())
        ]);
  }

  _buildBottomNavigationBar() {
    return NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        selectedIndex: _currentTabIndex,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_sharp), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.model_training_sharp), label: 'Models'),
          NavigationDestination(
              icon: Icon(Icons.data_array_sharp), label: 'Data')
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(
          appBar: _buildAppBar(context, appProvider),
          body: _buildBody(),
          floatingActionButton: _currentTabIndex == 0
              ? null
              : FloatingActionButton(
                  onPressed: () {
                    if (appProvider.auth.currentUser?.emailVerified == false &&
                        _currentTabIndex == 1) {
                      Dialogs.showMessageDialog(context, "Email Verification",
                          "Please verify your email address to create a model resource!");
                    } else if (appProvider.auth.currentUser?.emailVerified ==
                            false &&
                        _currentTabIndex == 2) {
                      Dialogs.showMessageDialog(context, "Email Verification",
                          "Please verify your email address to create a data resource!");
                    } else {
                      _handleActionButton(appProvider);
                    }
                  },
                  child: const Icon(Icons.add)),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: _buildBottomNavigationBar());
    });
  }

  void _handleActionButton(AppProvider appProvider) {
    // if (appProvider.auth.currentUser?.emailVerified == false) {
    //   Dialogs.showMessageDialog(context, "Email Verification",
    //       "Please verify your email address to create a resource!");
    // } else
    if (_currentTabIndex == 1 && appProvider.projectProvider.name.isEmpty) {
      Dialogs.showMessageDialog(context, "Create Model",
          "Please select a project first to create a model resource!");
    } else if (_currentTabIndex == 1 &&
        appProvider.projectProvider.data.isEmpty) {
      Dialogs.showMessageDialog(context, "Create Model",
          "No data resources available to create a model, Please create a data resource first.!");
    } else if (appProvider.projectProvider.name.isEmpty &&
        _currentTabIndex == 2) {
      Dialogs.showMessageDialog(context, "Create Data",
          "Please select a project first to create a data resource!");
    } else if (_currentTabIndex == 1) {
      _pushToCreateModel();
    } else {
      _pushToDataCreate();
    }
  }
}
