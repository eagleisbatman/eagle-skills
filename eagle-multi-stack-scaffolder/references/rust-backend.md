# Rust Backend Reference

## Research Queries
- "Rust web framework comparison 2025 2026 Axum Actix"
- "Rust backend best practices 2025"
- "SQLx vs Diesel vs SeaORM 2025"
- "Railway Rust deployment 2025"
- "Rust S3 MinIO integration"

## Package Manager
**Cargo** - Standard Rust package manager.

```bash
cargo new my-api --name my_api
cd my-api
```

## Framework: Axum (Recommended)

Tokio-native, tower ecosystem, modern design, excellent ergonomics.

---

## Database Selection

| Database | Use Case | Crate |
|----------|----------|-------|
| **PostgreSQL** | Production apps, complex queries | `sqlx`, `diesel`, `sea-orm` |
| **SQLite** | Embedded, local-first, edge | `sqlx`, `rusqlite` |
| **MongoDB** | Document-based | `mongodb` |
| **Redis** | Caching, sessions | `redis`, `deadpool-redis` |

---

## ORM/Query Builder Selection

| Tool | Philosophy | Best For |
|------|-----------|----------|
| **SQLx** | Compile-time verified SQL | SQL control, performance |
| **Diesel** | Type-safe ORM | Schema-first, compile-time safety |
| **SeaORM** | ActiveRecord-style | Rapid development, migrations |

### Comparison

```rust
// SQLx - Raw SQL, compile-time checked
let user = sqlx::query_as!(User,
    "SELECT * FROM users WHERE id = $1", id
).fetch_one(&pool).await?;

// Diesel - DSL, schema.rs generated
let user = users::table
    .filter(users::id.eq(id))
    .first::<User>(&mut conn)?;

// SeaORM - ActiveRecord style
let user = User::find_by_id(id)
    .one(&db)
    .await?;
```

**Choose SQLx** for: Performance, SQL control, compile-time verification
**Choose Diesel** for: Type safety, complex queries, schema-first
**Choose SeaORM** for: Rapid development, async-first, migrations

---

## Database Setup

### PostgreSQL with SQLx (Recommended)

**Cargo.toml:**
```toml
[dependencies]
sqlx = { version = "0.8", features = ["runtime-tokio", "postgres", "uuid", "chrono"] }
tokio = { version = "1", features = ["full"] }
uuid = { version = "1", features = ["v4", "serde"] }
chrono = { version = "0.4", features = ["serde"] }
```

**src/db/mod.rs:**
```rust
use sqlx::{postgres::PgPoolOptions, PgPool};
use std::time::Duration;

pub async fn create_pool(database_url: &str) -> Result<PgPool, sqlx::Error> {
    PgPoolOptions::new()
        .max_connections(10)
        .acquire_timeout(Duration::from_secs(3))
        .connect(database_url)
        .await
}
```

**src/models/user.rs:**
```rust
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;
use uuid::Uuid;

#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct User {
    pub id: Uuid,
    pub email: String,
    pub name: Option<String>,
    pub avatar_url: Option<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Deserialize)]
pub struct CreateUser {
    pub email: String,
    pub name: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateUser {
    pub name: Option<String>,
    pub avatar_url: Option<String>,
}
```

**src/repositories/user.rs:**
```rust
use sqlx::PgPool;
use uuid::Uuid;
use crate::models::user::{User, CreateUser, UpdateUser};
use crate::error::AppError;

pub struct UserRepository;

impl UserRepository {
    pub async fn find_all(pool: &PgPool, limit: i64, offset: i64) -> Result<Vec<User>, AppError> {
        let users = sqlx::query_as!(
            User,
            r#"SELECT * FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2"#,
            limit, offset
        )
        .fetch_all(pool)
        .await?;
        Ok(users)
    }

    pub async fn find_by_id(pool: &PgPool, id: Uuid) -> Result<Option<User>, AppError> {
        let user = sqlx::query_as!(
            User,
            r#"SELECT * FROM users WHERE id = $1"#,
            id
        )
        .fetch_optional(pool)
        .await?;
        Ok(user)
    }

    pub async fn find_by_email(pool: &PgPool, email: &str) -> Result<Option<User>, AppError> {
        let user = sqlx::query_as!(
            User,
            r#"SELECT * FROM users WHERE email = $1"#,
            email
        )
        .fetch_optional(pool)
        .await?;
        Ok(user)
    }

    pub async fn create(pool: &PgPool, input: CreateUser) -> Result<User, AppError> {
        let user = sqlx::query_as!(
            User,
            r#"
            INSERT INTO users (id, email, name, created_at, updated_at)
            VALUES ($1, $2, $3, NOW(), NOW())
            RETURNING *
            "#,
            Uuid::new_v4(),
            input.email,
            input.name,
        )
        .fetch_one(pool)
        .await?;
        Ok(user)
    }

    pub async fn update(pool: &PgPool, id: Uuid, input: UpdateUser) -> Result<User, AppError> {
        let user = sqlx::query_as!(
            User,
            r#"
            UPDATE users
            SET name = COALESCE($2, name),
                avatar_url = COALESCE($3, avatar_url),
                updated_at = NOW()
            WHERE id = $1
            RETURNING *
            "#,
            id,
            input.name,
            input.avatar_url,
        )
        .fetch_one(pool)
        .await?;
        Ok(user)
    }

    pub async fn delete(pool: &PgPool, id: Uuid) -> Result<(), AppError> {
        sqlx::query!("DELETE FROM users WHERE id = $1", id)
            .execute(pool)
            .await?;
        Ok(())
    }
}
```

### SeaORM Setup

**Cargo.toml:**
```toml
[dependencies]
sea-orm = { version = "1.0", features = ["runtime-tokio-native-tls", "sqlx-postgres"] }
```

---

## Object Storage: MinIO

**Cargo.toml:**
```toml
[dependencies]
aws-sdk-s3 = "1"
aws-config = "1"
```

**src/lib/storage.rs:**
```rust
use aws_sdk_s3::{Client, config::{Region, Credentials, Builder}};
use aws_sdk_s3::primitives::ByteStream;
use crate::config::Settings;
use crate::error::AppError;

pub struct Storage {
    client: Client,
    bucket: String,
    endpoint: String,
}

impl Storage {
    pub fn new(settings: &Settings) -> Self {
        let credentials = Credentials::new(
            &settings.minio_access_key,
            &settings.minio_secret_key,
            None, None, "minio"
        );

        let config = Builder::new()
            .region(Region::new("us-east-1"))
            .endpoint_url(&settings.minio_endpoint)
            .credentials_provider(credentials)
            .force_path_style(true)
            .build();

        let client = Client::from_conf(config);

        Self {
            client,
            bucket: settings.minio_bucket.clone(),
            endpoint: settings.minio_endpoint.clone(),
        }
    }

    pub async fn upload(&self, key: &str, data: Vec<u8>, content_type: &str) -> Result<String, AppError> {
        self.client
            .put_object()
            .bucket(&self.bucket)
            .key(key)
            .body(ByteStream::from(data))
            .content_type(content_type)
            .send()
            .await
            .map_err(|e| AppError::Internal(e.into()))?;

        Ok(format!("{}/{}/{}", self.endpoint, self.bucket, key))
    }

    pub async fn get_presigned_url(&self, key: &str, expires_in: u64) -> Result<String, AppError> {
        let presigning_config = aws_sdk_s3::presigning::PresigningConfig::expires_in(
            std::time::Duration::from_secs(expires_in)
        ).map_err(|e| AppError::Internal(e.into()))?;

        let url = self.client
            .get_object()
            .bucket(&self.bucket)
            .key(key)
            .presigned(presigning_config)
            .await
            .map_err(|e| AppError::Internal(e.into()))?
            .uri()
            .to_string();

        Ok(url)
    }

    pub async fn delete(&self, key: &str) -> Result<(), AppError> {
        self.client
            .delete_object()
            .bucket(&self.bucket)
            .key(key)
            .send()
            .await
            .map_err(|e| AppError::Internal(e.into()))?;
        Ok(())
    }
}
```

---

## Migrations

### SQLx Migrations
```bash
# Install sqlx-cli
cargo install sqlx-cli

# Create migration
sqlx migrate add initial

# Run migrations
sqlx migrate run

# Revert
sqlx migrate revert
```

**migrations/20240101000000_initial.sql:**
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100),
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);

CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    content TEXT,
    published BOOLEAN NOT NULL DEFAULT FALSE,
    author_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_posts_author ON posts(author_id);
```

---

## Project Structure

```
src/
├── main.rs                     # Entry point
├── lib.rs                      # Library exports
├── config/
│   ├── mod.rs
│   └── settings.rs             # Configuration
├── api/
│   ├── mod.rs
│   ├── routes.rs               # Router setup
│   └── handlers/
│       ├── mod.rs
│       ├── users.rs
│       └── files.rs
├── models/
│   ├── mod.rs
│   └── user.rs
├── repositories/
│   ├── mod.rs
│   └── user.rs
├── services/
│   ├── mod.rs
│   └── user.rs
├── lib/
│   ├── mod.rs
│   └── storage.rs              # MinIO client
├── error.rs                    # Error types
└── middleware/
    ├── mod.rs
    └── auth.rs
migrations/
tests/
Cargo.toml
```

---

## Cargo.toml

```toml
[package]
name = "my-api"
version = "0.1.0"
edition = "2021"

[dependencies]
# Web framework
axum = { version = "0.7", features = ["multipart"] }
tokio = { version = "1", features = ["full"] }
tower = "0.4"
tower-http = { version = "0.5", features = ["cors", "trace", "compression-gzip"] }

# Serialization
serde = { version = "1", features = ["derive"] }
serde_json = "1"

# Database
sqlx = { version = "0.8", features = ["runtime-tokio", "postgres", "uuid", "chrono"] }

# Object Storage
aws-sdk-s3 = "1"
aws-config = "1"

# Auth
jsonwebtoken = "9"
argon2 = "0.5"

# Utilities
uuid = { version = "1", features = ["v4", "serde"] }
chrono = { version = "0.4", features = ["serde"] }
thiserror = "1"
anyhow = "1"

# Logging
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }

# Config
dotenvy = "0.15"

[dev-dependencies]
tokio-test = "0.4"
```

---

## Deployment: Railway

### railway.json
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "DOCKERFILE"
  },
  "deploy": {
    "healthcheckPath": "/health",
    "healthcheckTimeout": 30
  }
}
```

### Dockerfile
```dockerfile
# Build stage
FROM rust:1.75 AS builder

WORKDIR /app
COPY . .

# Build release binary
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/target/release/my-api /app/my-api
COPY --from=builder /app/migrations /app/migrations

ENV PORT=3000
EXPOSE 3000

CMD ["./my-api"]
```

### Deploy Commands
```bash
# Install Railway CLI
npm install -g @railway/cli

railway login
railway init
railway up

# Add PostgreSQL
railway add -d postgresql
```

---

## Code Patterns

### Configuration
```rust
// src/config/settings.rs
use serde::Deserialize;

#[derive(Debug, Clone, Deserialize)]
pub struct Settings {
    pub database_url: String,
    pub port: u16,
    pub jwt_secret: String,
    pub minio_endpoint: String,
    pub minio_access_key: String,
    pub minio_secret_key: String,
    pub minio_bucket: String,
}

impl Settings {
    pub fn from_env() -> Result<Self, envy::Error> {
        dotenvy::dotenv().ok();
        envy::from_env()
    }
}
```

### Error Handling
```rust
// src/error.rs
use axum::{http::StatusCode, response::{IntoResponse, Response}, Json};
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("Not found: {0}")]
    NotFound(String),

    #[error("Bad request: {0}")]
    BadRequest(String),

    #[error("Conflict: {0}")]
    Conflict(String),

    #[error("Unauthorized")]
    Unauthorized,

    #[error("Database error")]
    Database(#[from] sqlx::Error),

    #[error("Internal error")]
    Internal(#[from] anyhow::Error),
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, message) = match &self {
            AppError::NotFound(msg) => (StatusCode::NOT_FOUND, msg.clone()),
            AppError::BadRequest(msg) => (StatusCode::BAD_REQUEST, msg.clone()),
            AppError::Conflict(msg) => (StatusCode::CONFLICT, msg.clone()),
            AppError::Unauthorized => (StatusCode::UNAUTHORIZED, "Unauthorized".into()),
            AppError::Database(_) => (StatusCode::INTERNAL_SERVER_ERROR, "Database error".into()),
            AppError::Internal(_) => (StatusCode::INTERNAL_SERVER_ERROR, "Internal error".into()),
        };

        (status, Json(serde_json::json!({ "error": message }))).into_response()
    }
}
```

### Router
```rust
// src/api/routes.rs
use axum::{routing::{get, post, patch, delete}, Router};
use sqlx::PgPool;
use tower_http::{cors::CorsLayer, trace::TraceLayer, compression::CompressionLayer};
use crate::api::handlers::{users, files};
use crate::lib::storage::Storage;
use std::sync::Arc;

#[derive(Clone)]
pub struct AppState {
    pub pool: PgPool,
    pub storage: Arc<Storage>,
}

pub fn create_router(state: AppState) -> Router {
    Router::new()
        .route("/health", get(|| async { "ok" }))
        .nest("/api/v1", api_routes())
        .with_state(state)
        .layer(TraceLayer::new_for_http())
        .layer(CompressionLayer::new())
        .layer(CorsLayer::permissive())
}

fn api_routes() -> Router<AppState> {
    Router::new()
        .route("/users", get(users::list).post(users::create))
        .route("/users/:id", get(users::get_by_id).patch(users::update).delete(users::delete))
        .route("/files/upload", post(files::upload))
}
```

### Handler
```rust
// src/api/handlers/users.rs
use axum::{extract::{Path, Query, State}, Json};
use uuid::Uuid;
use crate::api::routes::AppState;
use crate::error::AppError;
use crate::models::user::{User, CreateUser, UpdateUser};
use crate::repositories::user::UserRepository;

#[derive(Debug, serde::Deserialize)]
pub struct ListQuery {
    #[serde(default = "default_limit")]
    pub limit: i64,
    #[serde(default)]
    pub offset: i64,
}

fn default_limit() -> i64 { 20 }

pub async fn list(
    State(state): State<AppState>,
    Query(query): Query<ListQuery>,
) -> Result<Json<Vec<User>>, AppError> {
    let users = UserRepository::find_all(&state.pool, query.limit, query.offset).await?;
    Ok(Json(users))
}

pub async fn get_by_id(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
) -> Result<Json<User>, AppError> {
    let user = UserRepository::find_by_id(&state.pool, id)
        .await?
        .ok_or_else(|| AppError::NotFound("User not found".into()))?;
    Ok(Json(user))
}

pub async fn create(
    State(state): State<AppState>,
    Json(input): Json<CreateUser>,
) -> Result<Json<User>, AppError> {
    // Check if email exists
    if UserRepository::find_by_email(&state.pool, &input.email).await?.is_some() {
        return Err(AppError::Conflict("Email already exists".into()));
    }

    let user = UserRepository::create(&state.pool, input).await?;
    Ok(Json(user))
}

pub async fn update(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
    Json(input): Json<UpdateUser>,
) -> Result<Json<User>, AppError> {
    let user = UserRepository::update(&state.pool, id, input).await?;
    Ok(Json(user))
}

pub async fn delete(
    State(state): State<AppState>,
    Path(id): Path<Uuid>,
) -> Result<(), AppError> {
    UserRepository::delete(&state.pool, id).await?;
    Ok(())
}
```

### Main
```rust
// src/main.rs
use std::sync::Arc;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};

mod api;
mod config;
mod db;
mod error;
mod lib;
mod models;
mod repositories;

use crate::api::routes::{create_router, AppState};
use crate::config::settings::Settings;
use crate::db::create_pool;
use crate::lib::storage::Storage;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing
    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::new(
            std::env::var("RUST_LOG").unwrap_or_else(|_| "info".into())
        ))
        .with(tracing_subscriber::fmt::layer())
        .init();

    // Load config
    let settings = Settings::from_env()?;

    // Database
    let pool = create_pool(&settings.database_url).await?;
    sqlx::migrate!().run(&pool).await?;

    // Storage
    let storage = Arc::new(Storage::new(&settings));

    // App state
    let state = AppState { pool, storage };

    // Router
    let app = create_router(state);

    // Start server
    let addr = format!("0.0.0.0:{}", settings.port);
    let listener = tokio::net::TcpListener::bind(&addr).await?;
    tracing::info!("Server running on {}", addr);
    axum::serve(listener, app).await?;

    Ok(())
}
```

---

## Setup Commands

```bash
# Create project
cargo new my-api && cd my-api

# Add dependencies (edit Cargo.toml)

# Install sqlx-cli
cargo install sqlx-cli

# Database setup
export DATABASE_URL="postgresql://user:pass@localhost/myapp"
sqlx database create
sqlx migrate add initial
# Edit migration file
sqlx migrate run

# Environment
cat > .env << EOF
DATABASE_URL=postgresql://user:pass@localhost/myapp
PORT=3000
JWT_SECRET=$(openssl rand -hex 32)
MINIO_ENDPOINT=http://localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET=uploads
EOF

# Run
cargo run

# Watch mode
cargo install cargo-watch
cargo watch -x run
```

---

## Key Rules

- Use SQLx for compile-time verified SQL queries
- Use Axum with tower middleware ecosystem
- Use proper error handling with thiserror
- Use connection pooling (sqlx handles this)
- Run migrations on startup for simplicity
- Use Docker for Railway deployment
- Use MinIO for S3-compatible object storage
