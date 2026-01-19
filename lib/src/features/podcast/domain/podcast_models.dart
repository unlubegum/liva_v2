import 'package:flutter/material.dart';

/// Podcast kategorileri
enum PodcastCategory { technology, business, selfImprovement, comedy, news, health, education, history }

/// Podcast modeli
class Podcast {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final PodcastCategory category;
  final String description;
  final Color accentColor;
  final List<Episode> episodes;
  final bool isSubscribed;

  const Podcast({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.category,
    required this.description,
    required this.accentColor,
    this.episodes = const [],
    this.isSubscribed = false,
  });

  String get categoryLabel => switch (category) {
    PodcastCategory.technology => 'Teknoloji',
    PodcastCategory.business => 'İş Dünyası',
    PodcastCategory.selfImprovement => 'Kişisel Gelişim',
    PodcastCategory.comedy => 'Komedi',
    PodcastCategory.news => 'Haberler',
    PodcastCategory.health => 'Sağlık',
    PodcastCategory.education => 'Eğitim',
    PodcastCategory.history => 'Tarih',
  };

  IconData get categoryIcon => switch (category) {
    PodcastCategory.technology => Icons.computer_rounded,
    PodcastCategory.business => Icons.business_center_rounded,
    PodcastCategory.selfImprovement => Icons.self_improvement_rounded,
    PodcastCategory.comedy => Icons.sentiment_very_satisfied_rounded,
    PodcastCategory.news => Icons.newspaper_rounded,
    PodcastCategory.health => Icons.health_and_safety_rounded,
    PodcastCategory.education => Icons.school_rounded,
    PodcastCategory.history => Icons.history_edu_rounded,
  };

  Podcast copyWith({bool? isSubscribed, List<Episode>? episodes}) => Podcast(
    id: id, title: title, author: author, coverUrl: coverUrl,
    category: category, description: description, accentColor: accentColor,
    episodes: episodes ?? this.episodes, isSubscribed: isSubscribed ?? this.isSubscribed,
  );
}

/// Bölüm modeli
class Episode {
  final String id;
  final String podcastId;
  final String title;
  final String description;
  final Duration duration;
  final DateTime publishDate;
  final Duration listenedDuration;
  final bool isDownloaded;

  const Episode({
    required this.id,
    required this.podcastId,
    required this.title,
    required this.description,
    required this.duration,
    required this.publishDate,
    this.listenedDuration = Duration.zero,
    this.isDownloaded = false,
  });

  bool get isListened => listenedDuration >= duration;
  bool get isInProgress => listenedDuration > Duration.zero && !isListened;
  double get progress => duration.inSeconds > 0 ? listenedDuration.inSeconds / duration.inSeconds : 0;

  String get durationText {
    final mins = duration.inMinutes;
    if (mins < 60) return '$mins dk';
    return '${mins ~/ 60} sa ${mins % 60} dk';
  }

  String get progressText {
    if (isListened) return 'Tamamlandı';
    if (!isInProgress) return durationText;
    final remaining = duration - listenedDuration;
    return '${remaining.inMinutes} dk kaldı';
  }

  Episode copyWith({Duration? listenedDuration, bool? isDownloaded}) => Episode(
    id: id, podcastId: podcastId, title: title, description: description,
    duration: duration, publishDate: publishDate,
    listenedDuration: listenedDuration ?? this.listenedDuration,
    isDownloaded: isDownloaded ?? this.isDownloaded,
  );
}

/// Şu an çalan
class NowPlaying {
  final Episode episode;
  final Podcast podcast;
  final bool isPlaying;
  final Duration position;

  const NowPlaying({
    required this.episode,
    required this.podcast,
    this.isPlaying = false,
    this.position = Duration.zero,
  });
}
