import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Daily feed card - unified design for all feed items
/// Displays contextual information from various modules
class DailyFeedCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback? onTap;

  const DailyFeedCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: item.accentColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Leading Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                item.icon,
                color: item.accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: item.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.module,
                          style: AppTextStyles.cardMeta.copyWith(
                            color: item.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.timeLabel,
                        style: AppTextStyles.cardMeta,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: AppTextStyles.cardTitle,
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle!,
                      style: AppTextStyles.cardSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Data model for feed items
class FeedItem {
  final String id;
  final String module;
  final String title;
  final String? subtitle;
  final String timeLabel;
  final IconData icon;
  final Color accentColor;

  const FeedItem({
    required this.id,
    required this.module,
    required this.title,
    this.subtitle,
    required this.timeLabel,
    required this.icon,
    required this.accentColor,
  });
}

/// Demo için örnek veriler
class DummyFeedData {
  static List<FeedItem> get todaysFeed => [
    const FeedItem(
      id: '1',
      module: 'Bütçe',
      title: 'Yaklaşan Fatura: Netflix',
      subtitle: 'Aylık abonelik - ₺99.99',
      timeLabel: 'Yarın',
      icon: Icons.subscriptions_rounded,
      accentColor: AppColors.budgetAccent,
    ),
    const FeedItem(
      id: '2',
      module: 'Aile',
      title: 'Parla\'nın Aşısı',
      subtitle: 'Şehir Veteriner Kliniği\'nde planlandı',
      timeLabel: '2 gün sonra',
      icon: Icons.vaccines_rounded,
      accentColor: AppColors.familyAccent,
    ),
    const FeedItem(
      id: '3',
      module: 'Araba',
      title: 'Servis Hatırlatması',
      subtitle: '45.000 km\'de yağ değişimi gerekli',
      timeLabel: 'Gelecek hafta',
      icon: Icons.build_rounded,
      accentColor: AppColors.carAccent,
    ),
    const FeedItem(
      id: '4',
      module: 'Fitness',
      title: 'Haftalık Hedef İlerlemesi',
      subtitle: '5 antrenmandan 4\'ü tamamlandı',
      timeLabel: 'Bu hafta',
      icon: Icons.trending_up_rounded,
      accentColor: AppColors.fitnessAccent,
    ),
    const FeedItem(
      id: '5',
      module: 'Seyahat',
      title: 'Antalya Gezisi',
      subtitle: 'Uçuş rezervasyonu onayı bekleniyor',
      timeLabel: '12 gün sonra',
      icon: Icons.flight_takeoff_rounded,
      accentColor: AppColors.travelAccent,
    ),
    const FeedItem(
      id: '6',
      module: 'Ev',
      title: 'Elektrik Faturası',
      subtitle: 'Son ödeme tarihi yaklaşıyor',
      timeLabel: '5 gün sonra',
      icon: Icons.bolt_rounded,
      accentColor: AppColors.homeAccent,
    ),
    const FeedItem(
      id: '7',
      module: 'Podcast',
      title: 'Yeni Bölüm Yayında',
      subtitle: 'The Daily - "Yapay Zeka Devrimi"',
      timeLabel: 'Bugün',
      icon: Icons.headphones_rounded,
      accentColor: AppColors.podcastAccent,
    ),
    const FeedItem(
      id: '8',
      module: 'Evcil Hayvan',
      title: 'Max\'in Veteriner Randevusu',
      subtitle: 'Yıllık kontrol planlandı',
      timeLabel: 'Yarın',
      icon: Icons.pets_rounded,
      accentColor: AppColors.petsAccent,
    ),
  ];
}
