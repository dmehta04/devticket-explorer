# DevTicket App (Flutter)

## Build & Run
```bash
flutter pub get
flutter run
```

## Architecture
Deutschlandticket travel explorer app. Flutter 3.5.1, Riverpod, flutter_map.

### Key Facts
- **State**: Riverpod 2.4.0
- **Maps**: flutter_map 6.1.0 + latlong2
- **API**: Dio → `http://localhost:8090/api/v1`
- **10 screens**: HomeScreen, DiscoverScreen, DestinationsList, DestinationDetail, TransportLines, CircularRouteDetail, Trips, PlacesExplorer, PlaceDetail, MainShell
- **Navigation**: MainShell with bottom nav
