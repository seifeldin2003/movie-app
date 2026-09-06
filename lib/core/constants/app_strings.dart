/// Every user-visible string in the app. No raw text literals in widgets.
///
/// Add your screen's strings under its own section — that keeps two people
/// editing this file from touching the same lines.
class AppStrings {
  const AppStrings._();

  // Splash
  static const String supervisedBy = 'Supervised by Mohamed Nabil';

  // Onboarding — copy transcribed from the Figma frames verbatim.
  static const String exploreNow = 'Explore Now';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String finish = 'Finish';

  static const String onboardingIntroTitle =
      'Find Your Next Favorite Movie Here';
  static const String onboardingIntroBody =
      'Get access to a huge library of movies to suit all tastes. '
      'You will surely like it.';

  static const String onboardingDiscoverTitle = 'Discover Movies';
  static const String onboardingDiscoverBody =
      'Explore a vast collection of movies in all qualities and genres. '
      'Find your next favorite film with ease.';

  static const String onboardingGenresTitle = 'Explore All Genres';
  static const String onboardingGenresBody =
      'Discover movies from every genre, in all available qualities. '
      'Find something new and exciting to watch every day.';

  static const String onboardingWatchlistTitle = 'Create Watchlists';
  static const String onboardingWatchlistBody =
      'Save movies to your watchlist to keep track of what you want to watch '
      'next. Enjoy films in various qualities and genres.';

  static const String onboardingReviewTitle = 'Rate, Review, and Learn';
  static const String onboardingReviewBody =
      "Share your thoughts on the movies you've watched. Dive deep into film "
      'details and help others discover great movies with your reviews.';

  static const String onboardingStartTitle = 'Start Watching Now';

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

  // Update profile
  static const String pickAvatar = 'Pick Avatar';
  static const String resetPassword = 'Reset Password';
  static const String deleteAccount = 'Delete Account';
  static const String updateData = 'Update Data';

  // Bottom navigation
  static const String home = 'Home';
  static const String search = 'Search';
  static const String browse = 'Browse';
  static const String profile = 'Profile';

  /// Shown by the tab bodies until their feature is built.
  static const String comingSoon = 'Coming soon';

  // Home
  static const String seeMore = 'See More';

  // Search
  static const String searchHint = 'Search';
  static const String searchEmpty = 'Search for a movie to get started.';
  static const String searchNoResults = 'No movies match that search.';

  // Avatar picker
  static const String changePhoto = 'Change photo';
  static const String chooseAvatar = 'Choose an avatar';
  static const String chooseAvatarSubtitle = 'Pick one of our characters';
  static const String browseImage = 'Browse an image';
  static const String browseImageSubtitle = 'Use a photo from your gallery';
  static const String removePhoto = 'Remove photo';
  static const String removePhotoSubtitle = 'Go back to a character';
  static const String photoTooLarge =
      'That image is too large. Please pick a smaller one.';
  static const String photoPickFailed =
      'Could not open that image. Please try another.';

  // Firestore
  static const String firestorePermissionDenied =
      'You do not have permission to do that.';
  static const String firestoreNotEnabled =
      'The database is not set up for this project yet.';

  // Profile
  static const String wishList = 'Wish List';
  static const String history = 'History';
  static const String watchList = 'Watch List';
  static const String editProfile = 'Edit Profile';
  static const String exit = 'Exit';
  static const String watchListEmpty = 'Your watch list is empty.';
  static const String historyEmpty = 'You have not watched anything yet.';

  // Auth feedback
  static String welcome(String name) => 'Welcome, $name';

  // Firebase auth errors — translated in the data source so no error code
  // ever reaches a Bloc or a screen.
  static const String weakPassword = 'The password provided is too weak.';
  static const String emailAlreadyInUse =
      'An account already exists for that email.';
  static const String invalidEmailAddress = 'That email address is not valid.';
  static const String emailPasswordNotEnabled =
      'Email sign-in is not enabled for this project.';
  static const String networkError =
      'No internet connection. Check your network and try again.';
  static const String wrongEmailOrPassword =
      'Incorrect email or password. Please try again.';
  static const String accountDisabled = 'This account has been disabled.';
  static const String tooManyAttempts =
      'Too many attempts. Please wait a moment and try again.';
  static const String accountExistsWithDifferentCredential =
      'An account already exists with a different sign-in method.';
  static const String googleSignInFailed =
      'Google sign-in failed. Please try again.';
  static const String googleSignInNotConfigured =
      'Google sign-in is not set up for this project yet.';
  static const String requiresRecentLogin =
      'For your security, please sign in again before doing this.';

  // Profile
  static const String profileUpdated = 'Your profile has been updated.';
  static const String deleteAccountTitle = 'Delete account?';
  static const String deleteAccountBody =
      'This permanently removes your account and cannot be undone.';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';

  // Validation + generic errors
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Enter a valid email address';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String somethingWentWrong =
      'Something went wrong. Please try again.';
}
