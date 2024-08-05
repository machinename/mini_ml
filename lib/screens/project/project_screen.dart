import 'package:flutter/material.dart';
import 'package:mini_ml/models/project.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/project/project_create.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  static final GlobalKey<RefreshIndicatorState> _projecrRefreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  // bool _showGreenIcon = false;
  // Timer? _blinkTimer;

  // @override
  // void initState() {
  //   super.initState();
  //   _startBlinking();
  // }

  // @override
  // void dispose() {
  //   _blinkTimer?.cancel();
  //   super.dispose();
  // }

  void _back() {
    Navigator.pop(context);
  }

  void _pushToCreateProject() {
    Navigator.push(
      context,
      MaterialPageRoute(
        maintainState: false,
        builder: (context) => const ProjectCreate(),
      ),
    );
  }

  void _setProject(AppProvider appProvider, Project project) async {
    await appProvider.setProjectProvider(project);
    _back();
  }

  // void _startBlinking() {
  //   _blinkTimer = Timer.periodic(const Duration(milliseconds: 1250), (timer) {
  //     setState(() {
  //       _showGreenIcon = !_showGreenIcon;
  //     });
  //   });
  // }

  _buildBody(AppProvider appProvider) {
    final List<Project> filteredItems = appProvider.projects
        .where((Project item) =>
            item.name.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
    return Column(children: [
      if (appProvider.projects.length > 1)
        Container(
            color: const Color.fromARGB(30, 135, 135, 135),
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Constants.getPaddingHorizontal(context),
                    vertical: 4),
                child: TextFormField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                        hintText: 'Search your projects',
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
                final project = filteredItems[index];
                return ListTile(
                    leading: project.name == appProvider.projectProvider.name
                        ? const Icon(Icons.check_outlined)
                        : null,
                    title: Text(project.name),
                    selected: project.name == appProvider.projectProvider.name,
                    selectedColor: Colors.blue,
                    onTap: () {
                      if (appProvider.projectProvider.name != project.name) {
                        _setProject(appProvider, project);
                      }
                    });
              }))
    ]);
  }

  _buidlAppBar(AppProvider appProvider) {
    return AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Projects'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_box_outlined,
              // color: appProvider.projects.isEmpty && _showGreenIcon
              //     ? Colors.green
              //     : null, // Conditionally set color
            ),
            onPressed: () {
              if (appProvider.auth.currentUser?.emailVerified == false) {
                Dialogs.showMessageDialog(context, "Email Verification!",
                    "Please verify your email address to create a project!");
              } else {
                _pushToCreateProject();
              }
            },
          )
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return Scaffold(
            appBar: _buidlAppBar(appProvider),
            body: RefreshIndicator(
                key: _projecrRefreshIndicatorKey,
                strokeWidth: 3.0,
                onRefresh: () async {
                  if (appProvider.projectProvider.name.isEmpty) {
                    await appProvider.fetchAppData();
                  } else {
                    print('Fetching projects');
                    await appProvider.fetchProjects();
                  }
                },
                child: _buildBody(appProvider)));
      },
    );
  }
}
