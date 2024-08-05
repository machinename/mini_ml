import 'package:flutter/material.dart';
import 'package:mini_ml/utils/constants.dart';

class SupportAccount extends StatelessWidget {
  const SupportAccount({super.key});

  Widget _buildBody(BuildContext context) {
    return ListView(physics: const ClampingScrollPhysics(), children: [
      // const ListTile(
      //   leading: Icon(Icons.person_outline),
      //   title: Text(
      //       'Learn how to manage your personl info and security settings.'),
      // ),
      // Padding(
      //     padding: EdgeInsets.symmetric(
      //         horizontal: Constants.getPaddingHorizontal(context)),
      //     child: const Divider()),
      ListTile(
          title: const Text("Edit Email Display Name"),
          leading: const Icon(Icons.description_outlined),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
        leading: const Icon(Icons.description_outlined),
        title: const Text("Edit Email Address"),
        onTap: () => (),
        trailing: const Icon(Icons.chevron_right_sharp),
      ),
      // ListTile(
      //   leading: const Icon(Icons.description_outlined),
      //   title: const Text(
      //     "Edit Phone Number",
      //   ),
      //   onTap: () => (),
      //   trailing: const Icon(Icons.chevron_right_sharp),
      // ),
      // ListTile(
      //   leading: const Icon(Icons.description_outlined),
      //   title: const Text("Manage Notifications"),
      //   onTap: () => (),
      //   trailing: const Icon(Icons.chevron_right_sharp),
      // ),
      // ListTile(
      //     leading: const Icon(Icons.description_outlined),
      //     title: const Text("Enable Biometric Authentication"),
      //     onTap: () => (),
      //     trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text("Reset Password"),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
      ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text("Close Account"),
          onTap: () => (),
          trailing: const Icon(Icons.chevron_right_sharp)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Account - Support"),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_sharp),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: _buildBody(context));
  }
}
