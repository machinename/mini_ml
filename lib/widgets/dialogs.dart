import 'package:flutter/material.dart';

class Dialogs {
  /// Shows a message dialog with a title and a message.
  ///
  /// [context] - The BuildContext for finding the dialog's location in the widget tree.
  /// [title] - The title of the dialog.
  /// [message] - The message content of the dialog.
  ///
  /// Returns a Future that completes with true if the dialog is closed, or null if closed in any other way.
  static Future<bool?> showMessageDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context); // Close the dialog when 'CLOSE' is pressed.
              },
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }

  /// Shows a confirmation dialog with a message and 'YES' and 'CANCEL' options.
  ///
  /// [context] - The BuildContext for finding the dialog's location in the widget tree.
  /// [message] - The message content of the dialog.
  ///
  /// Returns a Future that completes with true if 'YES' is pressed, false if 'CANCEL' is pressed.
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
                Navigator.of(context)
                    .pop(true); // Return true when 'YES' is pressed.
              },
              child: const Text('YES'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Return false when 'CANCEL' is pressed.
              },
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog for entering a URL with a form validation.
  ///
  /// [context] - The BuildContext for finding the dialog's location in the widget tree.
  ///
  /// Returns a Future that completes with the entered URL if 'OK' is pressed and the form is valid, or null if 'CANCEL' is pressed or if the input is invalid.
  static Future<String?> showUrlDialog(BuildContext context) {
    final TextEditingController urlController =
        TextEditingController(); // Controller to manage text input.
    final formKey = GlobalKey<FormState>(); // Key to manage form state.

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Enter URL'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: urlController,
                  obscureText:
                      false, // Adjusted to false to show URL input in plain text.
                  decoration: const InputDecoration(hintText: 'Url'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Url cannot be empty'; // Validation message if the URL is empty.
                    }
                    return null;
                  },
                  onChanged: (_) {
                    setState(
                        () {}); // Rebuild the dialog to update 'OK' button state.
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: urlController.text.isNotEmpty
                      ? () {
                          if (formKey.currentState!.validate()) {
                            Navigator.of(context).pop(urlController
                                .text); // Return URL if form is valid.
                          }
                        }
                      : null,
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(null); // Return null if 'CANCEL' is pressed.
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

  /// Shows a dialog with three buttons: 'YES', 'CANCEL', and a third custom button.
  ///
  /// [context] - The BuildContext for finding the dialog's location in the widget tree.
  /// [message] - The message content of the dialog.
  /// [thirdButtonText] - The text for the third button.
  ///
  /// Returns a Future that completes with true if 'YES' or the third button is pressed, false if 'CANCEL' is pressed.
  static Future<bool?> showThreeButtonDialog(
      BuildContext context, String message, String thirdButtonText) {
    bool buttonEnabled =
        false; // Flag to control the state of the third button.

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
                    setState(() {
                      buttonEnabled =
                          true; // Enable the third button when 'YES' is pressed.
                    });
                  },
                  child: const Text('YES'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Return false if 'CANCEL' is pressed.
                  },
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: buttonEnabled
                      ? () {
                          Navigator.of(context).pop(
                              true); // Return true if the third button is pressed.
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

  /// Shows a SnackBar with a message.
  ///
  /// [context] - The BuildContext for finding the SnackBar's location in the widget tree.
  /// [message] - The message content of the SnackBar.
  /// [seconds] - The duration for which the SnackBar is displayed (default is 4 seconds).
  /// [color] - The color of the text in the SnackBar (optional).
  static void showSnackBar(BuildContext context, String message,
      {int seconds = 4, Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
            child: Text(message,
                style: color != null
                    ? TextStyle(fontSize: 18, color: color)
                    : const TextStyle(fontSize: 18))),
        duration: Duration(seconds: seconds),
      ),
    );
  }
}
