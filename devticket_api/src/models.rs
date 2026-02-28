use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Station {
    pub id: String,
    pub name: String,
    pub city: String,
    pub latitude: f64,
    pub longitude: f64,
    pub station_type: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Destination {
    pub id: String,
    pub name: String,
    pub city: String,
    pub state: String,
    pub latitude: f64,
    pub longitude: f64,
    pub description: String,
    pub region: String,
    pub highlights: Vec<String>,
    pub trip_type: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DestinationWithTravel {
    pub id: String,
    pub name: String,
    pub city: String,
    pub state: String,
    pub latitude: f64,
    pub longitude: f64,
    pub description: String,
    pub region: String,
    pub highlights: Vec<String>,
    pub trip_type: String,
    pub travel_time_minutes: i32,
    pub number_of_transfers: i32,
    pub transport_types: Vec<String>,
    pub distance_km: f64,
    pub ice_minutes: Option<i32>,
    pub ice_price_euros: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RouteSegment {
    pub from_station: String,
    pub to_station: String,
    pub transport_type: String,
    pub line: String,
    pub duration_minutes: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RouteDetail {
    pub from_station: Station,
    pub to_destination: Destination,
    pub segments: Vec<RouteSegment>,
    pub total_duration_minutes: i32,
    pub total_transfers: i32,
    pub ice_minutes: Option<i32>,
    pub ice_price_euros: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CoverageInfo {
    pub north: CoveragePoint,
    pub south: CoveragePoint,
    pub east: CoveragePoint,
    pub west: CoveragePoint,
    pub total_cities: i32,
    pub total_connections: i32,
    pub transport_types: Vec<TransportTypeInfo>,
    pub ticket_price: String,
    pub ticket_name: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CoveragePoint {
    pub city: String,
    pub latitude: f64,
    pub longitude: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TransportTypeInfo {
    pub code: String,
    pub name: String,
    pub description: String,
    pub color: String,
}

#[derive(Debug, Deserialize)]
pub struct NearbyQuery {
    pub lat: f64,
    pub lng: f64,
    #[serde(default = "default_radius")]
    pub radius: f64,
}

fn default_radius() -> f64 {
    50.0
}

#[derive(Debug, Deserialize)]
pub struct DestinationsQuery {
    pub lat: f64,
    pub lng: f64,
    #[serde(default = "default_max_minutes")]
    pub max_minutes: i32,
}

fn default_max_minutes() -> i32 {
    240
}

#[derive(Debug, Deserialize)]
pub struct SearchQuery {
    pub q: String,
    #[serde(default)]
    pub lat: f64,
    #[serde(default)]
    pub lng: f64,
}

#[derive(Debug, Deserialize)]
pub struct TripsQuery {
    #[serde(default)]
    pub trip_type: String,
    #[serde(default)]
    pub lat: f64,
    #[serde(default)]
    pub lng: f64,
}
