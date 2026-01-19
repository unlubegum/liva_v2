import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/podcast_repository.dart';
import '../domain/podcast_models.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ANA EKRAN
// ═══════════════════════════════════════════════════════════════════════════

class PodcastScreen extends ConsumerWidget {
  const PodcastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscribed = ref.watch(subscribedPodcastsProvider);
    final discover = ref.watch(discoverPodcastsProvider);
    final inProgress = ref.watch(inProgressEpisodesProvider);
    final nowPlaying = ref.watch(nowPlayingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120, pinned: true,
                backgroundColor: AppColors.podcastAccent,
                leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
                title: Text('Podcast', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [AppColors.podcastAccent, AppColors.podcastAccent.withOpacity(0.7), const Color(0xFF8E44AD)],
                      ),
                    ),
                  ),
                ),
              ),

              // Continue Listening
              if (inProgress.isNotEmpty) ...[
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text('Devam Et', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)))),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: inProgress.length,
                      itemBuilder: (_, i) {
                        final (episode, podcast) = inProgress[i];
                        return _ContinueCard(episode: episode, podcast: podcast, ref: ref).animate(delay: Duration(milliseconds: 100 * i)).fadeIn().slideX(begin: 0.1, end: 0);
                      },
                    ),
                  ),
                ),
              ],

              // Subscribed Podcasts
              if (subscribed.isNotEmpty) ...[
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 8), child: Text('Aboneliklerim', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)))),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: subscribed.length,
                      itemBuilder: (_, i) => _PodcastCard(podcast: subscribed[i], ref: ref).animate(delay: Duration(milliseconds: 100 * i)).fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
                    ),
                  ),
                ),
              ],

              // Discover
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 8), child: Text('Keşfet', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)))),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: _DiscoverTile(podcast: discover[i], ref: ref),
                  ),
                  childCount: discover.length,
                ),
              ),

              // All Episodes from subscribed
              if (subscribed.isNotEmpty) ...[
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 8), child: Text('Son Bölümler', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)))),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final allEpisodes = subscribed.expand((p) => p.episodes.map((e) => (e, p))).toList()
                        ..sort((a, b) => b.$1.publishDate.compareTo(a.$1.publishDate));
                      if (i >= allEpisodes.length) return null;
                      final (episode, podcast) = allEpisodes[i];
                      return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: _EpisodeTile(episode: episode, podcast: podcast, ref: ref));
                    },
                    childCount: subscribed.expand((p) => p.episodes).length.clamp(0, 10),
                  ),
                ),
              ],

              SliverToBoxAdapter(child: SizedBox(height: nowPlaying != null ? 120 : 40)),
            ],
          ),

          // Mini Player
          if (nowPlaying != null)
            Positioned(bottom: 0, left: 0, right: 0, child: _MiniPlayer(nowPlaying: nowPlaying, ref: ref)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET'LAR
// ═══════════════════════════════════════════════════════════════════════════

class _ContinueCard extends StatelessWidget {
  final Episode episode; final Podcast podcast; final WidgetRef ref;
  const _ContinueCard({required this.episode, required this.podcast, required this.ref});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => ref.read(nowPlayingProvider.notifier).state = NowPlaying(episode: episode, podcast: podcast, isPlaying: true, position: episode.listenedDuration),
    child: Container(
      width: 280, margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: podcast.accentColor.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: podcast.accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
          child: Center(child: Icon(podcast.categoryIcon, color: podcast.accentColor, size: 28)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(episode.title, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(podcast.title, style: TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(value: episode.progress, backgroundColor: AppColors.surfaceVariant, valueColor: AlwaysStoppedAnimation(podcast.accentColor), minHeight: 4),
            )),
            const SizedBox(width: 8),
            Text(episode.progressText, style: TextStyle(fontSize: 10, color: podcast.accentColor, fontWeight: FontWeight.w600)),
          ]),
        ])),
      ]),
    ),
  );
}

class _PodcastCard extends StatelessWidget {
  final Podcast podcast; final WidgetRef ref;
  const _PodcastCard({required this.podcast, required this.ref});

  @override
  Widget build(BuildContext context) => Container(
    width: 120, margin: const EdgeInsets.only(right: 12),
    child: Column(children: [
      Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [podcast.accentColor, podcast.accentColor.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: podcast.accentColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Center(child: Icon(podcast.categoryIcon, color: Colors.white, size: 40)),
      ),
      const SizedBox(height: 10),
      Text(podcast.title, style: AppTextStyles.cardTitle.copyWith(fontSize: 12), maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
    ]),
  );
}

class _DiscoverTile extends StatelessWidget {
  final Podcast podcast; final WidgetRef ref;
  const _DiscoverTile({required this.podcast, required this.ref});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(gradient: LinearGradient(colors: [podcast.accentColor, podcast.accentColor.withOpacity(0.7)]), borderRadius: BorderRadius.circular(14)),
        child: Center(child: Icon(podcast.categoryIcon, color: Colors.white, size: 26)),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(podcast.title, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(podcast.author, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: podcast.accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Text(podcast.categoryLabel, style: TextStyle(fontSize: 10, color: podcast.accentColor, fontWeight: FontWeight.w600)),
        ),
      ])),
      GestureDetector(
        onTap: () => ref.read(podcastsProvider.notifier).toggleSubscription(podcast.id),
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: podcast.accentColor.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(Icons.add_rounded, color: podcast.accentColor, size: 20),
        ),
      ),
    ]),
  );
}

class _EpisodeTile extends StatelessWidget {
  final Episode episode; final Podcast podcast; final WidgetRef ref;
  const _EpisodeTile({required this.episode, required this.podcast, required this.ref});

  @override
  Widget build(BuildContext context) {
    final months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return GestureDetector(
      onTap: () => ref.read(nowPlayingProvider.notifier).state = NowPlaying(episode: episode, podcast: podcast, isPlaying: true, position: episode.listenedDuration),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: podcast.accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(episode.isListened ? Icons.check_circle_rounded : Icons.play_circle_filled_rounded, color: episode.isListened ? AppColors.success : podcast.accentColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(episode.title, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600, color: episode.isListened ? AppColors.textTertiary : AppColors.textPrimary, decoration: episode.isListened ? TextDecoration.lineThrough : null), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${episode.publishDate.day} ${months[episode.publishDate.month - 1]} • ${episode.durationText}', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ])),
          if (episode.isInProgress)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: podcast.accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Text('${(episode.progress * 100).toInt()}%', style: TextStyle(fontSize: 10, color: podcast.accentColor, fontWeight: FontWeight.w600)),
            ),
        ]),
      ),
    );
  }
}

class _MiniPlayer extends StatelessWidget {
  final NowPlaying nowPlaying; final WidgetRef ref;
  const _MiniPlayer({required this.nowPlaying, required this.ref});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: nowPlaying.podcast.accentColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: nowPlaying.podcast.accentColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6))],
    ),
    child: Row(children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: Icon(nowPlaying.podcast.categoryIcon, color: Colors.white, size: 24),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(nowPlaying.episode.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(nowPlaying.podcast.title, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
      ])),
      IconButton(
        icon: Icon(nowPlaying.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 32),
        onPressed: () => ref.read(nowPlayingProvider.notifier).state = NowPlaying(episode: nowPlaying.episode, podcast: nowPlaying.podcast, isPlaying: !nowPlaying.isPlaying, position: nowPlaying.position),
      ),
      IconButton(
        icon: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.7), size: 24),
        onPressed: () => ref.read(nowPlayingProvider.notifier).state = null,
      ),
    ]),
  ).animate().slideY(begin: 1, end: 0, duration: 300.ms);
}
