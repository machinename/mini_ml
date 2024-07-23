import 'package:flutter/material.dart';
import 'package:mini_ml/models/project.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/project/project_create.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:provider/provider.dart';

class ProjectSearch extends StatefulWidget {
  const ProjectSearch({super.key});

  @override
  State<ProjectSearch> createState() => _ProjectSearchState();
}

class _ProjectSearchState extends State<ProjectSearch> {
  final TextEditingController _controller = TextEditingController();
  String _searchText = "";
  String selected = "";

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

  _buildBody(AppProvider appProvider) {
    final List<Project> filteredItems = appProvider.projects
        .where((Project item) =>
            item.name.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
                hintText: 'Find',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    // borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide())),
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
          ),
        ),
        filteredItems.isEmpty
            ? Padding(
                padding: EdgeInsets.all(Constants.getPaddingVertical(context)),
                child:
                    const Text("It's Looking Empty In Here, Create a Project!"),
              )
            : Expanded(
                child: ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final project = filteredItems[index];
                    return ListTile(
                      leading: filteredItems[index].name ==
                              appProvider.projectProvider.name
                          ? const Icon(Icons.check)
                          : null,
                      title: Text(filteredItems[index].name),
                      onTap: () {
                        if (appProvider.projectProvider.name !=
                            filteredItems[index].name) {
                          _setProject(appProvider, project);
                        }
                      },
                    );
                  },
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return Scaffold(
            appBar: AppBar(
              // shape: Border(
              //     bottom: BorderSide(color: Colors.grey[300]!, width: 1.0)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Search Projects'),
              centerTitle: false,
              actions: [
                IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _pushToCreateProject()),
              ],
            ),
            body: _buildBody(appProvider));
      },
    );
  }
}
