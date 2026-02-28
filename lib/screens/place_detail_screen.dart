import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../providers/providers.dart';
import '../widgets/rating_stars.dart';

class PlaceDetailScreen extends ConsumerWidget {
  final String placeId;

  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(placeDetailsProvider(placeId));
    final apiService = ref.watch(apiServiceProvider);

    return Scaffold(
      body: detailsAsync.when(
        data: (details) {
          return CustomScrollView(
            slivers: [
              // Photo header
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppTheme.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    details.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: details.photos.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: apiService.getPlacePhotoUrl(
                              details.placeId, details.photos.first),
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppTheme.primary.withOpacity(0.3),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppTheme.primary,
                            child: const Center(
                              child: Icon(Icons.restaurant,
                                  size: 48, color: Colors.white),
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.primary,
                          child: const Center(
                            child: Icon(Icons.restaurant,
                                size: 48, color: Colors.white),
                          ),
                        ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating & price
                      if (details.rating != null)
                        Row(
                          children: [
                            RatingStars(rating: details.rating!, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              details.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (details.totalRatings != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(${details.totalRatings} reviews)',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (details.priceLevel != null)
                              Text(
                                '\u20ac' * details.priceLevel!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accent,
                                ),
                              ),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // Address card
                      _InfoRow(
                        icon: Icons.location_on,
                        text: details.address,
                        actionIcon: Icons.map,
                        onAction: () => _openMaps(details.address),
                      ),
                      if (details.phone != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.phone,
                          text: details.phone!,
                          actionIcon: Icons.call,
                          onAction: () =>
                              _openUrl('tel:${details.phone}'),
                        ),
                      ],
                      if (details.website != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.language,
                          text: details.website!,
                          actionIcon: Icons.open_in_new,
                          onAction: () => _openUrl(details.website!),
                        ),
                      ],

                      // Opening hours
                      if (details.openingHours != null &&
                          details.openingHours!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Opening Hours',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: details.openingHours!
                                .map((h) => Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 2),
                                      child: Text(
                                        h,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],

                      // Reviews
                      if (details.reviews.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Reviews (${details.reviews.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...details.reviews.map((review) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor:
                                            AppTheme.primary.withOpacity(0.1),
                                        child: Text(
                                          review.author.isNotEmpty
                                              ? review.author[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              review.author,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                RatingStars(
                                                    rating: review.rating,
                                                    size: 12),
                                                const SizedBox(width: 6),
                                                Text(
                                                  review.timeDescription,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (review.text.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      review.text,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                        height: 1.4,
                                      ),
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            )),
                      ],

                      // Bottom actions
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _openMaps(details.address),
                              icon: const Icon(Icons.directions, size: 18),
                              label: const Text('Directions'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          if (details.website != null) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _openUrl(details.website!),
                                icon: const Icon(Icons.language, size: 18),
                                label: const Text('Website'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: const BorderSide(
                                      color: AppTheme.primary),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('Could not load details',
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _openMaps(String address) async {
    final encoded = Uri.encodeComponent(address);
    try {
      await launchUrl(
        Uri.parse('https://maps.apple.com/?q=$encoded'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final IconData actionIcon;
  final VoidCallback onAction;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.actionIcon,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onAction,
            icon: Icon(actionIcon, size: 18, color: AppTheme.primary),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
