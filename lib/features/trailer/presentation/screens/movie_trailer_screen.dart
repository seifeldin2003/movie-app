import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/movie_trailer_args.dart';
import '../../domain/movie_trailer_service.dart';

/// Plays a movie's trailer without leaving the app.
///
/// Its own screen rather than a WebView dropped into Movie Details: the
/// controller owns a native view with a lifecycle, and Details is already a
/// scrolling page with two Blocs on it.
///
/// The page is loaded and displayed as the provider serves it. Nothing here
/// inspects it, rewrites it, or reaches for the underlying media.
class MovieTrailerScreen extends StatefulWidget {
  const MovieTrailerScreen({super.key, required this.args});

  final MovieTrailerArgs args;

  @override
  State<MovieTrailerScreen> createState() => _MovieTrailerScreenState();
}

class _MovieTrailerScreenState extends State<MovieTrailerScreen> {
  static const MovieTrailerService _service = MovieTrailerService();

  late final WebViewController _controller;

  bool _isLoading = true;
  bool _hasFailed = false;

  /// The host of the page that actually loaded, which is not necessarily the
  /// configured one — the provider is free to redirect its embed. Null until
  /// the first load finishes, and that null is meaningful: it is what lets the
  /// redirect chain settle before anything is refused.
  String? _loadedHost;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
  }

  /// ⚠️ iOS defaults `allowsInlineMediaPlayback` to false, which hands video to
  /// the fullscreen system player and takes the user out of the app. Turning it
  /// on is what keeps the trailer on this screen — the platform-level
  /// equivalent of the `playsinline=1` this used to append to a YouTube URL,
  /// and unlike that it works whatever the provider is.
  ///
  /// The empty `mediaTypesRequiringUserAction` set (and Android's matching
  /// `setMediaPlaybackRequiresUserGesture(false)`) lifts the platform gesture
  /// requirement, so the embed can start on its own. The user tapped a play
  /// button to get here — asking them to tap a second one inside the page is
  /// the kind of thing that reads as broken.
  WebViewController _buildController() {
    final params = WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
          )
        : const PlatformWebViewControllerCreationParams();

    final controller = WebViewController.fromPlatformCreationParams(params);

    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    // ⚠️ DO NOT add `setOnConsoleMessage` here. On iOS it is not a native hook —
    // it injects a user script that overrides console.log/debug/error/info/
    // warning and stringifies every argument. The provider's page runs an
    // anti-debugging script whose detectors work by passing objects with
    // poisoned `toString` into the console and seeing whether they get
    // stringified, so the hook trips it on every poll and the page reacts as if
    // a debugger were attached. The diagnostic changed what it was measuring.
    //
    // Everything logged below is passive: it observes navigation and responses
    // without touching the page.

    // Production-correct regardless, and it keeps the WebView from advertising
    // an attached inspector: you do not ship an inspectable web view.
    if (controller.platform is WebKitWebViewController) {
      (controller.platform as WebKitWebViewController).setInspectable(false);
    }

    return controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Otherwise the WebView paints white before the embed does, which
      // flashes against a black screen.
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (kDebugMode) debugPrint('[trailer] started ${_origin(url)}');
          },
          onPageFinished: (url) {
            _loadedHost ??= Uri.tryParse(url)?.host;
            if (kDebugMode) debugPrint('[trailer] finished ${_origin(url)}');
            _settle(loading: false);
          },
          onUrlChange: (change) {
            final url = change.url;
            if (kDebugMode && url != null) {
              debugPrint('[trailer] url -> ${_origin(url)}');
            }
          },
          onWebResourceError: _handleResourceError,
          onNavigationRequest: (request) {
            final allowed = _service.allowsNavigation(
              isMainFrame: request.isMainFrame,
              url: request.url,
              loadedHost: _loadedHost,
            );
            if (!allowed && kDebugMode) {
              debugPrint('[trailer] refused main-frame navigation off site');
            }
            return allowed
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
          // ⚠️ Log only, never fatal. On iOS this fires for *any* resource that
          // comes back >= 400, which on an ad-supported page is routine. Only
          // statusCode is reliably populated — both platforms leave the
          // response URI null, and iOS leaves the request null too.
          onHttpError: (error) {
            if (kDebugMode) {
              debugPrint(
                '[trailer] http ${error.response?.statusCode} on a subresource',
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_service.buildTrailerUrl(widget.args.imdbId)));
  }

  /// Scheme + host only. The full address carries the provider's endpoint and
  /// there is no reason to spray it through the console.
  static String _origin(String url) {
    final uri = Uri.tryParse(url);
    return uri == null ? '(unparseable)' : '${uri.scheme}://${uri.host}';
  }

  /// Only a main-frame failure *before anything has loaded* is a real failure.
  ///
  /// ⚠️ Refusing a navigation surfaces here as an error too, so without the
  /// `_loadedHost` guard, blocking one pop-up ad would tear down a trailer that
  /// is playing perfectly well and replace it with the error screen.
  void _handleResourceError(WebResourceError error) {
    // Analytics pixels and thumbnails fail all the time on these pages.
    if (!(error.isForMainFrame ?? true)) return;
    // The page is up; this is a blocked ad, not a broken trailer.
    if (_loadedHost != null) return;
    // NSURLErrorCancelled — our own prevent, or a superseded redirect.
    if (error.errorCode == -999) return;

    _settle(loading: false, failed: true);
  }

  void _settle({required bool loading, bool failed = false}) {
    if (!mounted) return;
    setState(() {
      _isLoading = loading;
      _hasFailed = failed;
    });
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _hasFailed = false;
      // Back to "nothing has loaded yet", so the retry gets the same freedom to
      // follow the provider's redirects that the first attempt had.
      _loadedHost = null;
    });
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        // The default AppBar leading gives the system back button and the iOS
        // swipe gesture for free — no custom handling needed.
        title: Text(widget.args.title, style: AppTextStyles.titleMedium),
      ),
      body: _hasFailed
          ? ErrorView(message: AppStrings.trailerFailed, onRetry: _retry)
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                // Over the top rather than instead of it: the WebView has to
                // stay in the tree to load at all.
                if (_isLoading) const LoadingView(),
              ],
            ),
    );
  }
}
