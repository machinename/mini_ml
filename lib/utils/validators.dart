class Validators {
  /// Validates a description field.
  ///
  /// [value] - The description string to validate.
  /// [mode] - A descriptive mode to customize the error messages.
  ///
  /// Returns an error message if validation fails, or null if the input is valid.
  static String? descriptionValidator(String? value, String mode) {
    // Check if the value contains invalid control characters.
    if (!RegExp(r'^[^\x00-\x1F]*$').hasMatch(value!)) {
      return '$mode description can only contain valid characters';
    }
    // Ensure the description length does not exceed 100 characters.
    if (value.length > 100) {
      return '$mode description must be less than 101 characters';
    }
    return null; // Return null if no validation errors.
  }

  /// Validates a name field.
  ///
  /// [value] - The name string to validate.
  /// [mode] - A descriptive mode to customize the error messages.
  ///
  /// Returns an error message if validation fails, or null if the input is valid.
  static String? nameValidator(String? value, String mode) {
    // Check if the value is empty or null.
    if (value == null || value.isEmpty) {
      return 'Please enter a ${mode.toLowerCase()} name';
    }
    // Ensure the name length is between 4 and 40 characters.
    if (value.length < 4) {
      return '$mode name must be at least 4 characters long';
    }
    if (value.length > 40) {
      return '$mode name must be less than or equal to 40 characters';
    }
    // Ensure the name contains only valid characters (letters, numbers, dashes, and underscores).
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value.trim())) {
      return 'Only letters, numbers, dashes, and underscores allowed';
    }
    return null; // Return null if no validation errors.
  }

  /// Validates a URL field.
  ///
  /// [value] - The URL string to validate.
  ///
  /// Returns an error message if validation fails, or null if the input is valid.
  static String? urlValidator(String? value) {
    // Check if the value is empty or null.
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    // Validate the URL format using a regular expression.
    final RegExp urlRegExp = RegExp(
      r'^(?:http|https):\/\/[\w\-]+(?:\.[\w\-]+)+[\w\-.,@?^=%&:/~\+#]*[\w\-@?^=%&/~\+#]$',
    );
    if (!urlRegExp.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null; // Return null if no validation errors.
  }

  /// Validates an email field.
  ///
  /// [value] - The email string to validate.
  ///
  /// Returns an error message if validation fails, or null if the input is valid.
  static String? emailValidator(String? value) {
    // Check if the value is empty or null.
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Validate the email format using a regular expression.
    final RegExp emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    // Ensure the email length does not exceed 100 characters.
    if (value.length > 100) {
      return 'Email must be less than 101 characters';
    }
    return null; // Return null if no validation errors.
  }

  /// Validates a password field.
  ///
  /// [value] - The password string to validate.
  /// [confirmPassword] - An optional field to check if the password matches a confirmation field.
  ///
  /// Returns an error message if validation fails, or null if the input is valid.
  static String? passwordValidator(String? value, {String? confirmPassword}) {
    // Check if the password matches the confirmed password.
    if (confirmPassword != null && value != confirmPassword) {
      return 'Passwords do not match.';
    }
    // Check if the password is empty or null.
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    // Ensure the password is at least 8 characters long.
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    // Validate the password contains at least one uppercase letter.
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter.';
    }
    // Validate the password contains at least one lowercase letter.
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter.';
    }
    // Validate the password contains at least one number.
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number.';
    }
    // Validate the password contains at least one special character.
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character.';
    }
    return null; // Return null if no validation errors.
  }

  /// Validates a phone number field.
  ///
  /// [value] - The phone number string to validate.
  ///
  /// Returns an error message if validation fails, or null if the input is valid.
  static String? phoneNumberValidator(String? value) {
    // Check if the value is empty or null.
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Validate the phone number format using a regular expression.
    final RegExp phoneRegExp = RegExp(
      r'^\+?[1-9]\d{1,14}$',
    );
    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null; // Return null if no validation errors.
  }

  // Placeholder for project description validation logic.
  // Currently does not perform any validation.
  static projectDescriptionValidator(String? value) {}

  // Placeholder for project name validation logic.
  // Currently does not perform any validation.
  static projectNameValidator(String? value) {}
}
