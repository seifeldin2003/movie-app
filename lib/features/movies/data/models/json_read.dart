/// Type-safe reads for a payload that is not type-safe.
///
/// YTS is loosely typed: `rating` arrives as `8` on one record and `8.4` on
/// the next, `runtime` is occasionally a string. `json['rating'] as double?`
/// works right up until the row that disagrees, and then it throws in the
/// middle of parsing a list — so every number goes through here instead.
class JsonRead {
  const JsonRead._();

  static int? asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? asDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static List<String>? asStringList(Object? value) {
    if (value is! List) return null;
    return value.whereType<String>().toList();
  }

  /// The `Map<String, dynamic>` entries of a JSON array, skipping anything
  /// that is not an object.
  static List<Map<String, dynamic>> objects(Object? value) {
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList();
  }
}
