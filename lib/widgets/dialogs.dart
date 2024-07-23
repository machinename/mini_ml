import 'package:flutter/material.dart';

class Dialogs {
  static Future<bool?> showMessageDialog(
      BuildContext context, String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> showConfirmDialog(BuildContext context, String message) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('YES'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }


  static Future<String?> showUrlDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Enter Password'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: urlController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Url'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Url cannot be empty';
                    }
                    return null;
                  },
                  onChanged: (_) {
                    setState(
                      () {},
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: urlController.text.isNotEmpty
                      ? () {
                          if (formKey.currentState!.validate()) {
                            Navigator.of(context).pop(urlController.text);
                          }
                        }
                      : null,
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: const Text('CANCEL'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<bool?> showThreeButtonDialog(
      BuildContext context, String message, String thirdButtonText) {
    bool buttonEnabled = false;

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Confirmation'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(
                      () {
                        buttonEnabled = true;
                      },
                    );
                  },
                  child: const Text('YES'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: buttonEnabled
                      ? () {
                          Navigator.of(context).pop(true);
                        }
                      : null,
                  child: Text(thirdButtonText),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static void showSnackBar(BuildContext context, String message,
      {int seconds = 4}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(message)),
        duration: Duration(seconds: seconds),
      ),
    );
  }
}
