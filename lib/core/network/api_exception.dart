import 'package:dio/dio.dart';

/// A network failure carrying a sentence that can go straight on screen.
///
/// Same split as the auth layer: the data source translates, so a Bloc never
/// sees a `DioExceptionType` and a widget never sees a status code.
class ApiException implements Exception {
  const ApiException(this.message, {this.isConnectionIssue = false});

  final String message;

  /// True when the request never reached the server — no signal, DNS failure,
  /// timeout, blocked mirror. The repository uses this to decide whether
  /// falling back to bundled data makes sense: a 404 means the movie is not
  /// there, and showing a stale catalogue instead would be a lie.
  final bool isConnectionIssue;

  @override
  String toString() => message;

  /// Builds the user-facing message from a Dio failure.
  factory ApiException.from(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      // Added in Dio 5.11 — decoding a large body ran past the budget.
      case DioExceptionType.transformTimeout:
        return const ApiException(
          'The connection timed out. Check your internet and try again.',
          isConnectionIssue: true,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const ApiException(
          'No internet connection.',
          isConnectionIssue: true,
        );
      case DioExceptionType.cancel:
        return const ApiException('Request cancelled.');
      case DioExceptionType.badCertificate:
        return const ApiException('Could not verify a secure connection.');
      case DioExceptionType.badResponse:
        return ApiException(readableBody(error.response?.data));
    }
  }

  /// Reads the server's own message without trusting its shape.
  ///
  /// ⚠️ `data['status_message']` on a raw body is the crash that hides the
  /// real one: when a proxy or a dead mirror answers with an HTML string
  /// instead of JSON, indexing it throws a `TypeError` *inside the catch
  /// block*, so the log shows a type error rather than the actual failure.
  /// Check the type first, always.
  ///
  /// YTS names the field `status_message`, not `message`.
  static String readableBody(Object? data) {
    if (data is Map && data['status_message'] != null) {
      return '${data['status_message']}';
    }
    return 'Something went wrong. Please try again.';
  }
}
