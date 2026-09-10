class Validators {
  Validators._();

  static String? required(String? value, [String message = 'This field is required']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter age';
    }
    final intValue = int.tryParse(value.trim());
    if (intValue == null || intValue <= 0 || intValue > 125) {
      return 'Please enter a valid age (1-125)';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (cleaned.length < 10) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
