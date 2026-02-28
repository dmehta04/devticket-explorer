use axum::{routing::get, Router};
use rusqlite::Connection;
use std::sync::{Arc, Mutex};
use tower_http::cors::CorsLayer;

mod db;
mod geo;
mod handlers;
mod models;

#[derive(Clone)]
pub struct AppState {
    pub db: Arc<Mutex<Connection>>,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "devticket_api=info".into()),
        )
        .init();

    let conn = Connection::open("devticket.db")?;
    conn.execute_batch("PRAGMA journal_mode=WAL; PRAGMA foreign_keys=ON;")?;
    db::initialize(&conn)?;

    let state = AppState {
        db: Arc::new(Mutex::new(conn)),
    };

    let app = Router::new()
        .route("/api/v1/health", get(handlers::health))
        .route("/api/v1/stations/nearby", get(handlers::get_nearby_stations))
        .route("/api/v1/destinations/all", get(handlers::get_all_destinations))
        .route("/api/v1/destinations/search", get(handlers::search_destinations))
        .route("/api/v1/destinations", get(handlers::get_destinations))
        .route("/api/v1/routes/:from_id/:to_id", get(handlers::get_route_detail))
        .route("/api/v1/coverage", get(handlers::get_coverage))
        .route("/api/v1/trips", get(handlers::get_featured_trips))
        .layer(CorsLayer::permissive())
        .with_state(state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:8090").await?;
    tracing::info!("Devticket API server listening on {}", listener.local_addr()?);

    axum::serve(listener, app).await?;

    Ok(())
}
