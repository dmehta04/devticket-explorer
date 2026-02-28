import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/providers.dart';
import 'discover_screen.dart';
import 'home_screen.dart';
import 'destinations_list_screen.dart';
import 'trips_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    final screens = [
      const DiscoverScreen(),
      const HomeScreen(),
      const DestinationsListScreen(),
      const TripsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentTab,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: (index) {
          ref.read(currentTabProvider.notifier).state = index;
        },
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppTheme.primary.withOpacity(0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore, color: AppTheme.primary),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: AppTheme.primary),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_city_outlined),
            selectedIcon: Icon(Icons.location_city, color: AppTheme.primary),
            label: 'Cities',
          ),
          NavigationDestination(
            icon: Icon(Icons.card_travel_outlined),
            selectedIcon: Icon(Icons.card_travel, color: AppTheme.primary),
            label: 'Trips',
          ),
        ],
      ),
    );
  }
}
