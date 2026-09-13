import 'package:movie_app/core/constants/trailer_constants.dart';

/// Everything the trailer feature knows about URLs.
///
/// Kept out of the widgets deliberately: the screen renders a WebView, and
/// deciding what it may load is a rule, not a rendering concern. It is also
/// the only part of the feature that can be tested without a platform view.
class MovieTrailerService {
  /// [baseUrl] defaults to the app's one configured provider. It is a
  /// parameter only so tests can pin a known host — without it every
  /// navigation-guard test would depend on whatever is pasted into
  /// [movieTrailerBaseUrl], and would start failing the day that changes.
  const MovieTrailerService({this.baseUrl = movieTrailerBaseUrl});

  final String baseUrl;

  /// Whether there is a trailer to open at all.
  ///
  /// Lives here so the button and the screen agree on the answer instead of
  /// each deciding — the API returns the imdb field as an empty string about
  /// as often as it omits it.
  bool hasTrailer(String? imdbId) => imdbId != null && imdbId.trim().isNotEmpty;

  /// The address for [imdbId], trimmed — a stray space would otherwise be
  /// percent-encoded into the path and 404.
  String buildTrailerUrl(String imdbId) => '$baseUrl${imdbId.trim()}';

  /// Whether the WebView may follow a navigation.
  ///
  /// Returns a plain bool rather than a `NavigationDecision` so this stays
  /// testable without a platform view, and so the domain layer does not import
  /// the WebView plugin. The screen maps it.
  ///
  /// [loadedHost] is null until the first page has finished loading.
  ///
  /// Three rules, in order:
  ///
  /// 1. **Subframes always pass.** This is the page composing itself — the
  ///    player iframe, its CDN, the ad frames. Gating it is what left the
  ///    screen black: on iOS every subframe arrives here and `prevent` cancels
  ///    it outright. (Android never reports subframes at all, so this is a
  ///    no-op there.)
  /// 2. **Before the first load, anything passes.** The provider's own redirect
  ///    chain has to be allowed to settle wherever it goes. On Android this is
  ///    the only path a redirect can take — every main-frame navigation is
  ///    cancelled natively and re-issued only if this returns true.
  /// 3. **After that the main frame stays put.** A pop-up ad reaches both
  ///    platforms as a main-frame load, and this is what stops it replacing the
  ///    trailer with a browser.
  bool allowsNavigation({
    required bool isMainFrame,
    required String url,
    required String? loadedHost,
  }) {
    if (!isMainFrame) return true;
    if (loadedHost == null) return true;

    return isSameSite(url, loadedHost);
  }

  /// Whether [url] sits on [host] or one of its subdomains.
  ///
  /// ⚠️ Compared against the host actually **loaded**, not the configured one.
  /// Checking against [baseUrl] is what blanked the screen: the provider is
  /// free to redirect its embed elsewhere, and that redirect is the page
  /// working, not an escape from it.
  ///
  /// The suffix check is deliberately `.$host` and not `contains` — a naive
  /// check would accept `provider.test.evil.test`.
  bool isSameSite(String url, String host) {
    final target = Uri.tryParse(url)?.host;
    if (target == null || target.isEmpty || host.isEmpty) return false;

    return target == host || target.endsWith('.$host');
  }
}
