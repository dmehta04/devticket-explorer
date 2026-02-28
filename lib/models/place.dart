import 'package:flutter/material.dart';

class Place {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? totalRatings;
  final int? priceLevel;
  final List<String> types;
  final bool? isOpenNow;
  final String? photoRef;

  Place({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.totalRatings,
    this.priceLevel,
    this.types = const [],
    this.isOpenNow,
    this.photoRef,
  });

  String get priceLevelString {
    if (priceLevel == null) return '';
    return '\u20ac' * priceLevel!;
  }

  String get categoryLabel {
    if (types.contains('cafe')) return 'Cafe';
    if (types.contains('bar')) return 'Bar';
    if (types.contains('restaurant')) return 'Restaurant';
    return 'Place';
  }

  IconData get categoryIcon {
    if (types.contains('cafe')) return Icons.coffee;
    if (types.contains('bar')) return Icons.local_bar;
    if (types.contains('restaurant')) return Icons.restaurant;
    return Icons.place;
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      totalRatings: json['total_ratings'] as int?,
      priceLevel: json['price_level'] as int?,
      types: (json['types'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isOpenNow: json['is_open_now'] as bool?,
      photoRef: json['photo_ref'] as String?,
    );
  }
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String address;
  final String? phone;
  final String? website;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? totalRatings;
  final int? priceLevel;
  final List<String>? openingHours;
  final List<PlaceReview> reviews;
  final List<String> photos;

  PlaceDetails({
    required this.placeId,
    required this.name,
    required this.address,
    this.phone,
    this.website,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.totalRatings,
    this.priceLevel,
    this.openingHours,
    this.reviews = const [],
    this.photos = const [],
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    return PlaceDetails(
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      totalRatings: json['total_ratings'] as int?,
      priceLevel: json['price_level'] as int?,
      openingHours: (json['opening_hours'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map(
                  (e) => PlaceReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class PlaceReview {
  final String author;
  final double rating;
  final String text;
  final String timeDescription;

  PlaceReview({
    required this.author,
    required this.rating,
    required this.text,
    required this.timeDescription,
  });

  factory PlaceReview.fromJson(Map<String, dynamic> json) {
    return PlaceReview(
      author: json['author'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      text: json['text'] as String? ?? '',
      timeDescription: json['time_description'] as String? ?? '',
    );
  }
}

class Attraction {
  final String id;
  final String destinationId;
  final String name;
  final String description;
  final String photoUrl;
  final String wikiUrl;
  final int displayOrder;

  Attraction({
    required this.id,
    required this.destinationId,
    required this.name,
    this.description = '',
    this.photoUrl = '',
    this.wikiUrl = '',
    this.displayOrder = 0,
  });

  factory Attraction.fromJson(Map<String, dynamic> json) {
    return Attraction(
      id: json['id'] as String,
      destinationId: json['destination_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      photoUrl: json['photo_url'] as String? ?? '',
      wikiUrl: json['wiki_url'] as String? ?? '',
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }
}
