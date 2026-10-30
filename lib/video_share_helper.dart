import 'dart:io';

import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

/// Utility for sharing or saving local video files.
class VideoShareHelper {
  const VideoShareHelper._();

  /// Shares a local video file using the system share sheet.
  static Future<void> shareVideo({
    required String videoPath,
    String message = '我分享了一个视频给你',
  }) async {
    final file = File(videoPath);
    if (!await file.exists()) {
      throw FileSystemException('视频文件不存在', videoPath);
    }

    final xFile = XFile(
      videoPath,
      mimeType: _guessMimeType(videoPath),
      name: _basename(videoPath),
    );

    await Share.shareXFiles(
      [xFile],
      text: message,
    );
  }

  /// Saves a video to the system photo library / gallery.
  /// Returns true when the operation succeeds.
  static Future<bool> saveVideoToGallery({
    required String videoPath,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS && !Platform.isMacOS) {
      return false;
    }

    final file = File(videoPath);
    if (!await file.exists()) {
      return false;
    }

    try {
      final success = await Gal.putVideo(videoPath);
      return success;
    } on Exception {
      return false;
    }
  }

  static String _basename(String path) {
    final uri = Uri.file(path);
    return uri.pathSegments.isEmpty ? 'video' : uri.pathSegments.last;
  }

  static String _guessMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.mp4')) return 'video/mp4';
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.m4v')) return 'video/x-m4v';
    if (lower.endsWith('.webm')) return 'video/webm';
    return 'video/mp4';
  }
}

/// Example use in UI:
///
/// ElevatedButton(
///   onPressed: () async {
///     final path = '/storage/emulated/0/Download/demo.mp4';
///     try {
///       await VideoShareHelper.shareVideo(videoPath: path);
///     } catch (_) {
///       // handle error
///     }
///   },
///   child: const Text('分享'),
/// );
///
/// ElevatedButton(
///   onPressed: () async {
///     final path = '/storage/emulated/0/Download/demo.mp4';
///     final ok = await VideoShareHelper.saveVideoToGallery(videoPath: path);
///     if (!ok) {
///       // handle failure
///     }
///   },
///   child: const Text('保存到相册'),
/// );
