import 'package:flutter/material.dart';
import 'package:mini_ml/models/data.dart';
import 'package:mini_ml/models/resource.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/screens/data/data_description.dart';
import 'package:mini_ml/screens/data/data_name.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class ManageData extends StatefulWidget {
  const ManageData({super.key});

  @override
  State<ManageData> createState() => _ManageDataState();
}

class _ManageDataState extends State<ManageData> {
  bool _showDeleteDialog = false;

  void _back() {
    Navigator.pop(context);
  }

  void _exit() {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }
  void _pushToDataName() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const DataName()));
  }

  void _pushToDataDescription() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const DataDescription()));
  }




  void _handleDeleteData(AppProvider appProvider) async {
    try {
      bool? isDeleteData = await Dialogs.showConfirmDialog(context,
          "Are you sure you want to delete your data set? This action is irreversible!");

      if (isDeleteData != true) {
        return;
      }

      Data? data = appProvider.projectProvider.currentData;

      if (data == null) {
        _showSnackBar("Data not found");
        return;
      }

      var projectId = appProvider.projectProvider.id;
      await appProvider.deleteResource(projectId, data);
      await appProvider.fetchResources(projectId);
      _back();
      _showSnackBar("Data Set Deleted Successfully");
      appProvider.projectProvider.currentData = null;
    } catch (error) {
      _showSnackBar('Error Occured');
      throw Exception(
        error.toString(),
      );
    }
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
  }

  _dataTypeIcon(AppProvider appProvider) {
    switch (appProvider.projectProvider.currentData?.dataType) {
      case DataType.tabular:
        return const Icon(Icons.table_chart_sharp);
      // case DataType.image:
      //   return const Icon(Icons.image_sharp);
      // case DataType.text:
      //   return const Icon(Icons.text_fields_sharp);
      // case DataType.audio:
      //   return const Icon(Icons.audiotrack_sharp);
      // case DataType.video:
      //   return const Icon(Icons.video_collection_sharp);
      default:
        return null;
    }
  }

  _buildBody(AppProvider appProvider) {
    Data? data = appProvider.projectProvider.currentData;
    if (data == null) {
      return const Center(child: Text("Data not found"));
    } else {
      return ListView(physics: const ClampingScrollPhysics(), children: [
        ListTile(
            title: const Text("Name"),
            subtitle: Text(data.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pushToDataName()),
        ListTile(
            title: const Text("Description"),
            subtitle: data.description.isNotEmpty
                ? Text(data.description)
                : const Text('N/A'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pushToDataDescription()),
        ListTile(
            title: const Text("Data Type"),
            subtitle: Text(data.dataType
                .toString()
                .split('.')
                .last
                .replaceFirstMapped(RegExp(r'^[a-z]'),
                    (match) => match.group(0)!.toUpperCase()))),
        ListTile(
            title: const Text("Variables"),
            subtitle: Text("${data.variables.length} variables"))
      ]);
    }
  }

  _buildAppBar(AppProvider appProvider) {
    return AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_sharp),
            onPressed: () {
              _back();
            }),
        title: const Text("Manage Data"),
        centerTitle: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.delete_sharp),
              onPressed: () {
                _handleDeleteData(appProvider);
              })
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(
          appBar: _buildAppBar(appProvider), body: _buildBody(appProvider));
    });
  }
}
