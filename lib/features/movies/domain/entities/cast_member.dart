/// One actor on Movie Details. Figma node 55:91.
///
/// Mirrors an entry in the YTS `movie_details` `cast` array, which is only
/// returned when the request passes `with_cast=true`.
class CastMember {
  const CastMember({
    required this.name,
    this.characterName,
    this.imageUrl,
  });

  final String name;

  /// YTS `character_name`. Often missing, so the row has to read without it.
  final String? characterName;

  /// YTS `url_small_image`.
  final String? imageUrl;
}
