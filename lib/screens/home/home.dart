import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/account/manage_account.dart';
import 'package:mini_ml/screens/data/create_data.dart';
import 'package:mini_ml/screens/home/dashboard.dart';
import 'package:mini_ml/screens/home/data_screen.dart';
import 'package:mini_ml/screens/home/model_screen.dart';
import 'package:mini_ml/screens/model/create_model.dart';
import 'package:mini_ml/screens/project/create_project.dart';
import 'package:mini_ml/screens/project/manage_project.dart';
import 'package:mini_ml/screens/project/search_projects.dart';
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

  void _pushToCreateData() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const CreateData()));
  }

  void _pushToCreateProject() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const CreateProject()));
  }

  void _pushToCreateModel() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const CreateModel()));
  }

  void _pushToManageProject() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ManageProject()));
  }

  void _pushToAccountScreen() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const ManageAccount()));
  }

  void _pushToSearchProjects() {
    Navigator.push(
        context,
        MaterialPageRoute(
            maintainState: false, builder: (context) => const SearchProject()));
  }

  _buildBody() {
    return _pages[_currentTabIndex];
  }

  _buildAppBar(BuildContext context, AppProvider appProvider) {
    return AppBar(
        automaticallyImplyLeading: false,
        // titleSpacing: 0,
        // titleSpacing: 2,
        // leading: const Icon(Icons.cloud_sharp),
        title: ListTile(
            title: const Text('Project',
                style: TextStyle(fontWeight: FontWeight.w300)),
            subtitle: Row(children: [
              Text(appProvider.projectProvider.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Icon(Icons.arrow_drop_down)
            ]),
            onTap: () => _pushToSearchProjects()),
        centerTitle: false,
        actions: [
          if (appProvider.projectProvider.name.isNotEmpty)
            IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _pushToManageProject()),
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _pushToCreateProject()),
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
          body: appProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(),
          floatingActionButton: _currentTabIndex == 0
              ? null
              : FloatingActionButton(
                  onPressed: () => _handleActionButton(appProvider),
                  child: const Icon(Icons.add)),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          bottomNavigationBar: _buildBottomNavigationBar());
    });
  }

  void _handleActionButton(AppProvider appProvider) {
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
      _pushToCreateData();
    }
  }
}
