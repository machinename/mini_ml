import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:provider/provider.dart';

class Verify extends StatelessWidget {
  const Verify({super.key});

  _exit(BuildContext context, AppProvider appProvider) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  _buildBody(BuildContext context, AppProvider appProvider) {
    return Padding(
        padding: EdgeInsets.symmetric(
            vertical: Constants.getPaddingVertical(context),
            horizontal: Constants.getPaddingHorizontal(context)),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Center(
              child:
                  Text("Please verify your email to complete registration.")),
          const Center(
              child: Text(
                  "Check your spam box if you don't see it in your inbox.")),
          SizedBox(height: Constants.getPaddingVertical(context)),
          ElevatedButton(
              onPressed: () {
                _exit(context, appProvider);
              },
              child: const Text('Exit'))
        ]));
  }

  _buildAppBar(BuildContext context, AppProvider appProvider) {
    return AppBar(
        leading: IconButton(
            icon: const Icon(Icons.clear_sharp),
            onPressed: () {
              _exit(context, appProvider);
            }),
        automaticallyImplyLeading: false,
        centerTitle: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(
          appBar: _buildAppBar(context, appProvider),
          body: _buildBody(context, appProvider));
    });
  }
}
