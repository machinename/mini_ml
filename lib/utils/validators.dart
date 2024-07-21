class Validators {
  static String? descriptionValidator(String? value, String mode) {
    if (!RegExp(r'^[^\x00-\x1F]*$').hasMatch(value!)) {
      return '$mode description can only contain valid characters';
    }
    if (value.length > 100) {
      return '$mode description must be less than 101 characters';
    }
    return null;
  }

  static String? nameValidator(String? value, String mode) {
    if (value == null || value.isEmpty) {
      return 'Please enter a ${mode.toLowerCase()} name';
    }
    if (value.length < 4) {
      return '$mode name must be at least 4 characters long';
    }
    if (value.length >= 40) {
      return '$mode name must be less than or equal to 40 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value.trim())) {
      return 'Only letters, numbers, dashes and underscores allowed';
    }
    return null;
  }

  static String? urlValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    final RegExp urlRegExp = RegExp(
      r'^(?:http|https):\/\/[\w\-]+(?:\.[\w\-]+)+[\w\-.,@?^=%&:/~\+#]*[\w\-@?^=%&/~\+#]$',
    );
    if (!urlRegExp.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final RegExp emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    if (value.length > 100) {
      return 'Email must be less than 101 characters';
    }
    return null;
  }

  static String? passwordValidator(String? value, {String? confirmPassword}) {
    if (confirmPassword != null && value != confirmPassword) {
      return 'Passwords do not match.';
    }

    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number.';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  static String? phoneNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final RegExp phoneRegExp = RegExp(
      r'^\+?[1-9]\d{1,14}$',
    );
    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static projectDescriptionValidator(String? value) {}

  static projectNameValidator(String? value) {}
}
