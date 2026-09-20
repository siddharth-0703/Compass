class LocalizedMediaSource {
  final String contentUrl;
  final String provider; // YOUTUBE, MP4, HLS
  final String contentType; // VIDEO

  const LocalizedMediaSource({
    required this.contentUrl,
    required this.provider,
    required this.contentType,
  });
}

class LocalizedMedia {
  final LocalizedMediaSource? en;
  final LocalizedMediaSource? hi;
  final LocalizedMediaSource? mr;

  const LocalizedMedia({
    this.en,
    this.hi,
    this.mr,
  });
}

class Lesson {
  final String id;
  final String title;
  final String description;
  final int durationSeconds;
  final LocalizedMedia? media;
  final List<String> resources;
  final int order;
  final bool isPublished;
  final String
      contentStatus; // NOT_CONFIGURED, CONFIGURED, VERIFIED, UNAVAILABLE

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.durationSeconds,
    this.media,
    required this.resources,
    required this.order,
    required this.isPublished,
    required this.contentStatus,
  });
}
