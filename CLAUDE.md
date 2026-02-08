# Deutschlandticket Explorer

## Project Overview
An interactive app that helps tourists and residents maximize their **Deutschlandticket** (Germany's €63/month nationwide regional public transport pass). Shows reachable destinations via regional trains (RE/RB), S-Bahn, U-Bahn, trams, and buses — excluding ICE/IC/EC long-distance trains.

## Architecture
Two projects in this repo:

### `devticket_api/` — Rust Backend (Axum + SQLite)
- **Framework**: Axum 0.7 (uses `:param` syntax for path params, NOT `{param}`)
- **Database**: SQLite via rusqlite (bundled feature, embedded)
- **Port**: 8090 (port 8080 is taken by Jenkins)
- **Data**: 52 German cities, 106 connections, 26 route segments

### `devticket_app/` — Flutter Frontend
- **Map**: flutter_map + OpenStreetMap tiles (free, no API key)
- **State**: Riverpod (flutter_riverpod)
- **HTTP**: Dio
- **URL launching**: url_launcher
- **Flutter SDK**: `/Users/dheerajmehta/flutter/bin/flutter` (not in PATH, must use full path)

## Build & Run Commands

### Backend
```bash
cd devticket_api
cargo build
cargo run
# Server starts on http://localhost:8090
# To recreate DB with fresh seed data: rm devticket.db && cargo run
```

### Frontend
```bash
cd devticket_app
/Users/dheerajmehta/flutter/bin/flutter pub get
/Users/dheerajmehta/flutter/bin/flutter analyze
/Users/dheerajmehta/flutter/bin/flutter run -d <device-id>
# iOS Simulator: xcrun simctl list devices booted
# Hot reload: r | Hot restart: R
```

### Verify API
```bash
curl http://localhost:8090/api/v1/health
curl "http://localhost:8090/api/v1/destinations?lat=50.1&lng=8.7&max_minutes=240"
curl http://localhost:8090/api/v1/destinations/all
curl http://localhost:8090/api/v1/coverage
curl http://localhost:8090/api/v1/trips
curl "http://localhost:8090/api/v1/destinations/search?q=berlin&lat=50.1&lng=8.7"
curl http://localhost:8090/api/v1/routes/berlin_hbf/hamburg
```

## API Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/health` | Health check |
| GET | `/api/v1/stations/nearby?lat=&lng=&radius=` | Nearest stations |
| GET | `/api/v1/destinations?lat=&lng=&max_minutes=` | Reachable destinations (time-filtered) |
| GET | `/api/v1/destinations/all` | All 52 destinations (for Cities tab) |
| GET | `/api/v1/destinations/search?q=&lat=&lng=` | Search by name |
| GET | `/api/v1/routes/:from_id/:to_id` | Route detail with segments |
| GET | `/api/v1/coverage` | Coverage info (N/S/E/W boundaries) |
| GET | `/api/v1/trips?trip_type=` | Featured trips (optional filter: day_trip, weekend) |

## App Structure

### Flutter Screens (4 tabs via bottom NavigationBar)
1. **Discover** (`discover_screen.dart`) — Welcome page: D-Ticket info, transport types grid, compass coverage, stats, NOT included warning, buy ticket links
2. **Map** (`home_screen.dart`) — Interactive OpenStreetMap with color-coded markers, search, time filters, destination card carousel
3. **Cities** (`destinations_list_screen.dart`) — All 52 cities grouped by region (North/South/East/West/Central), search, TabBar filter
4. **Trips** (`trips_screen.dart`) — Curated trip cards with gradient headers, filter by day_trip/weekend

### Destination Detail (`destination_detail_screen.dart`)
- ICE vs D-Ticket comparison card (time + price)
- Numbered top attractions list (8 per city)
- Step-by-step route timeline with transport badges
- Buy Deutschlandticket button (url_launcher → deutschlandticket.de)

### Key Files
```
devticket_api/src/
├── main.rs          # Server init, routing, CORS
├── models.rs        # All data structs (Serialize/Deserialize)
├── handlers.rs      # HTTP endpoint handlers
├── db.rs            # SQLite schema + seed data (52 cities)
└── geo.rs           # Haversine distance calculation

devticket_app/lib/
├── main.dart                  # Entry point → MainShell
├── config/
│   ├── app_config.dart        # API base URL (localhost:8090), defaults
│   └── theme.dart             # AppTheme (colors, transport helpers)
├── models/
│   ├── destination.dart       # Destination model with region, highlights, ICE data
│   └── route_detail.dart      # RouteDetail, RouteSegment, Station models
├── providers/
│   └── providers.dart         # All Riverpod providers
├── screens/
│   ├── main_shell.dart        # Bottom nav with IndexedStack
│   ├── discover_screen.dart   # Tab 0: Welcome/info
│   ├── home_screen.dart       # Tab 1: Map
│   ├── destinations_list_screen.dart  # Tab 2: Cities
│   ├── trips_screen.dart      # Tab 3: Trips
│   └── destination_detail_screen.dart # Detail view
├── services/
│   ├── api_service.dart       # Dio HTTP client
│   └── location_service.dart  # GPS location
└── widgets/
    ├── map_widget.dart        # flutter_map with markers
    ├── destination_card.dart   # Horizontal scroll card
    ├── filter_chips.dart       # Time filter (1h/2h/3h/4h+)
    ├── search_bar_widget.dart  # Search overlay
    └── transport_badge.dart    # RE/S/U/Tram/Bus badges
```

## Important Notes
- Station/destination IDs are strings (e.g., `berlin_hbf`, `hamburg`), not integers
- iOS simulator uses `localhost` for API; Android emulator uses `10.0.2.2`
- Route segments only seeded for a few key connections; detail screen falls back to DirectConnectionCard gracefully
- Shell is zsh — multiline piped commands with `|` can fail in Bash tool; use separate calls
- The DB file (`devticket.db`) is auto-created on first run with seed data

## Current Status (Feb 2026)
- All features implemented and tested
- Backend: compiles and runs cleanly
- Frontend: `flutter analyze` — 0 issues
- Tested on iOS (iPhone 16 Pro simulator) and Android (sdk gphone64 arm64 emulator)
- All 7 API endpoints verified working
- No runtime errors

## Possible Future Enhancements
- Real-time transport data integration (Deutsche Bahn API)
- Offline mode with cached destinations
- Favorite destinations / trip planner
- Push notifications for service disruptions
- More route segments for all connections
- User location-aware nearest station for Cities/Trips tabs (currently defaults to frankfurt_hbf)
- Localization (German/English)
