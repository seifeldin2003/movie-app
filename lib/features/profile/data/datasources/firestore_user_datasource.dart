import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/user_profile.dart';

/// The only file that talks to Firestore for user profiles.
///
/// House rule, same as the auth data source: translate the error here and
/// throw a sentence. Nothing above this layer sees a Firebase code.
class FirestoreUserDataSource {
  static const String _collection = 'users';

  static const String _avatarId = 'avatarId';
  static const String _photoBase64 = 'photoBase64';
  static const String _phoneNumber = 'phoneNumber';
  static const String _updatedAt = 'updatedAt';

  /// Firestore rejects a document over 1 MiB. Capping well under that leaves
  /// room for the fields around the photo — and, later, the watch list.
  static const int maxPhotoBytes = 700 * 1024;

  CollectionReference<Map<String, dynamic>> get _users =>
      FirebaseFirestore.instance.collection(_collection);

  Future<UserProfile?> load(String uid) async {
    try {
      final snapshot = await _users.doc(uid).get();
      final data = snapshot.data();

      // No document is the normal state straight after sign-up, not an error.
      if (!snapshot.exists || data == null) return null;

      return UserProfile(
        uid: uid,
        avatarId: data[_avatarId] as String?,
        photoBase64: data[_photoBase64] as String?,
        phoneNumber: data[_phoneNumber] as String?,
      );
    } on FirebaseException catch (e) {
      throw _readableMessage(e);
    }
  }

  Future<void> save(UserProfile profile) async {
    final photo = profile.photoBase64;
    if (photo != null && photo.length > maxPhotoBytes) {
      throw AppStrings.photoTooLarge;
    }

    try {
      await _users.doc(profile.uid).set({
        _avatarId: profile.avatarId,
        _photoBase64: profile.photoBase64,
        _phoneNumber: profile.phoneNumber,
        _updatedAt: Timestamp.now(),
        // Merge, so saving an avatar cannot wipe fields this screen does not
        // know about.
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _readableMessage(e);
    }
  }

  String _readableMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return AppStrings.firestorePermissionDenied;
      case 'unavailable':
      case 'network-request-failed':
        return AppStrings.networkError;
      case 'not-found':
        // Firestore itself has not been created for the project yet.
        return AppStrings.firestoreNotEnabled;
      default:
        return e.message ?? AppStrings.somethingWentWrong;
    }
  }
}
