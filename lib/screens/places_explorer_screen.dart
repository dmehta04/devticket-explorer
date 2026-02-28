import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/destination.dart';
import '../providers/providers.dart';
import '../widgets/place_card.dart';
import 'place_detail_screen.dart';

class PlacesExplorerScreen extends ConsumerStatefulWidget {
  final Destination destination;

  const PlacesExplorerScreen({super.key, required this.destination});

  @override
  ConsumerState<PlacesExplorerScreen> createState() =>
      _PlacesExplorerScreenState();
}

class _PlacesExplorerScreenState extends ConsumerState<PlacesExplorerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _categories = [
    (label: 'All', value: null),
    (label: 'Cafes', value: 'cafe'),
    (label: 'Restaurants', value: 'restaurant'),
    (label: 'Bars', value: 'bar'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(placeCategoryProvider.notifier).state =
            _categories[_tabController.index].value;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = ref.watch(placeCategoryProvider);
    final placesAsync = ref.watch(placesProvider((
      destinationId: widget.destination.id,
      category: category,
    )));
    final apiService = ref.watch(apiServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Eat & Drink in ${widget.destination.city}'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: _categories
              .map((c) => Tab(
                    icon: Icon(_getCategoryIcon(c.value), size: 20),
                    text: c.label,
                  ))
              .toList(),
        ),
      ),
      body: placesAsync.when(
        data: (places) {
          if (places.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant_menu,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    category == null
                        ? 'No places found nearby'
                        : 'No ${category}s found nearby',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Google Places API key may not be configured',
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return PlaceCard(
                place: place,
                apiService: apiService,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PlaceDetailScreen(placeId: place.placeId),
                  ));
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'Could not load places',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                e.toString(),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'cafe':
        return Icons.coffee;
      case 'restaurant':
        return Icons.restaurant;
      case 'bar':
        return Icons.local_bar;
      default:
        return Icons.restaurant_menu;
    }
  }
}
