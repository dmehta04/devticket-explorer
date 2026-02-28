use axum::{
    extract::{Path, Query, State},
    http::StatusCode,
    Json,
};
use crate::geo::haversine_km;
use crate::models::*;
use crate::AppState;

pub async fn health() -> &'static str {
    "OK"
}

pub async fn get_nearby_stations(
    State(state): State<AppState>,
    Query(params): Query<NearbyQuery>,
) -> Result<Json<Vec<Station>>, (StatusCode, String)> {
    let conn = state.db.lock().map_err(|e| {
        (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
    })?;

    let mut stmt = conn
        .prepare("SELECT id, name, city, latitude, longitude, station_type FROM stations")
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    let stations: Vec<Station> = stmt
        .query_map([], |row| {
            Ok(Station {
                id: row.get(0)?,
                name: row.get(1)?,
                city: row.get(2)?,
                latitude: row.get(3)?,
                longitude: row.get(4)?,
                station_type: row.get(5)?,
            })
        })
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .filter_map(|s| s.ok())
        .filter(|s| haversine_km(params.lat, params.lng, s.latitude, s.longitude) <= params.radius)
        .collect();

    Ok(Json(stations))
}

pub async fn get_destinations(
    State(state): State<AppState>,
    Query(params): Query<DestinationsQuery>,
) -> Result<Json<Vec<DestinationWithTravel>>, (StatusCode, String)> {
    let conn = state.db.lock().map_err(|e| {
        (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
    })?;

    let mut stmt = conn
        .prepare("SELECT id, name, city, latitude, longitude, station_type FROM stations")
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    let nearest_station: Option<Station> = stmt
        .query_map([], |row| {
            Ok(Station {
                id: row.get(0)?,
                name: row.get(1)?,
                city: row.get(2)?,
                latitude: row.get(3)?,
                longitude: row.get(4)?,
                station_type: row.get(5)?,
            })
        })
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .filter_map(|s| s.ok())
        .min_by(|a, b| {
            let da = haversine_km(params.lat, params.lng, a.latitude, a.longitude);
            let db = haversine_km(params.lat, params.lng, b.latitude, b.longitude);
            da.partial_cmp(&db).unwrap_or(std::cmp::Ordering::Equal)
        });

    let station = match nearest_station {
        Some(s) => s,
        None => return Ok(Json(vec![])),
    };

    let mut stmt = conn
        .prepare(
            "SELECT d.id, d.name, d.city, d.state, d.latitude, d.longitude, d.description,
                    d.region, d.highlights, d.trip_type,
                    c.travel_time_minutes, c.number_of_transfers, c.transport_types,
                    c.ice_minutes, c.ice_price_euros
             FROM destinations d
             JOIN connections c ON d.id = c.to_destination_id
             WHERE c.from_station_id = ?1 AND c.travel_time_minutes <= ?2
             ORDER BY c.travel_time_minutes ASC",
        )
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    let destinations: Vec<DestinationWithTravel> = stmt
        .query_map(
            rusqlite::params![station.id, params.max_minutes],
            |row| {
                let types_str: String = row.get(12)?;
                let transport_types: Vec<String> =
                    serde_json::from_str(&types_str).unwrap_or_default();
                let highlights_str: String = row.get(8)?;
                let highlights: Vec<String> =
                    serde_json::from_str(&highlights_str).unwrap_or_default();
                let lat: f64 = row.get(4)?;
                let lng: f64 = row.get(5)?;
                Ok(DestinationWithTravel {
                    id: row.get(0)?,
                    name: row.get(1)?,
                    city: row.get(2)?,
                    state: row.get(3)?,
                    latitude: lat,
                    longitude: lng,
                    description: row.get(6)?,
                    region: row.get(7)?,
                    highlights,
                    trip_type: row.get(9)?,
                    travel_time_minutes: row.get(10)?,
                    number_of_transfers: row.get(11)?,
                    transport_types,
                    distance_km: haversine_km(params.lat, params.lng, lat, lng),
                    ice_minutes: row.get(13)?,
                    ice_price_euros: row.get(14)?,
                })
            },
        )
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .filter_map(|d| d.ok())
        .collect();

    Ok(Json(destinations))
}

pub async fn search_destinations(
    State(state): State<AppState>,
    Query(params): Query<SearchQuery>,
) -> Result<Json<Vec<DestinationWithTravel>>, (StatusCode, String)> {
    let conn = state.db.lock().map_err(|e| {
        (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
    })?;

    let search_term = format!("%{}%", params.q.to_lowercase());

    let mut stmt = conn
        .prepare(
            "SELECT d.id, d.name, d.city, d.state, d.latitude, d.longitude, d.description,
                    d.region, d.highlights, d.trip_type,
                    c.travel_time_minutes, c.number_of_transfers, c.transport_types,
                    c.ice_minutes, c.ice_price_euros
             FROM destinations d
             LEFT JOIN connections c ON d.id = c.to_destination_id
             WHERE LOWER(d.name) LIKE ?1 OR LOWER(d.city) LIKE ?1 OR LOWER(d.description) LIKE ?1
             ORDER BY c.travel_time_minutes ASC
             LIMIT 20",
        )
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    let destinations: Vec<DestinationWithTravel> = stmt
        .query_map(rusqlite::params![search_term], |row| {
            let types_str: Option<String> = row.get(12)?;
            let transport_types: Vec<String> = types_str
                .and_then(|s| serde_json::from_str(&s).ok())
                .unwrap_or_default();
            let highlights_str: String = row.get::<_, Option<String>>(8)?.unwrap_or_else(|| "[]".to_string());
            let highlights: Vec<String> =
                serde_json::from_str(&highlights_str).unwrap_or_default();
            let lat: f64 = row.get(4)?;
            let lng: f64 = row.get(5)?;
            Ok(DestinationWithTravel {
                id: row.get(0)?,
                name: row.get(1)?,
                city: row.get(2)?,
                state: row.get(3)?,
                latitude: lat,
                longitude: lng,
                description: row.get(6)?,
                region: row.get::<_, Option<String>>(7)?.unwrap_or_default(),
                highlights,
                trip_type: row.get::<_, Option<String>>(9)?.unwrap_or_default(),
                travel_time_minutes: row.get::<_, Option<i32>>(10)?.unwrap_or(0),
                number_of_transfers: row.get::<_, Option<i32>>(11)?.unwrap_or(0),
                transport_types,
                distance_km: haversine_km(params.lat, params.lng, lat, lng),
                ice_minutes: row.get(13)?,
                ice_price_euros: row.get(14)?,
            })
        })
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .filter_map(|d| d.ok())
        .collect();

    Ok(Json(destinations))
}

pub async fn get_route_detail(
    State(state): State<AppState>,
    Path((from_id, to_id)): Path<(String, String)>,
) -> Result<Json<RouteDetail>, (StatusCode, String)> {
    let conn = state.db.lock().map_err(|e| {
        (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
    })?;

    let station: Station = conn
        .query_row(
            "SELECT id, name, city, latitude, longitude, station_type FROM stations WHERE id = ?1",
            rusqlite::params![from_id],
            |row| {
                Ok(Station {
                    id: row.get(0)?,
                    name: row.get(1)?,
                    city: row.get(2)?,
                    latitude: row.get(3)?,
                    longitude: row.get(4)?,
                    station_type: row.get(5)?,
                })
            },
        )
        .map_err(|e| (StatusCode::NOT_FOUND, format!("Station not found: {}", e)))?;

    let destination: Destination = conn
        .query_row(
            "SELECT id, name, city, state, latitude, longitude, description, region, highlights, trip_type FROM destinations WHERE id = ?1",
            rusqlite::params![to_id],
            |row| {
                let highlights_str: String = row.get(8)?;
                let highlights: Vec<String> =
                    serde_json::from_str(&highlights_str).unwrap_or_default();
                Ok(Destination {
                    id: row.get(0)?,
                    name: row.get(1)?,
                    city: row.get(2)?,
                    state: row.get(3)?,
                    latitude: row.get(4)?,
                    longitude: row.get(5)?,
                    description: row.get(6)?,
                    region: row.get(7)?,
                    highlights,
                    trip_type: row.get(9)?,
                })
            },
        )
        .map_err(|e| (StatusCode::NOT_FOUND, format!("Destination not found: {}", e)))?;

    let (total_duration, total_transfers, ice_minutes, ice_price_euros): (i32, i32, Option<i32>, Option<f64>) = conn
        .query_row(
            "SELECT travel_time_minutes, number_of_transfers, ice_minutes, ice_price_euros FROM connections WHERE from_station_id = ?1 AND to_destination_id = ?2",
            rusqlite::params![from_id, to_id],
            |row| Ok((row.get(0)?, row.get(1)?, row.get(2)?, row.get(3)?)),
        )
        .map_err(|e| (StatusCode::NOT_FOUND, format!("Connection not found: {}", e)))?;

    let mut stmt = conn
        .prepare(
            "SELECT from_stop, to_stop, transport_type, line, duration_minutes
             FROM route_segments
             WHERE from_station_id = ?1 AND to_destination_id = ?2
             ORDER BY sequence_order ASC",
        )
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    let segments: Vec<RouteSegment> = stmt
        .query_map(rusqlite::params![from_id, to_id], |row| {
            Ok(RouteSegment {
                from_station: row.get(0)?,
                to_station: row.get(1)?,
                transport_type: row.get(2)?,
                line: row.get(3)?,
                duration_minutes: row.get(4)?,
            })
        })
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .filter_map(|s| s.ok())
        .collect();

    Ok(Json(RouteDetail {
        from_station: station,
        to_destination: destination,
        segments,
        total_duration_minutes: total_duration,
        total_transfers,
        ice_minutes,
        ice_price_euros,
    }))
}

pub async fn get_all_destinations(
    State(state): State<AppState>,
) -> Result<Json<Vec<DestinationWithTravel>>, (StatusCode, String)> {
    let conn = state.db.lock().map_err(|e| {
        (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
    })?;

    let mut stmt = conn
        .prepare(
            "SELECT id, name, city, state, latitude, longitude, description, region, highlights, trip_type
             FROM destinations
             ORDER BY region, name",
        )
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    let destinations: Vec<DestinationWithTravel> = stmt
        .query_map([], |row| {
            let highlights_str: String = row.get(8)?;
            let highlights: Vec<String> =
                serde_json::from_str(&highlights_str).unwrap_or_default();
            let lat: f64 = row.get(4)?;
            let lng: f64 = row.get(5)?;
            Ok(DestinationWithTravel {
                id: row.get(0)?,
                name: row.get(1)?,
                city: row.get(2)?,
                state: row.get(3)?,
                latitude: lat,
                longitude: lng,
                description: row.get(6)?,
                region: row.get(7)?,
                highlights,
                trip_type: row.get(9)?,
                travel_time_minutes: 0,
                number_of_transfers: 0,
                transport_types: vec![],
                distance_km: 0.0,
                ice_minutes: None,
                ice_price_euros: None,
            })
        })
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .filter_map(|d| d.ok())
        .collect();

    Ok(Json(destinations))
}

pub async fn get_coverage(
) -> Json<CoverageInfo> {
    Json(CoverageInfo {
        north: CoveragePoint {
            city: "Kiel / Stralsund".to_string(),
            latitude: 54.32,
            longitude: 10.13,
        },
        south: CoveragePoint {
            city: "Garmisch-Partenkirchen / Konstanz".to_string(),
            latitude: 47.49,
            longitude: 11.10,
        },
        east: CoveragePoint {
            city: "Dresden / Passau".to_string(),
            latitude: 51.05,
            longitude: 13.74,
        },
        west: CoveragePoint {
            city: "Aachen / Trier".to_string(),
            latitude: 50.77,
            longitude: 6.09,
        },
        total_cities: 52,
        total_connections: 110,
        transport_types: vec![
            TransportTypeInfo {
                code: "RE".to_string(),
                name: "Regional Express".to_string(),
                description: "Fast regional trains connecting major cities. Stops at larger stations only.".to_string(),
                color: "#1B5E20".to_string(),
            },
            TransportTypeInfo {
                code: "RB".to_string(),
                name: "Regionalbahn".to_string(),
                description: "Local regional trains stopping at all stations. Great for short scenic routes.".to_string(),
                color: "#2E7D32".to_string(),
            },
            TransportTypeInfo {
                code: "S_BAHN".to_string(),
                name: "S-Bahn".to_string(),
                description: "Suburban rail running frequently within city regions. High frequency, short distances.".to_string(),
                color: "#388E3C".to_string(),
            },
            TransportTypeInfo {
                code: "U_BAHN".to_string(),
                name: "U-Bahn".to_string(),
                description: "Metro/underground in major cities (Berlin, Munich, Hamburg, etc). Fastest in-city travel.".to_string(),
                color: "#1565C0".to_string(),
            },
            TransportTypeInfo {
                code: "TRAM".to_string(),
                name: "Tram / Straßenbahn".to_string(),
                description: "Street trams in many German cities. Scenic and convenient for inner-city trips.".to_string(),
                color: "#C62828".to_string(),
            },
            TransportTypeInfo {
                code: "BUS".to_string(),
                name: "Bus".to_string(),
                description: "City and regional buses covering areas without rail. Connects to smaller towns and attractions.".to_string(),
                color: "#6A1B9A".to_string(),
            },
        ],
        ticket_price: "63".to_string(),
        ticket_name: "Deutschlandticket".to_string(),
    })
}

pub async fn get_featured_trips(
    State(state): State<AppState>,
    Query(params): Query<TripsQuery>,
) -> Result<Json<Vec<DestinationWithTravel>>, (StatusCode, String)> {
    let conn = state.db.lock().map_err(|e| {
        (StatusCode::INTERNAL_SERVER_ERROR, e.to_string())
    })?;

    let query = if params.trip_type.is_empty() {
        "SELECT id, name, city, state, latitude, longitude, description, region, highlights, trip_type
         FROM destinations
         ORDER BY trip_type, name"
    } else {
        "SELECT id, name, city, state, latitude, longitude, description, region, highlights, trip_type
         FROM destinations
         WHERE trip_type = ?1
         ORDER BY name"
    };

    let mut stmt = conn.prepare(query)
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?;

    let destinations: Vec<DestinationWithTravel> = if params.trip_type.is_empty() {
        stmt.query_map([], |row| {
            let highlights_str: String = row.get(8)?;
            let highlights: Vec<String> =
                serde_json::from_str(&highlights_str).unwrap_or_default();
            let lat: f64 = row.get(4)?;
            let lng: f64 = row.get(5)?;
            Ok(DestinationWithTravel {
                id: row.get(0)?,
                name: row.get(1)?,
                city: row.get(2)?,
                state: row.get(3)?,
                latitude: lat,
                longitude: lng,
                description: row.get(6)?,
                region: row.get(7)?,
                highlights,
                trip_type: row.get(9)?,
                travel_time_minutes: 0,
                number_of_transfers: 0,
                transport_types: vec![],
                distance_km: if params.lat != 0.0 { haversine_km(params.lat, params.lng, lat, lng) } else { 0.0 },
                ice_minutes: None,
                ice_price_euros: None,
            })
        })
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .filter_map(|d| d.ok())
        .collect()
    } else {
        stmt.query_map(rusqlite::params![params.trip_type], |row| {
            let highlights_str: String = row.get(8)?;
            let highlights: Vec<String> =
                serde_json::from_str(&highlights_str).unwrap_or_default();
            let lat: f64 = row.get(4)?;
            let lng: f64 = row.get(5)?;
            Ok(DestinationWithTravel {
                id: row.get(0)?,
                name: row.get(1)?,
                city: row.get(2)?,
                state: row.get(3)?,
                latitude: lat,
                longitude: lng,
                description: row.get(6)?,
                region: row.get(7)?,
                highlights,
                trip_type: row.get(9)?,
                travel_time_minutes: 0,
                number_of_transfers: 0,
                transport_types: vec![],
                distance_km: if params.lat != 0.0 { haversine_km(params.lat, params.lng, lat, lng) } else { 0.0 },
                ice_minutes: None,
                ice_price_euros: None,
            })
        })
        .map_err(|e| (StatusCode::INTERNAL_SERVER_ERROR, e.to_string()))?
        .filter_map(|d| d.ok())
        .collect()
    };

    Ok(Json(destinations))
}
