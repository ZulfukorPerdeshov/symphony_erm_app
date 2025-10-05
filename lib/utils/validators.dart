class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters long';
    }

    return null;
  }

  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'This field'} cannot exceed $maxLength characters';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    final cleanPhone = value.replaceAll(RegExp(r'[\s-()]'), '');

    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }

    return null;
  }

  static String? positiveNumber(String? value, {String? fieldName}) {
    final numberValidation = number(value, fieldName: fieldName);
    if (numberValidation != null) return numberValidation;

    final numberValue = double.parse(value!);
    if (numberValue <= 0) {
      return '${fieldName ?? 'This field'} must be greater than 0';
    }

    return null;
  }

  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (int.tryParse(value) == null) {
      return 'Please enter a valid whole number';
    }

    return null;
  }

  static String? positiveInteger(String? value, {String? fieldName}) {
    final integerValidation = integer(value, fieldName: fieldName);
    if (integerValidation != null) return integerValidation;

    final intValue = int.parse(value!);
    if (intValue <= 0) {
      return '${fieldName ?? 'This field'} must be greater than 0';
    }

    return null;
  }

  static String? sku(String? value) {
    if (value == null || value.isEmpty) {
      return 'SKU is required';
    }

    if (value.length < 3) {
      return 'SKU must be at least 3 characters long';
    }

    final skuRegex = RegExp(r'^[A-Z0-9\-_]+$');
    if (!skuRegex.hasMatch(value.toUpperCase())) {
      return 'SKU can only contain letters, numbers, hyphens, and underscores';
    }

    return null;
  }

  static String? orderNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Order number is required';
    }

    if (value.length < 5) {
      return 'Order number must be at least 5 characters long';
    }

    return null;
  }

  static String? currency(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Price'} is required';
    }

    final currencyValue = double.tryParse(value);
    if (currencyValue == null) {
      return 'Please enter a valid amount';
    }

    if (currencyValue < 0) {
      return '${fieldName ?? 'Price'} cannot be negative';
    }

    // Check for more than 2 decimal places
    final decimalPlaces = value.split('.').length > 1 ? value.split('.')[1].length : 0;
    if (decimalPlaces > 2) {
      return '${fieldName ?? 'Price'} cannot have more than 2 decimal places';
    }

    return null;
  }

  static String? percentage(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Percentage'} is required';
    }

    final percentageValue = double.tryParse(value);
    if (percentageValue == null) {
      return 'Please enter a valid percentage';
    }

    if (percentageValue < 0 || percentageValue > 100) {
      return '${fieldName ?? 'Percentage'} must be between 0 and 100';
    }

    return null;
  }

  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) return result;
    }
    return null;
  }

  static String? Function(String?) combineValidators(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}