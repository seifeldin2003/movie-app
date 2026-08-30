/// Every user-visible string in the app. No raw text literals in widgets.
///
/// Add your screen's strings under its own section — that keeps two people
/// editing this file from touching the same lines.
class AppStrings {
  const AppStrings._();

  // Splash / Onboarding
  static const String supervisedBy = 'Supervised by Mohamed Nabil';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String explore = 'Explore Now';

  // Login
  static const String login = 'Login';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgetPassword = 'Forget Password ?';
  static const String createAccountPrompt = 'Don\'t Have Account ? Create One';
  static const String or = 'OR';
  static const String loginWithGoogle = 'Login With Google';

  // Register
  static const String register = 'Register';
  static const String name = 'Name';
  static const String confirmPassword = 'Confirm Password';
  static const String phoneNumber = 'Phone Number';
  static const String avatar = 'Avatar';
  static const String haveAccountPrompt = 'Already Have Account ? Login';

  // Forgot password
  static const String verifyEmail = 'Verify Email';
  static const String resetPasswordSent =
      'A reset link has been sent to your email.';

  // Validation + generic errors
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Enter a valid email address';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';
}
