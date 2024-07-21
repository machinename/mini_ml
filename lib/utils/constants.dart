import 'package:flutter/material.dart';

class Constants {
  static double getPaddingVertical(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.03;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      padding /= 2;
    }
    return padding;
  }

  static double getPaddingHorizontal(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.03;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return padding * 3;
    }
    return padding;
  }
}
