import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../models/place.dart';

class AttractionCard extends StatelessWidget {
  final Attraction attraction;

  const AttractionCard({super.key, required this.attraction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo
          if (attraction.photoUrl.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: attraction.photoUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 160,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 160,
                  color: AppTheme.primary.withOpacity(0.1),
                  child: const Center(
                    child:
                        Icon(Icons.image, size: 40, color: AppTheme.primary),
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number badge + name
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${attraction.displayOrder}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        attraction.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                // Description
                if (attraction.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    attraction.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Action chips
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    if (attraction.wikiUrl.isNotEmpty)
                      ActionChip(
                        avatar: const Icon(Icons.menu_book,
                            size: 16, color: AppTheme.primary),
                        label: const Text('Wikipedia',
                            style: TextStyle(fontSize: 12)),
                        onPressed: () => _openUrl(attraction.wikiUrl),
                        backgroundColor: AppTheme.primary.withOpacity(0.08),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ActionChip(
                      avatar: const Icon(Icons.map,
                          size: 16, color: AppTheme.accent),
                      label:
                          const Text('Maps', style: TextStyle(fontSize: 12)),
                      onPressed: () => _openMaps(attraction.name),
                      backgroundColor: AppTheme.accent.withOpacity(0.08),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _openMaps(String query) async {
    final encoded = Uri.encodeComponent(query);
    try {
      await launchUrl(
        Uri.parse('https://maps.apple.com/?q=$encoded'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }
}
