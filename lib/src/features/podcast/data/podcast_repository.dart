import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/podcast_models.dart';

/// Podcast Repository Provider
final podcastRepositoryProvider = Provider<PodcastRepository>((ref) => PodcastRepository());

class PodcastRepository {
  List<Podcast> getPodcasts() {
    final now = DateTime.now();
    return [
      Podcast(
        id: 'p1',
        title: 'Girişimci Muhabbeti',
        author: 'Enis Hulli',
        coverUrl: '',
        category: PodcastCategory.business,
        description: 'Türkiye\'nin en başarılı girişimcileriyle sohbetler',
        accentColor: const Color(0xFF9B59B6),
        isSubscribed: true,
        episodes: [
          Episode(id: 'e1', podcastId: 'p1', title: 'Startup Ekosistemi 2024', description: 'Yatırımcı gözünden Türkiye', duration: const Duration(minutes: 45), publishDate: now.subtract(const Duration(days: 2)), listenedDuration: const Duration(minutes: 20)),
          Episode(id: 'e2', podcastId: 'p1', title: 'Bootstrapping vs VC', description: 'Hangi yol size uygun?', duration: const Duration(minutes: 52), publishDate: now.subtract(const Duration(days: 9))),
          Episode(id: 'e3', podcastId: 'p1', title: 'Exit Stratejileri', description: 'Şirketinizi satmak', duration: const Duration(minutes: 38), publishDate: now.subtract(const Duration(days: 16)), listenedDuration: const Duration(minutes: 38)),
        ],
      ),
      Podcast(
        id: 'p2',
        title: 'Teknoloji Sohbetleri',
        author: 'Serdar Kuzuloğlu',
        coverUrl: '',
        category: PodcastCategory.technology,
        description: 'Güncel teknoloji haberleri ve analizler',
        accentColor: const Color(0xFF3498DB),
        isSubscribed: true,
        episodes: [
          Episode(id: 'e4', podcastId: 'p2', title: 'AI Devrimi', description: 'ChatGPT ve geleceğimiz', duration: const Duration(minutes: 62), publishDate: now.subtract(const Duration(days: 1))),
          Episode(id: 'e5', podcastId: 'p2', title: 'Apple Vision Pro', description: 'AR gözlükler kullanışlı mı?', duration: const Duration(minutes: 48), publishDate: now.subtract(const Duration(days: 8)), listenedDuration: const Duration(minutes: 48)),
        ],
      ),
      Podcast(
        id: 'p3',
        title: 'Zihin Jimnastiği',
        author: 'Dr. Hakan Atalay',
        coverUrl: '',
        category: PodcastCategory.selfImprovement,
        description: 'Kişisel gelişim ve psikoloji',
        accentColor: const Color(0xFF2ECC71),
        isSubscribed: false,
        episodes: [
          Episode(id: 'e6', podcastId: 'p3', title: 'Alışkanlık Döngüsü', description: 'Yeni alışkanlıklar nasıl oluşur?', duration: const Duration(minutes: 35), publishDate: now.subtract(const Duration(days: 3))),
          Episode(id: 'e7', podcastId: 'p3', title: 'Motivasyon Mitleri', description: 'Gerçek motivasyon kaynakları', duration: const Duration(minutes: 42), publishDate: now.subtract(const Duration(days: 10))),
        ],
      ),
      Podcast(
        id: 'p4',
        title: 'Tarih Kazanı',
        author: 'Prof. İlber Ortaylı',
        coverUrl: '',
        category: PodcastCategory.history,
        description: 'Tarihten dersler ve hikayeler',
        accentColor: const Color(0xFFE67E22),
        isSubscribed: false,
        episodes: [
          Episode(id: 'e8', podcastId: 'p4', title: 'Osmanlı Ekonomisi', description: 'İmparatorluğun mali yapısı', duration: const Duration(minutes: 55), publishDate: now.subtract(const Duration(days: 5))),
        ],
      ),
    ];
  }
}

/// Tüm podcastler provider
final podcastsProvider = StateNotifierProvider<PodcastsNotifier, List<Podcast>>((ref) {
  final repo = ref.watch(podcastRepositoryProvider);
  return PodcastsNotifier(repo.getPodcasts());
});

class PodcastsNotifier extends StateNotifier<List<Podcast>> {
  PodcastsNotifier(super.initial);

  void toggleSubscription(String podcastId) {
    state = state.map((p) => p.id == podcastId ? p.copyWith(isSubscribed: !p.isSubscribed) : p).toList();
  }

  void updateEpisodeProgress(String episodeId, Duration progress) {
    state = state.map((podcast) {
      final updatedEpisodes = podcast.episodes.map((e) {
        if (e.id != episodeId) return e;
        return e.copyWith(listenedDuration: progress);
      }).toList();
      return podcast.copyWith(episodes: updatedEpisodes);
    }).toList();
  }
}

/// Abone olunan podcastler
final subscribedPodcastsProvider = Provider<List<Podcast>>((ref) {
  return ref.watch(podcastsProvider).where((p) => p.isSubscribed).toList();
});

/// Keşfet podcastleri (abone olunmayan)
final discoverPodcastsProvider = Provider<List<Podcast>>((ref) {
  return ref.watch(podcastsProvider).where((p) => !p.isSubscribed).toList();
});

/// Devam eden bölümler
final inProgressEpisodesProvider = Provider<List<(Episode, Podcast)>>((ref) {
  final podcasts = ref.watch(podcastsProvider);
  final List<(Episode, Podcast)> result = [];
  for (final p in podcasts) {
    for (final e in p.episodes) {
      if (e.isInProgress) result.add((e, p));
    }
  }
  return result;
});

/// Now playing provider
final nowPlayingProvider = StateProvider<NowPlaying?>((ref) => null);
