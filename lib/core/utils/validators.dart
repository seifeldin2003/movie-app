import '../constants/app_strings.dart';

/// Form validators shared by the auth screens.
///
/// Each returns `null` when the value is acceptable and a message from
/// [AppStrings] when it is not — the shape `TextFormField.validator` expects.
class Validators {
  const Validators._();

  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static const int minPasswordLength = 6;

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    return null;
  }

  static String? email(String? value) {
    final emptyError = required(value);
    if (emptyError != null) return emptyError;

    if (!_emailPattern.hasMatch(value!.trim())) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  static String? password(String? value) {
    final emptyError = required(value);
    if (emptyError != null) return emptyError;

    if (value!.length < minPasswordLength) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  /// Confirm-password matching is form validation, not Bloc logic — the user
  /// should see it before anything is submitted.
  static String? confirmPassword(String? value, String original) {
    final emptyError = required(value);
    if (emptyError != null) return emptyError;

    if (value != original) {
      return AppStrings.passwordsDoNotMatch;
    }
    return null;
  }
}
