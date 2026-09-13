import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/constants/trailer_constants.dart';
import 'package:movie_app/features/movie_details/trailer/domain/movie_trailer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The app's real, configured provider — whatever is pasted into the
  // constant. Assertions below are written against the constant rather than a
  // literal so that changing providers does not turn these red.
  const service = MovieTrailerService();

  // A stand-in with a known host, for the rules that need one. Without this,
  // every navigation-guard case would depend on the configured provider and
  // would have to be rewritten the day it changes.
  const fakeProvider = MovieTrailerService(
    baseUrl: 'https://provider.test/embed/movie/',
  );

  group('hasTrailer', () {
    test('accepts a real imdb code', () {
      expect(service.hasTrailer('tt1300854'), isTrue);
    });

    test('rejects null, empty and whitespace alike', () {
      // The API returns `imdb_code` as an empty string about as often as it
      // omits it, so a plain null check would let blanks through and open a
      // WebView on a URL with nothing after the slash.
      expect(service.hasTrailer(null), isFalse);
      expect(service.hasTrailer(''), isFalse);
      expect(service.hasTrailer('   '), isFalse);
    });
  });

  group('buildTrailerUrl', () {
    test('builds from the id it is given, never a fixed one', () {
      expect(
        service.buildTrailerUrl('tt1300854'),
        '${movieTrailerBaseUrl}tt1300854',
      );
      expect(
        service.buildTrailerUrl('tt1234567'),
        '${movieTrailerBaseUrl}tt1234567',
      );
    });

    test('appends nothing of its own', () {
      // The provider's embed page is loaded exactly as served. The YouTube
      // player parameters this used to carry meant nothing off YouTube, and
      // inline playback is a WebView setting now, not a query string.
      expect(
        fakeProvider.buildTrailerUrl('tt1300854'),
        'https://provider.test/embed/movie/tt1300854',
      );
    });

    test('trims, so a stray space cannot 404 the request', () {
      // A space would otherwise be percent-encoded into the path.
      expect(
        fakeProvider.buildTrailerUrl('  tt1300854 '),
        'https://provider.test/embed/movie/tt1300854',
      );
    });
  });

  group('isSameSite', () {
    test('accepts the host itself and its subdomains', () {
      expect(
        service.isSameSite('https://provider.test/x', 'provider.test'),
        isTrue,
      );
      expect(
        service.isSameSite('https://cdn.provider.test/player', 'provider.test'),
        isTrue,
      );
    });

    test('refuses anywhere else', () {
      expect(
        service.isSameSite('https://example.com/', 'provider.test'),
        isFalse,
      );
      expect(
        service.isSameSite('https://notprovider.test/', 'provider.test'),
        isFalse,
      );
      // Would slip past a naive `contains('provider.test')` check.
      expect(
        service.isSameSite('https://provider.test.evil.test/', 'provider.test'),
        isFalse,
      );
    });

    test('refuses unparseable urls and an empty host', () {
      expect(service.isSameSite('', 'provider.test'), isFalse);
      expect(service.isSameSite('not a url', 'provider.test'), isFalse);
      // Fails closed rather than matching everything.
      expect(service.isSameSite('https://anywhere.test/', ''), isFalse);
    });
  });

  group('allowsNavigation', () {
    // These four are the bug. The old rule checked every navigation against the
    // configured host, which blanked the screen on both platforms.

    test('lets subframes through, always', () {
      // ⚠️ The iOS failure. Every subframe arrives at this callback there, and
      // refusing one cancels the player iframe outright — so the page loaded,
      // reported success, and painted nothing.
      expect(
        service.allowsNavigation(
          isMainFrame: false,
          url: 'https://some-cdn.example/player.html',
          loadedHost: 'provider.test',
        ),
        isTrue,
      );
    });

    test('lets the provider redirect anywhere before the first load', () {
      // ⚠️ The Android failure. Android cancels every main-frame navigation and
      // re-issues it only if this returns true, so a 302 to another host died
      // here and left a blank page.
      expect(
        service.allowsNavigation(
          isMainFrame: true,
          url: 'https://somewhere-else.test/player',
          loadedHost: null,
        ),
        isTrue,
      );
    });

    test('keeps the main frame on the loaded site once it has settled', () {
      expect(
        service.allowsNavigation(
          isMainFrame: true,
          url: 'https://provider.test/another',
          loadedHost: 'provider.test',
        ),
        isTrue,
      );
    });

    test('refuses a main-frame hijack after load', () {
      // A pop-up ad reaches both platforms as a main-frame load. This is the
      // one thing that still gets refused, and the only reason the guard exists.
      expect(
        service.allowsNavigation(
          isMainFrame: true,
          url: 'https://ads.example/win-a-prize',
          loadedHost: 'provider.test',
        ),
        isFalse,
      );
    });
  });
}
