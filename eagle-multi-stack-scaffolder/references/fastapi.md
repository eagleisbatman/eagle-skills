# FastAPI Reference

## Research Queries
- "FastAPI best practices 2025 2026"
- "FastAPI SQLAlchemy vs SQLModel 2025"
- "FastAPI project structure large applications"
- "Railway FastAPI deployment 2025"
- "MinIO Python S3 integration"

## Package Manager
**uv** - 10-100x faster than pip, proper dependency resolution.

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv init my-api && cd my-api
uv add fastapi "uvicorn[standard]"
```

---

## Database Selection

| Database | Use Case | Driver |
|----------|----------|--------|
| **PostgreSQL** | Production apps, complex queries, ACID | `asyncpg` (async), `psycopg` (sync) |
| **MongoDB** | Document-based, flexible schema | `motor` (async), `pymongo` |
| **SQLite** | Prototyping, embedded, edge | `aiosqlite` |
| **Redis** | Caching, sessions, queues | `redis` (async) |

### When to Use What
- **PostgreSQL**: Default for production. Use with SQLAlchemy or SQLModel.
- **MongoDB**: When you need flexible schemas, document storage.
- **SQLite**: Local development, edge deployments, prototyping.

---

## ORM Selection

| Tool | Philosophy | Best For |
|------|-----------|----------|
| **SQLAlchemy 2.0** | Full-featured, async | Complex apps, full control |
| **SQLModel** | SQLAlchemy + Pydantic | FastAPI integration, simplicity |
| **Tortoise ORM** | Django-like, async-first | Django developers |
| **Beanie** | MongoDB ODM | MongoDB + Pydantic |

### SQLAlchemy vs SQLModel

```python
# SQLAlchemy - More control, more verbose
class User(Base):
    __tablename__ = "users"
    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    email: Mapped[str] = mapped_column(String(255), unique=True)

# SQLModel - Cleaner, Pydantic integrated
class User(SQLModel, table=True):
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    email: str = Field(unique=True, max_length=255)
```

**Choose SQLAlchemy** for: Complex queries, existing SQLAlchemy knowledge, full control
**Choose SQLModel** for: FastAPI projects, cleaner code, Pydantic integration

---

## Database Setup

### PostgreSQL with SQLModel (Recommended)

```bash
uv add sqlmodel asyncpg greenlet
uv add --dev alembic
```

**src/db/models.py:**
```python
from datetime import datetime
from uuid import UUID, uuid4
from sqlmodel import SQLModel, Field, Relationship

class UserBase(SQLModel):
    email: str = Field(unique=True, index=True, max_length=255)
    name: str | None = Field(default=None, max_length=100)
    avatar_url: str | None = None

class User(UserBase, table=True):
    __tablename__ = "users"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    posts: list["Post"] = Relationship(back_populates="author", cascade_delete=True)

class UserCreate(UserBase):
    pass

class UserResponse(UserBase):
    id: UUID
    created_at: datetime

class PostBase(SQLModel):
    title: str = Field(max_length=200)
    content: str | None = None
    published: bool = False

class Post(PostBase, table=True):
    __tablename__ = "posts"

    id: UUID = Field(default_factory=uuid4, primary_key=True)
    author_id: UUID = Field(foreign_key="users.id", index=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    author: User = Relationship(back_populates="posts")
```

**src/db/session.py:**
```python
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlmodel import SQLModel

from src.config import settings

engine = create_async_engine(
    settings.database_url,
    echo=settings.debug,
    pool_size=5,
    max_overflow=10,
    pool_pre_ping=True,
)

AsyncSessionLocal = sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise

async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(SQLModel.metadata.create_all)
```

### PostgreSQL with SQLAlchemy 2.0

**src/db/base.py:**
```python
from datetime import datetime
from uuid import UUID, uuid4
from sqlalchemy import DateTime, String
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

class Base(DeclarativeBase):
    pass

class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )

class User(Base, TimestampMixin):
    __tablename__ = "users"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    name: Mapped[str | None] = mapped_column(String(100))
```

### MongoDB with Beanie

```bash
uv add beanie motor
```

**src/db/models.py:**
```python
from datetime import datetime
from beanie import Document, Indexed
from pydantic import EmailStr

class User(Document):
    email: Indexed(EmailStr, unique=True)
    name: str | None = None
    avatar_url: str | None = None
    created_at: datetime = datetime.utcnow()
    updated_at: datetime = datetime.utcnow()

    class Settings:
        name = "users"
```

**src/db/session.py:**
```python
from beanie import init_beanie
from motor.motor_asyncio import AsyncIOMotorClient

from src.config import settings
from src.db.models import User

async def init_db():
    client = AsyncIOMotorClient(settings.mongodb_url)
    await init_beanie(database=client.myapp, document_models=[User])
```

---

## Object Storage: MinIO

```bash
uv add boto3 python-multipart
```

**src/lib/storage.py:**
```python
import boto3
from botocore.config import Config

from src.config import settings

s3 = boto3.client(
    's3',
    endpoint_url=settings.minio_endpoint,
    aws_access_key_id=settings.minio_access_key,
    aws_secret_access_key=settings.minio_secret_key,
    config=Config(signature_version='s3v4'),
    region_name='us-east-1',
)

BUCKET = settings.minio_bucket

class Storage:
    @staticmethod
    def upload(key: str, data: bytes, content_type: str) -> str:
        s3.put_object(Bucket=BUCKET, Key=key, Body=data, ContentType=content_type)
        return f"{settings.minio_endpoint}/{BUCKET}/{key}"

    @staticmethod
    def get_presigned_upload_url(key: str, content_type: str, expires_in: int = 3600) -> str:
        return s3.generate_presigned_url(
            'put_object',
            Params={'Bucket': BUCKET, 'Key': key, 'ContentType': content_type},
            ExpiresIn=expires_in,
        )

    @staticmethod
    def get_presigned_download_url(key: str, expires_in: int = 3600) -> str:
        return s3.generate_presigned_url(
            'get_object',
            Params={'Bucket': BUCKET, 'Key': key},
            ExpiresIn=expires_in,
        )

    @staticmethod
    def delete(key: str):
        s3.delete_object(Bucket=BUCKET, Key=key)

storage = Storage()
```

**File Upload Endpoint:**
```python
from fastapi import APIRouter, UploadFile, File, HTTPException
from src.lib.storage import storage
import uuid

router = APIRouter(prefix="/files", tags=["files"])

@router.post("/upload")
async def upload_file(file: UploadFile = File(...)):
    if file.size > 10 * 1024 * 1024:  # 10MB limit
        raise HTTPException(400, "File too large")

    key = f"{uuid.uuid4()}-{file.filename}"
    content = await file.read()
    url = storage.upload(key, content, file.content_type)

    return {"url": url, "key": key}
```

---

## Migrations with Alembic

```bash
uv add --dev alembic
uv run alembic init alembic
```

**alembic/env.py:**
```python
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine
from alembic import context
from src.config import settings
from src.db.models import SQLModel  # or Base for SQLAlchemy

config = context.config
target_metadata = SQLModel.metadata

def run_migrations_offline():
    context.configure(url=settings.database_url, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()

def do_run_migrations(connection):
    context.configure(connection=connection, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()

async def run_migrations_online():
    connectable = create_async_engine(settings.database_url)
    async with connectable.connect() as connection:
        await connection.run_sync(do_run_migrations)

if context.is_offline_mode():
    run_migrations_offline()
else:
    asyncio.run(run_migrations_online())
```

**Commands:**
```bash
uv run alembic revision --autogenerate -m "initial"
uv run alembic upgrade head
uv run alembic downgrade -1
```

---

## Project Structure

```
src/
├── main.py                      # Application entry
├── config.py                    # Settings
├── db/
│   ├── __init__.py
│   ├── models.py                # SQLModel/SQLAlchemy models
│   ├── session.py               # Database connection
│   └── seed.py                  # Seed data
├── lib/
│   ├── storage.py               # MinIO client
│   └── security.py              # JWT, hashing
├── api/
│   ├── __init__.py
│   ├── deps.py                  # Shared dependencies
│   └── v1/
│       ├── __init__.py
│       ├── router.py
│       └── endpoints/
│           ├── users.py
│           ├── auth.py
│           └── files.py
├── services/
│   ├── __init__.py
│   └── user_service.py
├── schemas/                     # Pydantic schemas (if not using SQLModel)
└── tests/
alembic/                         # Migrations
```

---

## Essential Libraries

```bash
# Core
uv add fastapi "uvicorn[standard]"

# Database (choose)
uv add sqlmodel asyncpg greenlet           # SQLModel + PostgreSQL
uv add sqlalchemy asyncpg                  # SQLAlchemy + PostgreSQL
uv add beanie motor                        # MongoDB

# Migrations
uv add --dev alembic

# Object Storage
uv add boto3 python-multipart

# Settings
uv add pydantic-settings

# Auth
uv add "python-jose[cryptography]" "passlib[bcrypt]"

# HTTP Client
uv add httpx

# Dev
uv add --dev pytest pytest-asyncio ruff mypy
```

---

## Configuration

**src/config.py:**
```python
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    app_name: str = "My API"
    debug: bool = False

    # Database
    database_url: str  # postgresql+asyncpg://user:pass@host/db

    # MinIO
    minio_endpoint: str | None = None
    minio_access_key: str | None = None
    minio_secret_key: str | None = None
    minio_bucket: str = "uploads"

    # Auth
    secret_key: str
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30

    class Config:
        env_file = ".env"

@lru_cache
def get_settings() -> Settings:
    return Settings()

settings = get_settings()
```

---

## Deployment: Railway

### railway.json
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "uv run uvicorn src.main:app --host 0.0.0.0 --port $PORT",
    "healthcheckPath": "/health",
    "healthcheckTimeout": 30
  }
}
```

### Procfile (Alternative)
```
web: uv run uvicorn src.main:app --host 0.0.0.0 --port $PORT
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

# Set environment variables
railway variables set SECRET_KEY=$(openssl rand -hex 32)
```

### Dockerfile (Alternative)
```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Install uv
RUN pip install uv

# Copy and install dependencies
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen

# Copy source
COPY . .

# Run migrations and start
CMD uv run alembic upgrade head && uv run uvicorn src.main:app --host 0.0.0.0 --port $PORT
```

---

## Code Patterns

### Main Application
```python
# src/main.py
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from src.config import settings
from src.db.session import init_db
from src.api.v1.router import api_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    yield

app = FastAPI(
    title=settings.app_name,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix="/api/v1")

@app.get("/health")
async def health():
    return {"status": "healthy"}
```

### Service Layer
```python
# src/services/user_service.py
from uuid import UUID
from sqlmodel import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.models import User, UserCreate
from src.core.exceptions import NotFoundError, ConflictError

class UserService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_all(self, skip: int = 0, limit: int = 20) -> list[User]:
        result = await self.db.execute(select(User).offset(skip).limit(limit))
        return result.scalars().all()

    async def get_by_id(self, user_id: UUID) -> User:
        result = await self.db.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if not user:
            raise NotFoundError("User not found")
        return user

    async def create(self, data: UserCreate) -> User:
        # Check if email exists
        result = await self.db.execute(select(User).where(User.email == data.email))
        if result.scalar_one_or_none():
            raise ConflictError("Email already exists")

        user = User.model_validate(data)
        self.db.add(user)
        await self.db.flush()
        await self.db.refresh(user)
        return user
```

### API Endpoint
```python
# src/api/v1/endpoints/users.py
from uuid import UUID
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from src.db.session import get_db
from src.db.models import UserCreate, UserResponse
from src.services.user_service import UserService

router = APIRouter(prefix="/users", tags=["users"])

def get_user_service(db: AsyncSession = Depends(get_db)) -> UserService:
    return UserService(db)

@router.get("", response_model=list[UserResponse])
async def list_users(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    service: UserService = Depends(get_user_service),
):
    return await service.get_all(skip=skip, limit=limit)

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(user_id: UUID, service: UserService = Depends(get_user_service)):
    return await service.get_by_id(user_id)

@router.post("", response_model=UserResponse, status_code=201)
async def create_user(data: UserCreate, service: UserService = Depends(get_user_service)):
    return await service.create(data)
```

---

## Setup Commands

```bash
# Create project
uv init my-api && cd my-api

# Add dependencies
uv add fastapi "uvicorn[standard]" sqlmodel asyncpg pydantic-settings
uv add boto3 python-multipart
uv add "python-jose[cryptography]" "passlib[bcrypt]"
uv add --dev alembic pytest pytest-asyncio ruff mypy

# Create structure
mkdir -p src/{db,lib,api/v1/endpoints,services,tests}
touch src/{main.py,config.py,__init__.py}

# Environment
cat > .env << EOF
DATABASE_URL=postgresql+asyncpg://user:pass@localhost/myapp
SECRET_KEY=$(openssl rand -hex 32)
MINIO_ENDPOINT=http://localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
EOF

# Run
uv run uvicorn src.main:app --reload
```

---

## Key Rules

- Use async everywhere - FastAPI is async-first
- Use SQLModel for Pydantic + SQLAlchemy integration
- Use Alembic for migrations, never raw SQL DDL
- Use MinIO for file storage (S3-compatible)
- Deploy to Railway with PostgreSQL addon
- Use dependency injection for services
- Keep endpoints thin, business logic in services
