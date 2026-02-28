import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/destination.dart';
import '../providers/providers.dart';
import 'destination_detail_screen.dart';

class DestinationsListScreen extends ConsumerStatefulWidget {
  const DestinationsListScreen({super.key});

  @override
  ConsumerState<DestinationsListScreen> createState() =>
      _DestinationsListScreenState();
}

class _DestinationsListScreenState
    extends ConsumerState<DestinationsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<String> _regionTabs = [
    'All',
    'North',
    'South',
    'East',
    'West',
    'Central',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _regionTabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _getRegionColor(String region) {
    switch (region.toLowerCase()) {
      case 'north':
        return Colors.blue;
      case 'south':
        return Colors.green;
      case 'east':
        return Colors.orange;
      case 'west':
        return Colors.purple;
      case 'central':
        return Colors.teal;
      default:
        return AppTheme.primary;
    }
  }

  List<Destination> _filterDestinations(List<Destination> destinations) {
    var filtered = destinations;

    // Filter by region tab
    final selectedRegion = _regionTabs[_tabController.index];
    if (selectedRegion != 'All') {
      filtered = filtered
          .where((d) => d.region.toLowerCase() == selectedRegion.toLowerCase())
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((d) => d.city.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  Map<String, List<Destination>> _groupByRegion(
      List<Destination> destinations) {
    final grouped = <String, List<Destination>>{};
    for (final dest in destinations) {
      final region =
          dest.region.isNotEmpty ? dest.region : 'Other';
      grouped.putIfAbsent(region, () => []);
      grouped[region]!.add(dest);
    }
    // Sort regions alphabetically
    final sorted = Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    return sorted;
  }

  void _navigateToDetail(Destination dest) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DestinationDetailScreen(
          destination: dest,
          nearestStationId: 'frankfurt_hbf',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allDestinationsAsync = ref.watch(allDestinationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Destinations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(108),
          child: Column(
            children: [
              // Search field
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search cities...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon:
                        Icon(Icons.search, color: Colors.grey.shade600),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: Colors.grey.shade600, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // Region tabs
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                ),
                tabAlignment: TabAlignment.start,
                tabs: _regionTabs.map((region) {
                  return Tab(text: region);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      body: allDestinationsAsync.when(
        data: (destinations) {
          final filtered = _filterDestinations(destinations);

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'No cities match "$_searchQuery"'
                        : 'No destinations found in this region',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: const Text('Clear search'),
                    ),
                  ],
                ],
              ),
            );
          }

          // If showing "All" tab, group by region
          final selectedRegion = _regionTabs[_tabController.index];
          if (selectedRegion == 'All') {
            final grouped = _groupByRegion(filtered);
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final region = grouped.keys.elementAt(index);
                final regionDests = grouped[region]!;
                return _RegionSection(
                  region: region,
                  regionColor: _getRegionColor(region),
                  destinations: regionDests,
                  onDestinationTap: _navigateToDetail,
                );
              },
            );
          }

          // For specific region tab, show flat list
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _DestinationTile(
                destination: filtered[index],
                regionColor: _getRegionColor(filtered[index].region),
                onTap: () => _navigateToDetail(filtered[index]),
              );
            },
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.primary),
              SizedBox(height: 16),
              Text(
                'Loading destinations...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Could not load destinations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please check your internet connection\nor make sure the API server is running.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(allDestinationsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Region section header + its destination tiles
// ---------------------------------------------------------------------------

class _RegionSection extends StatelessWidget {
  final String region;
  final Color regionColor;
  final List<Destination> destinations;
  final ValueChanged<Destination> onDestinationTap;

  const _RegionSection({
    required this.region,
    required this.regionColor,
    required this.destinations,
    required this.onDestinationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Region header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: regionColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                region,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: regionColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: regionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${destinations.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: regionColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Destination tiles
        ...destinations.map(
          (dest) => _DestinationTile(
            destination: dest,
            regionColor: regionColor,
            onTap: () => onDestinationTap(dest),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual destination tile
// ---------------------------------------------------------------------------

class _DestinationTile extends StatelessWidget {
  final Destination destination;
  final Color regionColor;
  final VoidCallback onTap;

  const _DestinationTile({
    required this.destination,
    required this.regionColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeColor = destination.travelTimeMinutes > 0
        ? AppTheme.getTimeColor(destination.travelTimeMinutes)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: city name, region badge, time badge
              Row(
                children: [
                  // City name and state
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination.city,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          destination.state,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Region badge
                  if (destination.region.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: regionColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: regionColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        destination.region,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: regionColor,
                        ),
                      ),
                    ),
                  // Travel time badge
                  if (timeColor != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: timeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: timeColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time,
                              size: 13, color: timeColor),
                          const SizedBox(width: 4),
                          Text(
                            destination.formattedTime,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: timeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 10),

              // Description excerpt
              Text(
                destination.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 10),

              // Bottom row: highlights count, trip type
              Row(
                children: [
                  // Highlights count
                  if (destination.highlights.isNotEmpty) ...[
                    Icon(Icons.star_outline,
                        size: 15, color: Colors.amber.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '${destination.highlights.length} attraction${destination.highlights.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Trip type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: destination.tripType == 'weekend'
                          ? Colors.indigo.withOpacity(0.1)
                          : AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          destination.tripType == 'weekend'
                              ? Icons.weekend
                              : Icons.wb_sunny_outlined,
                          size: 13,
                          color: destination.tripType == 'weekend'
                              ? Colors.indigo
                              : AppTheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          destination.tripTypeLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: destination.tripType == 'weekend'
                                ? Colors.indigo
                                : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
