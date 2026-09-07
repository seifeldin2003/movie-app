import '../../domain/entities/cast_member.dart';
import 'json_read.dart';

/// One entry of the `cast` array on `movie_details.json`.
///
/// ⚠️ The array is only present when the request passes `with_cast=true`.
/// Without it the key is absent entirely — not empty — so the parse has to
/// treat "no cast" as normal rather than as a malformed response.
class CastMemberModel {
  const CastMemberModel({this.name, this.characterName, this.urlSmallImage});

  final String? name;
  final String? characterName;
  final String? urlSmallImage;

  factory CastMemberModel.fromJson(Map<String, dynamic> json) {
    return CastMemberModel(
      name: json['name'] as String?,
      characterName: json['character_name'] as String?,
      urlSmallImage: json['url_small_image'] as String?,
    );
  }

  static List<CastMemberModel> listFrom(Object? cast) =>
      JsonRead.objects(cast).map(CastMemberModel.fromJson).toList();

  CastMember toEntity() => CastMember(
    name: name ?? '',
    characterName: characterName,
    imageUrl: urlSmallImage,
  );
}
