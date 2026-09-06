import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/firestore_user_datasource.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl(this._dataSource);

  final FirestoreUserDataSource _dataSource;

  @override
  Future<UserProfile?> load(String uid) => _dataSource.load(uid);

  @override
  Future<void> save(UserProfile profile) => _dataSource.save(profile);
}
