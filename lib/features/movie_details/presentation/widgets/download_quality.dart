/// One row in the download sheet.
///
/// ⚠️ PRESENTATION ONLY. There is no download layer behind this — the values
/// are supplied by the screen as static text, so [size] is a formatted string
/// rather than a byte count. When a real source is wired up this becomes an
/// entity with `sizeBytes` and a URL, and the formatting moves off the screen.
class DownloadQuality {
  const DownloadQuality({required this.label, required this.size});

  /// e.g. `1080p`.
  final String label;

  /// Already formatted, e.g. `1.6 GB`.
  final String size;
}
