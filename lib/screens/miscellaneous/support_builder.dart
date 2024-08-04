import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:provider/provider.dart';

class SupportBuilder extends StatelessWidget {
  final String route;

  const SupportBuilder({super.key, required this.route});

  void _back(BuildContext context) {
    Navigator.pop(context);
  }

  _buildAppBar(BuildContext context) {
    String capitalize(String s) {
      if (s.isEmpty) return s;
      return s[0].toUpperCase() + s.substring(1);
    }

    return AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_sharp),
        onPressed: () {
          _back(context);
        },
      ),
      centerTitle: false,
      title: Text('${capitalize(route)} - Support'),
    );
  }

  Widget _buildBody(AppProvider appProvider) {
    return Stack(children: [
      if (appProvider.isLoading)
        const Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ListView(physics: const ClampingScrollPhysics(), children: const []),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appProvider, _) {
      return Scaffold(
          appBar: _buildAppBar(context), body: _buildBody(appProvider));
    });
  }
}
