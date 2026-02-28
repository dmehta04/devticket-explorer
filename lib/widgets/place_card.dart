import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/place.dart';
import '../services/api_service.dart';
import 'rating_stars.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final ApiService apiService;
  final VoidCallback onTap;

  const PlaceCard({
    super.key,
    required this.place,
    required this.apiService,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(14)),
              child: SizedBox(
                width: 90,
                height: 90,
                child: place.photoRef != null
                    ? CachedNetworkImage(
                        imageUrl: apiService.getPlacePhotoUrl(
                            place.placeId, place.photoRef!),
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.grey.shade200),
                        errorWidget: (_, __, ___) => _placeholderIcon(),
                      )
                    : _placeholderIcon(),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (place.rating != null)
                      Row(
                        children: [
                          RatingStars(rating: place.rating!, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            place.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (place.totalRatings != null) ...[
                            Text(
                              ' (${place.totalRatings})',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(place.categoryIcon,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          place.categoryLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (place.priceLevelString.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            place.priceLevelString,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (place.isOpenNow == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Open',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(place.categoryIcon, size: 30, color: Colors.grey.shade400),
      ),
    );
  }
}
