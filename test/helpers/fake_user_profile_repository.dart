import 'package:movie_app/features/profile/data/datasources/avatar_photo_picker.dart';
import 'package:movie_app/features/profile/domain/entities/user_profile.dart';
import 'package:movie_app/features/profile/domain/repositories/user_profile_repository.dart';

/// Stands in for Firestore so tests never touch the network.
class FakeUserProfileRepository implements UserProfileRepository {
  FakeUserProfileRepository({this.stored, this.error});

  /// What [load] returns. Null models a user with no document yet.
  final UserProfile? stored;
  final Object? error;

  /// The last profile handed to [save], so a test can assert what was written.
  UserProfile? saved;

  @override
  Future<UserProfile?> load(String uid) {
    if (error != null) return Future.error(error!);
    return Future.value(stored);
  }

  @override
  Future<void> save(UserProfile profile) {
    if (error != null) return Future.error(error!);
    saved = profile;
    return Future.value();
  }
}

/// Replaces the real gallery picker. Subclasses rather than implements an
/// interface because the production class wraps `image_picker` directly, and
/// only this one method ever needs standing in for.
class FakeAvatarPhotoPicker extends AvatarPhotoPicker {
  FakeAvatarPhotoPicker({this.encoded, this.error});

  /// What the picker returns. Null models the user dismissing the gallery.
  final String? encoded;
  final Object? error;

  @override
  Future<String?> pickAsBase64() {
    if (error != null) return Future.error(error!);
    return Future.value(encoded);
  }
}
