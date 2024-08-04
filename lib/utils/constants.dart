import 'package:flutter/material.dart';

class Constants {
  /// Calculates the vertical padding based on the screen width and orientation.
  ///
  /// [context] - The BuildContext to access the MediaQuery data.
  ///
  /// Returns the calculated padding value. The padding is scaled according to the screen width.
  /// In landscape orientation, the padding is reduced by half.
  static double getPaddingVertical(BuildContext context) {
    double screenWidth =
        MediaQuery.of(context).size.width; // Get the screen width.
    double padding =
        screenWidth * 0.03; // Calculate padding as 3% of the screen width.

    // Check if the device is in landscape orientation.
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      padding /= 2; // Halve the padding for landscape orientation.
    }

    return padding; // Return the calculated padding.
  }

  /// Calculates the horizontal padding based on the screen width and orientation.
  ///
  /// [context] - The BuildContext to access the MediaQuery data.
  ///
  /// Returns the calculated padding value. The padding is scaled according to the screen width.
  /// In landscape orientation, the padding is doubled.
  static double getPaddingHorizontal(BuildContext context) {
    double screenWidth =
        MediaQuery.of(context).size.width; // Get the screen width.
    double padding =
        screenWidth * 0.03; // Calculate padding as 3% of the screen width.

    // Check if the device is in landscape orientation.
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return padding * 2; // Double the padding for landscape orientation.
    }

    return padding; // Return the calculated padding.
  }
}
