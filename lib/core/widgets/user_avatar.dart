import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

/// A user's avatar — either one of the bundled illustrations or a photo they
/// uploaded. Figma node 55:865.
///
/// An uploaded photo wins over a picked illustration, since it is the more
/// deliberate choice.
///
/// Stateful only to cache the decode: base64 arrives as a string, and
/// decoding it inside `build` would re-run on every rebuild of the profile
/// screen. Decoding once per change keeps that off the frame path.
class UserAvatar extends StatefulWidget {
  const UserAvatar({
    super.key,
    required this.size,
    this.avatarId,
    this.photoBase64,
  });

  final double size;
  final String? avatarId;
  final String? photoBase64;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    _decodePhoto();
  }

  @override
  void didUpdateWidget(UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoBase64 != widget.photoBase64) _decodePhoto();
  }

  void _decodePhoto() {
    final encoded = widget.photoBase64;
    if (encoded == null || encoded.isEmpty) {
      _photoBytes = null;
      return;
    }

    try {
      _photoBytes = base64Decode(encoded);
    } on FormatException {
      // A corrupt string must not take the screen down — fall back to the
      // illustration instead.
      _photoBytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _photoBytes;

    return ClipOval(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: ColoredBox(
          color: AppColors.surface,
          child: bytes != null
              ? Image.memory(bytes, fit: BoxFit.cover)
              : Image.asset(
                  AppAssets.avatarPath(widget.avatarId),
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
