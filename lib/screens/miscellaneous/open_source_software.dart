import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenSourceSoftware extends StatelessWidget {
  const OpenSourceSoftware({super.key});

//   @override
//   State<OpenSourceSoftware> createState() => _AccountLicensesState();
// }

// class _AccountLicensesState extends State<OpenSourceSoftware> {

  static final Map<String, String> _licensesList = {
    'Cloud Firestore Plugin for Flutter': 'BSD 3-Clause License',
    'Cloud Storage for Flutter': 'BSD 3-Clause License',
    'Cupertino Icons': 'MIT License',
    'Encrypt': 'BSD 3-Clause License',
    'File Picker': 'MIT License',
    'Firebase Admin Python SDK': 'Apache License 2.0',
    'Firebase Auth for Flutter': 'BSD 3-Clause License',
    'Firebase Core for Flutter': 'BSD 3-Clause License',
    'Flask': 'BSD 3-Clause License',
    'HTTP': 'BSD 3-Clause License',
    'Pandas': 'BSD 3-Clause License',
    'Pycryptodome': 'Public Domain License',
    'Provider': 'MIT License',
    'Pointy Castle': 'MIT License',
    'Scikit Learn': 'BSD 3-Clause License',
    'Shared Preferences Plugin': 'BSD 3-Clause License',
    'Url Launcher': 'BSD 3-Clause License',
  };

  void _back(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _pushToLicense(String license) async {
    String url = '';

    switch (license) {
      case 'BSD 3-Clause License':
        url = 'opensource.org/license/BSD-3-Clause';
        break;
      case 'MIT License':
        url = 'opensource.org/licenses/MIT';
        break;
      case 'Apache License 2.0':
        url = 'www.apache.org/licenses/LICENSE-2.0';
        break;
      default:
        throw Exception('License not found');
    }


    try {
      final Uri uri = Uri(
        scheme: 'https',
        path: url,
      );

      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch ${uri.path}');
      }
    } catch (error) {
      return;
      // _showSnackBar('Error Occured');
      // throw Exception(
      //   error.toString(),
      // );
    }
  }

  // void _showSnackBar(string) {
  //   Dialogs.showSnackBar(context, string);
  // }

  _buildBody(AppProvider appProvider) {
    return ListView.builder(
        itemCount: _licensesList.length,
        itemBuilder: (context, index) {
          final data = _licensesList.entries.elementAt(index);
          return ListTile(
            title: Text(data.key),
            subtitle: Text(data.value),
            onTap: () => _pushToLicense(data.value),
          );
        });
  }

  _buildAppBar(BuildContext context, AppProvider appProvider) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_sharp),
        onPressed: () {
          _back(context);
        },
      ),
      title: const Text("Open Source Software"),
      centerTitle: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(
          appBar: _buildAppBar(context, appProvider), body: _buildBody(appProvider));
    });
  }
}
