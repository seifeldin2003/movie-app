import 'dart:convert';

import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_strings.dart';
import 'firestore_user_datasource.dart';

/// Picks a photo from the device and returns it base64-encoded, ready to sit
/// in the user's Firestore document.
///
/// The downscaling is done by `image_picker` itself rather than a separate
/// image package: a full-size camera photo would be several megabytes, far
/// past what a Firestore document can hold, and an avatar is never displayed
/// larger than a couple of hundred points.
class AvatarPhotoPicker {
  static const double _maxDimension = 300;

  /// Enough for a face at avatar size; the difference from 100 is invisible
  /// here and cuts the encoded string several times over.
  static const int _quality = 70;

  final ImagePicker _picker = ImagePicker();

  /// Returns `null` when the user backs out of the gallery — a cancel is not
  /// an error, same rule as the Google sign-in picker.
  Future<String?> pickAsBase64() async {
    final XFile? file;
    try {
      file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxDimension,
        maxHeight: _maxDimension,
        imageQuality: _quality,
      );
    } catch (_) {
      throw AppStrings.photoPickFailed;
    }

    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final encoded = base64Encode(bytes);

    // Checked here as well as on save so the user is told immediately, rather
    // than after filling in the rest of the form.
    if (encoded.length > FirestoreUserDataSource.maxPhotoBytes) {
      throw AppStrings.photoTooLarge;
    }

    return encoded;
  }
}
