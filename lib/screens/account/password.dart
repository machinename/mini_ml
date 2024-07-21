import 'package:flutter/material.dart';
import 'package:mini_ml/provider/app_provider.dart';
import 'package:mini_ml/utils/constants.dart';
import 'package:mini_ml/widgets/dialogs.dart';
import 'package:provider/provider.dart';

class Security extends StatefulWidget {
  const Security({
    super.key,
  });

  @override
  State<Security> createState() => _SecurityState();
}

class _SecurityState extends State<Security> {
  bool _showBack = false;

  void _back() {
    Navigator.pop(context);
  }

  void _sendPasswordResetEmail(AppProvider appProvider) async {
    try {
      bool? sendEmail = false;
      sendEmail = await Dialogs.showThreeButtonDialog(
          context,
          "Are you sure you want to send reset password email link?",
          "SEND EMAIL");
      if (sendEmail == true) {
        var user = appProvider.auth.currentUser;
        if (user == null) {
          _showSnackBar('Error Occured');
          return;
        }
        var email = user.email;

        if (email == null) {
          _showSnackBar('Error Occured');
          return;
        }
        await appProvider.resetPassword(email);

        setState(
          () {
            _showBack = true;
          },
        );
        _showSnackBar('Sending Password Reset Email!');
      }
    } catch (error) {
      _showSnackBar('Error Occured');
      // Log Here
      throw Exception(
        error.toString(),
      );
    }
  }

  void _showSnackBar(String string) {
    Dialogs.showSnackBar(context, string);
  }

  _buildBody(AppProvider appProvider) {
    return ListView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: Constants.getPaddingHorizontal(context),
      ),
      children: [
        const ListTile(
          title: Text("Enable biometric authentication"),
        ),
        ListTile(
          title: const Text("Send Password Reset Link"),
          onTap: () => _sendPasswordResetEmail(appProvider),
          trailing: const Icon(Icons.chevron_right),
        ),
        // ElevatedButton(
        //   onPressed: () {
        //     _sendPasswordResetEmail(appProvider);
        //   },
        //   child: const Text('Send E-Mail Link'),
        // ),
        if (_showBack)
          TextButton(
            onPressed: () {
              _back();
            },
            child: const Text('Back'),
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
            title: const Text("Security"),
            centerTitle: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_sharp),
              onPressed: () {
                _back();
              },
            ),
          ),
          body: _buildBody(appProvider),
        );
      },
    );
  }
}
