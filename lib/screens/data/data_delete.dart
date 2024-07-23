import 'package:flutter/material.dart';
import 'package:mini_ml/models/data.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class DataDelete extends StatefulWidget {
  const DataDelete({super.key});

  @override
  State<DataDelete> createState() => _DataDeleteState();
}

class _DataDeleteState extends State<DataDelete> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _deleteController = TextEditingController();

  void _back() {
    Navigator.pop(context);
  }

  void _exit() {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  void _deleteData(AppProvider appProvider) async {
    try {
      Data? data = appProvider.projectProvider.currentData;

      if (data == null) {
        _showSnackBar("Data not found");
        return;
      }

      var projectId = appProvider.projectProvider.id;
      appProvider.setIsLoading(true);
      await appProvider.deleteResource(projectId, data);
      await appProvider.fetchResources(projectId);
      appProvider.setIsLoading(false);
      _exit();
      _showSnackBar("Data Successfully Deleted");
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

  _buildBody(AppProvider appProvider) {
    return Stack(
      children: [
        if (appProvider.isLoading)
          const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Constants.getPaddingHorizontal(context),
                vertical: Constants.getPaddingVertical(context)),
            child: ListView(
              physics: const ClampingScrollPhysics(),
              children: [
                Text(
                    'This action is irreversible. To confirm type, "${appProvider.projectProvider.currentData?.name}" in the box below.',
                    textAlign: TextAlign.start),
                SizedBox(height: Constants.getPaddingHorizontal(context)),
                Form(
                    key: _formKey,
                    child: TextFormField(
                        enabled: !appProvider.isLoading,
                        controller: _deleteController,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) {
                          setState(() {});
                        })),
              ],
            )),
      ],
    );
  }

  _buildAppBar(AppProvider appProvider) {
    return AppBar(
        title: const Text('Delete Data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp),
          onPressed: () {
            _back();
          },
        ),
        centerTitle: false,
        actions: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                onPressed: _deleteController.text ==
                            appProvider.projectProvider.currentData?.name &&
                        !appProvider.isLoading
                    ? () {
                        _deleteData(appProvider);
                      }
                    : null,
                child: const Text('Delete'),
              ))
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        return Scaffold(
          appBar: _buildAppBar(appProvider),
          body: _buildBody(appProvider),
        );
      },
    );
  }
}
