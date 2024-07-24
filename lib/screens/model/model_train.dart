import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mini_ml/models/model.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/services/api_services.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class TrainModel extends StatefulWidget {
  final Map<String, dynamic> dataVariables;
  final String mode;
  final Model model;

  const TrainModel({
    super.key,
    required this.dataVariables,
    required this.mode,
    required this.model,
  });

  @override
  State<TrainModel> createState() => _TrainModelState();
}

class _TrainModelState extends State<TrainModel> {
  String _label = '';

  void _back() {
    Navigator.pop(context);
  }

  void _exit() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _handleModel(AppProvider appProvider) async {
    try {
      var projectId = appProvider.projectProvider.id;
      User? currentUser = appProvider.auth.currentUser;

      if (currentUser == null) {
        _showSnackBar("Current User Not Found");
        return;
      }

      appProvider.setIsLoading(true);
      if (widget.mode == 'create') {
        widget.model.label = _label;
        setState(() {
          _label = '';
        });
        await APIServices()
            .createResource(projectId, widget.model, currentUser);
      } else {
        // await APIServices().trainModel(projectId, model, currentUser);
      }

      await appProvider.fetchResources(projectId);
      appProvider.setIsLoading(false);
      _showSnackBar("Model Created Successfully");
      _exit();
    } catch (error) {
      appProvider.setIsLoading(false);
      _showSnackBar(error.toString());
    }
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
  }

  _buildBody(AppProvider appProvider) {
    return ListView(physics: const ClampingScrollPhysics(), children: [
      ListTile(
          title: const Text("Model Type"),
          subtitle: Text(widget.model.modelType
              .toString()
              .split('.')
              .last
              .replaceFirstMapped(
                  RegExp(r'^(.)'), (match) => match.group(0)!.toUpperCase()))),
      SizedBox(height: Constants.getPaddingVertical(context)),
      Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Constants.getPaddingHorizontal(context)),
          child: Column(children: [
            DropdownMenu<String>(
                label: const Text('Select Label'),
                width: MediaQuery.of(context).size.width * .94,
                menuHeight: MediaQuery.of(context).size.height * .5,
                requestFocusOnTap: true,
                enableFilter: true,
                leadingIcon: const Icon(Icons.search),
                onSelected: (selectedValue) {
                  if (selectedValue != null) {
                    setState(() {
                      _label = selectedValue;
                    });
                  }
                },
                dropdownMenuEntries: widget.dataVariables.entries
                    .map<DropdownMenuEntry<String>>(
                        (entry) => DropdownMenuEntry<String>(
                              value: entry.key,
                              label: "${entry.key}: ${entry.value.toString()}",
                            ))
                    .toList())
          ]))
    ]);
  }

  _buildAppBar(AppProvider appProvider) {
    return AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed:  !appProvider.isLoading ? () {
              _back();
            } : null
            ),
        title: widget.mode == 'create'
            ? const Text('Create Model')
            : const Text('Train Model'),
        centerTitle: false,
        actions: [
          Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              child: TextButton(
                onPressed: _label.isNotEmpty
                    ? () {
                        _handleModel(appProvider);
                      }
                    : null,
                child: widget.mode == 'create'
                    ? const Text('Create')
                    : const Text('Train'),
              ))
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(
        appBar: _buildAppBar(appProvider),
        body: appProvider.isLoading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : _buildBody(appProvider),
      );
    });
  }
}
