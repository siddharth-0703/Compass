import 'dart:async';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoStreamInfo {
  final String streamUrl;
  final int totalBytes;
  final String resolution;
  final String container;

  const VideoStreamInfo({
    required this.streamUrl,
    required this.totalBytes,
    required this.resolution,
    required this.container,
  });
}

class VideoStreamResolver {
  static final Map<String, VideoStreamInfo> _cache = {};
  static final YoutubeExplode _yt = YoutubeExplode();

  /// Extract video ID from youtube URL or return raw ID
  static String? extractYoutubeId(String url) {
    if (url.isEmpty) return null;
    if (!url.contains('/') && !url.contains('.')) {
      return url.trim();
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtube.com')) {
      if (uri.pathSegments.contains('embed')) {
        return uri.pathSegments.last;
      }
      return uri.queryParameters['v'];
    } else if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    return null;
  }

  /// Resolves a direct MP4 streaming URL from YouTube video or returns direct URL
  static Future<VideoStreamInfo?> resolve(String mediaUrl) async {
    final ytId = extractYoutubeId(mediaUrl);

    // If not YouTube, treat as direct URL
    if (ytId == null || ytId.isEmpty) {
      if (mediaUrl.startsWith('http://') || mediaUrl.startsWith('https://')) {
        return VideoStreamInfo(
          streamUrl: mediaUrl,
          totalBytes: 0,
          resolution: '720p',
          container: 'mp4',
        );
      }
      return null;
    }

    // Check memory cache
    if (_cache.containsKey(ytId)) {
      return _cache[ytId];
    }

    try {
      final manifest = await _yt.videos.streamsClient.getManifest(ytId).timeout(
        const Duration(seconds: 12),
      );
      final muxed = manifest.muxed.withHighestBitrate();
      final info = VideoStreamInfo(
        streamUrl: muxed.url.toString(),
        totalBytes: muxed.size.totalBytes,
        resolution: '${muxed.videoResolution}',
        container: muxed.container.name,
      );
      _cache[ytId] = info;
      return info;
    } catch (_) {
      // Return null on extraction failure
      return null;
    }
  }

  static void dispose() {
    _yt.close();
  }
}

