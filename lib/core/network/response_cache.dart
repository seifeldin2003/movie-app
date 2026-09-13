import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// The last response the API actually returned, kept on disk.
///
/// Not the same thing as `MovieLocalDataSource`, and it does not replace it.
/// That one reads three JSON files bundled into the build — a fixed snapshot
/// that never changes and knows nothing about what this user browsed. This is
/// a real cache: whatever the server last said, for the requests that were
/// actually made.
///
/// Stores the unwrapped `data` object, so what comes back out is shaped exactly
/// like a live response and is parsed by the same code.
class ResponseCache {
  const ResponseCache({this.rootDirectory});

  static const String _folder = 'api_cache';

  /// Where the cache folder is created. Injectable so a test can point it at a
  /// temp directory — otherwise the only way to exercise this is to fake
  /// path_provider's platform interface, which means a test importing a
  /// package the app does not depend on.
  final Future<Directory> Function()? rootDirectory;

  /// ⚠️ Every method swallows its own failures and returns null.
  ///
  /// A cache is an optimisation, and an optimisation that throws is worse than
  /// no optimisation at all — a full disk or a revoked permission would take
  /// down a screen that had a perfectly good network response in hand. Same
  /// reasoning as `MovieLocalDataSource._read`.
  Future<Map<String, dynamic>?> read(String key) async {
    try {
      final file = await _fileFor(key);
      if (!await file.exists()) return null;

      final decoded = jsonDecode(await file.readAsString());
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, Map<String, dynamic> data) async {
    try {
      final file = await _fileFor(key);
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(data));
    } catch (_) {
      // Nothing to do and nothing to report: the caller already has the live
      // response, which is the thing that matters.
    }
  }

  Future<File> _fileFor(String key) async {
    // Application support, not documents: this is app data the user did not
    // create and would not expect to see in a file browser, and on iOS
    // documents can be exposed and backed up.
    final root = await (rootDirectory ?? getApplicationSupportDirectory)();
    return File('${root.path}/$_folder/${_fileName(key)}.json');
  }

  /// Hashed rather than sanitised. A request key carries `/`, `?`, `&` and `=`,
  /// and an escaping scheme that stays readable also stays long — long enough
  /// to run past the 255-byte filename limit on a query-heavy request.
  ///
  /// FNV-1a, written out rather than pulled from `crypto`: that package is
  /// here transitively, and importing something you do not depend on is how a
  /// working build breaks on somebody else's `pub get`. Nothing here is
  /// security-sensitive — this only has to be deterministic across runs, which
  /// `String.hashCode` explicitly is not.
  String _fileName(String key) {
    var hash = 0xcbf29ce484222325;
    for (final byte in utf8.encode(key)) {
      hash ^= byte;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }
}
