import 'package:flutter/material.dart';
import 'package:mini_ml/utils/constants.dart';

class Verify extends StatelessWidget {
  const Verify({super.key});

  _exit(BuildContext context) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  _buildBody(BuildContext context) {
    return Column(
    
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
         padding: EdgeInsets.symmetric(
            horizontal: Constants.getPaddingHorizontal(context)
            ),
            child: 
        const Center(child:  Text('Verify your email address to enjoy all of mini ML features!'))),
        TextButton(
              onPressed: () {
                _exit(context);
              },
              child: const Text('Close'),
            ),
      ]
    );
  }

  _buildAppBar(BuildContext context) {
    return AppBar(
        leading: IconButton(
            icon: const Icon(Icons.clear_sharp),
            onPressed: () {
              _exit(context);
            }),
            title: const Text('Verify Email'),
        automaticallyImplyLeading: false,
        centerTitle: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(context), body: _buildBody(context));
  }
}
