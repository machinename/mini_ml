class MetricsDefinitions {
  final String _mae =
      "Mean Absolute Error (MAE) is the average of the absolute differences between predicted and actual values.";
  final String _rmse =
      "Root Mean Square Error (RMSE) is the square root of the average of the squared differences between predicted and actual values.";
  final String _r2 =
      "R-squared (R2) measures the proportion of variance in the dependent variable that is predictable from the independent variables.";
  final String _mse =
      "Mean Squared Error (MSE) is the average of the squared differences between predicted and actual values.";

  String fetchMetricDefinition(String metric) {
    switch (metric.toLowerCase()) {
      case "mae":
        return _mae;

      case "rmse":
        return _rmse;

      case "r2":
        return _r2;

      case "mse":
        return _mse;

      default:
        return "Definition not found for the given metric.";
    }
  }
}
