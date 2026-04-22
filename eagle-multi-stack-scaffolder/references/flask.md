# Flask Reference

## Research Queries
- "Flask best practices 2025 2026"
- "Flask SQLAlchemy 2.0 setup"
- "Flask application factory pattern"
- "Railway Flask deployment 2025"
- "Flask vs FastAPI 2025"

## Package Manager
**uv** - 10-100x faster than pip.

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv init my-api && cd my-api
uv add flask
```

## When to Choose Flask

- Simple APIs or microservices
- Prototyping and MVPs
- When you want full control over architecture
- Lightweight applications
- Synchronous workloads

**Note**: For async APIs, consider FastAPI instead.

---

## Database Selection

| Database | Use Case | Driver |
|----------|----------|--------|
| **PostgreSQL** | Production apps, complex queries | `psycopg2-binary`, `psycopg` |
| **MongoDB** | Document-based, flexible schema | `pymongo`, `flask-pymongo` |
| **SQLite** | Prototyping, embedded, small apps | Built-in |
| **Redis** | Caching, sessions | `redis`, `flask-caching` |

---

## ORM Selection

| Tool | Philosophy | Best For |
|------|-----------|----------|
| **Flask-SQLAlchemy** | Flask + SQLAlchemy integration | Most Flask apps |
| **SQLAlchemy 2.0** | Direct, more control | Advanced use cases |
| **Flask-PyMongo** | MongoDB integration | Document databases |

---

## Database Setup

### PostgreSQL with Flask-SQLAlchemy

```bash
uv add flask-sqlalchemy psycopg2-binary flask-migrate
```

**app/extensions.py:**
```python
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_bcrypt import Bcrypt
from flask_cors import CORS
from flask_marshmallow import Marshmallow

db = SQLAlchemy()
migrate = Migrate()
bcrypt = Bcrypt()
cors = CORS()
ma = Marshmallow()
```

**app/models/base.py:**
```python
from datetime import datetime
import uuid
from app.extensions import db

class BaseModel(db.Model):
    __abstract__ = True

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)

    def save(self):
        db.session.add(self)
        db.session.commit()
        return self

    def delete(self):
        db.session.delete(self)
        db.session.commit()
```

**app/models/user.py:**
```python
from app.models.base import BaseModel
from app.extensions import db

class User(BaseModel):
    __tablename__ = "users"

    email = db.Column(db.String(255), unique=True, nullable=False, index=True)
    name = db.Column(db.String(100))
    password_hash = db.Column(db.String(255))
    avatar_url = db.Column(db.String(500))

    posts = db.relationship("Post", backref="author", lazy="dynamic", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<User {self.email}>"
```

### MongoDB with Flask-PyMongo

```bash
uv add flask-pymongo
```

**app/extensions.py:**
```python
from flask_pymongo import PyMongo

mongo = PyMongo()
```

**app/models/user.py:**
```python
from datetime import datetime
from bson import ObjectId
from app.extensions import mongo

class UserModel:
    collection = mongo.db.users

    @classmethod
    def create(cls, data: dict) -> dict:
        data["created_at"] = datetime.utcnow()
        data["updated_at"] = datetime.utcnow()
        result = cls.collection.insert_one(data)
        data["_id"] = result.inserted_id
        return data

    @classmethod
    def find_by_id(cls, user_id: str) -> dict | None:
        return cls.collection.find_one({"_id": ObjectId(user_id)})

    @classmethod
    def find_by_email(cls, email: str) -> dict | None:
        return cls.collection.find_one({"email": email})
```

---

## Object Storage: MinIO

```bash
uv add boto3
```

**app/lib/storage.py:**
```python
import boto3
from botocore.config import Config
from flask import current_app

def get_s3_client():
    return boto3.client(
        's3',
        endpoint_url=current_app.config['MINIO_ENDPOINT'],
        aws_access_key_id=current_app.config['MINIO_ACCESS_KEY'],
        aws_secret_access_key=current_app.config['MINIO_SECRET_KEY'],
        config=Config(signature_version='s3v4'),
        region_name='us-east-1',
    )

class Storage:
    @staticmethod
    def upload(key: str, data: bytes, content_type: str) -> str:
        s3 = get_s3_client()
        bucket = current_app.config['MINIO_BUCKET']
        s3.put_object(Bucket=bucket, Key=key, Body=data, ContentType=content_type)
        return f"{current_app.config['MINIO_ENDPOINT']}/{bucket}/{key}"

    @staticmethod
    def get_presigned_url(key: str, expires_in: int = 3600) -> str:
        s3 = get_s3_client()
        bucket = current_app.config['MINIO_BUCKET']
        return s3.generate_presigned_url(
            'get_object',
            Params={'Bucket': bucket, 'Key': key},
            ExpiresIn=expires_in,
        )

    @staticmethod
    def delete(key: str):
        s3 = get_s3_client()
        bucket = current_app.config['MINIO_BUCKET']
        s3.delete_object(Bucket=bucket, Key=key)

storage = Storage()
```

---

## Migrations

```bash
# Initialize migrations
uv run flask --app wsgi:app db init

# Create migration
uv run flask --app wsgi:app db migrate -m "initial"

# Apply migration
uv run flask --app wsgi:app db upgrade

# Rollback
uv run flask --app wsgi:app db downgrade
```

---

## Project Structure

```
app/
├── __init__.py              # Application factory
├── config.py                # Configuration
├── extensions.py            # Flask extensions
├── lib/
│   ├── storage.py           # MinIO client
│   └── security.py          # Auth helpers
├── api/
│   ├── __init__.py
│   └── v1/
│       ├── __init__.py
│       ├── users.py
│       ├── auth.py
│       └── files.py
├── models/
│   ├── __init__.py
│   ├── base.py
│   └── user.py
├── schemas/
│   └── user.py
├── services/
│   └── user_service.py
└── utils/
    └── errors.py
migrations/
tests/
wsgi.py
```

---

## Essential Libraries

```bash
# Core
uv add flask

# Database
uv add flask-sqlalchemy flask-migrate psycopg2-binary

# Validation & Serialization
uv add marshmallow flask-marshmallow

# Auth
uv add flask-jwt-extended flask-bcrypt

# CORS
uv add flask-cors

# Object Storage
uv add boto3

# Dev
uv add --dev pytest pytest-flask ruff mypy python-dotenv
```

---

## Configuration

**app/config.py:**
```python
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret")
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # MinIO
    MINIO_ENDPOINT = os.getenv("MINIO_ENDPOINT")
    MINIO_ACCESS_KEY = os.getenv("MINIO_ACCESS_KEY")
    MINIO_SECRET_KEY = os.getenv("MINIO_SECRET_KEY")
    MINIO_BUCKET = os.getenv("MINIO_BUCKET", "uploads")

    # JWT
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", SECRET_KEY)
    JWT_ACCESS_TOKEN_EXPIRES = 3600

class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL", "postgresql://localhost/myapp_dev"
    )

class ProductionConfig(Config):
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL")

class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "sqlite:///:memory:"

config = {
    "development": DevelopmentConfig,
    "production": ProductionConfig,
    "testing": TestingConfig,
    "default": DevelopmentConfig,
}
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
    "startCommand": "uv run gunicorn -w 4 -b 0.0.0.0:$PORT wsgi:app",
    "healthcheckPath": "/health"
  }
}
```

### Procfile
```
web: uv run gunicorn -w 4 -b 0.0.0.0:$PORT wsgi:app
release: uv run flask --app wsgi:app db upgrade
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

# Production dependencies
uv add gunicorn
```

---

## Code Patterns

### Application Factory
```python
# app/__init__.py
from flask import Flask
from app.config import config
from app.extensions import db, migrate, bcrypt, cors, ma

def create_app(config_name: str = "default") -> Flask:
    app = Flask(__name__)
    app.config.from_object(config[config_name])

    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    bcrypt.init_app(app)
    cors.init_app(app)
    ma.init_app(app)

    # Register blueprints
    from app.api.v1 import api_v1_bp
    app.register_blueprint(api_v1_bp, url_prefix="/api/v1")

    # Health check
    @app.route("/health")
    def health():
        return {"status": "healthy"}

    # Error handlers
    from app.utils.errors import register_error_handlers
    register_error_handlers(app)

    return app
```

### Schema (Marshmallow)
```python
# app/schemas/user.py
from app.extensions import ma
from app.models.user import User
from marshmallow import fields, validate

class UserSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = User
        load_instance = True
        exclude = ("password_hash",)

    id = fields.String(dump_only=True)
    created_at = fields.DateTime(dump_only=True)
    email = fields.Email(required=True)
    name = fields.String(validate=validate.Length(max=100))

class UserCreateSchema(ma.Schema):
    email = fields.Email(required=True)
    name = fields.String(validate=validate.Length(max=100))
    password = fields.String(required=True, load_only=True, validate=validate.Length(min=8))

user_schema = UserSchema()
users_schema = UserSchema(many=True)
user_create_schema = UserCreateSchema()
```

### Service Layer
```python
# app/services/user_service.py
from app.models.user import User
from app.extensions import db, bcrypt
from app.utils.errors import NotFoundError, ConflictError

class UserService:
    @staticmethod
    def get_all(page: int = 1, per_page: int = 20):
        return User.query.paginate(page=page, per_page=per_page, error_out=False)

    @staticmethod
    def get_by_id(user_id: str) -> User:
        user = User.query.get(user_id)
        if not user:
            raise NotFoundError("User not found")
        return user

    @staticmethod
    def create(data: dict) -> User:
        if User.query.filter_by(email=data["email"]).first():
            raise ConflictError("Email already exists")

        user = User(
            email=data["email"],
            name=data.get("name"),
            password_hash=bcrypt.generate_password_hash(data["password"]).decode("utf-8"),
        )
        return user.save()

    @staticmethod
    def update(user: User, data: dict) -> User:
        for key, value in data.items():
            if value is not None and hasattr(user, key):
                setattr(user, key, value)
        db.session.commit()
        return user

    @staticmethod
    def delete(user: User):
        user.delete()
```

### API Blueprint
```python
# app/api/v1/__init__.py
from flask import Blueprint

api_v1_bp = Blueprint("api_v1", __name__)

from app.api.v1 import users, auth, files  # noqa
```

### API Endpoint
```python
# app/api/v1/users.py
from flask import request, jsonify
from app.api.v1 import api_v1_bp
from app.services.user_service import UserService
from app.schemas.user import user_schema, users_schema, user_create_schema
from app.utils.errors import BadRequestError

@api_v1_bp.route("/users", methods=["GET"])
def list_users():
    page = request.args.get("page", 1, type=int)
    per_page = request.args.get("per_page", 20, type=int)
    pagination = UserService.get_all(page=page, per_page=per_page)
    return jsonify({
        "data": users_schema.dump(pagination.items),
        "meta": {
            "page": pagination.page,
            "per_page": pagination.per_page,
            "total": pagination.total,
            "pages": pagination.pages,
        }
    })

@api_v1_bp.route("/users/<user_id>", methods=["GET"])
def get_user(user_id: str):
    user = UserService.get_by_id(user_id)
    return jsonify(user_schema.dump(user))

@api_v1_bp.route("/users", methods=["POST"])
def create_user():
    data = request.get_json()
    errors = user_create_schema.validate(data)
    if errors:
        raise BadRequestError(errors)
    user = UserService.create(data)
    return jsonify(user_schema.dump(user)), 201
```

### Error Handling
```python
# app/utils/errors.py
from flask import jsonify, Flask

class APIError(Exception):
    def __init__(self, message, status_code=400):
        self.message = message
        self.status_code = status_code

class NotFoundError(APIError):
    def __init__(self, message="Not found"):
        super().__init__(message, 404)

class BadRequestError(APIError):
    def __init__(self, message="Bad request"):
        super().__init__(message, 400)

class ConflictError(APIError):
    def __init__(self, message="Conflict"):
        super().__init__(message, 409)

def register_error_handlers(app: Flask):
    @app.errorhandler(APIError)
    def handle_api_error(error):
        return jsonify({"error": error.message}), error.status_code

    @app.errorhandler(404)
    def handle_404(error):
        return jsonify({"error": "Not found"}), 404

    @app.errorhandler(500)
    def handle_500(error):
        return jsonify({"error": "Internal server error"}), 500
```

### WSGI Entry Point
```python
# wsgi.py
import os
from app import create_app

config_name = os.getenv("FLASK_ENV", "development")
app = create_app(config_name)

if __name__ == "__main__":
    app.run()
```

---

## Setup Commands

```bash
# Create project
uv init my-api && cd my-api

# Add dependencies
uv add flask flask-sqlalchemy flask-migrate psycopg2-binary
uv add flask-jwt-extended flask-bcrypt flask-cors
uv add marshmallow flask-marshmallow boto3
uv add --dev pytest pytest-flask ruff python-dotenv gunicorn

# Create structure
mkdir -p app/{api/v1,models,schemas,services,lib,utils}
mkdir -p tests migrations
touch app/{__init__.py,config.py,extensions.py}
touch wsgi.py

# Environment
cat > .env << EOF
FLASK_ENV=development
SECRET_KEY=$(openssl rand -hex 32)
DATABASE_URL=postgresql://user:pass@localhost/myapp
MINIO_ENDPOINT=http://localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
EOF

# Initialize database
uv run flask --app wsgi:app db init
uv run flask --app wsgi:app db migrate -m "initial"
uv run flask --app wsgi:app db upgrade

# Run
uv run flask --app wsgi:app run --debug
```

---

## Key Rules

- ALWAYS use the application factory pattern
- ALWAYS use blueprints for organizing routes
- Use Flask-Migrate for migrations (Alembic under the hood)
- Keep views thin - business logic in services
- Use Marshmallow for validation and serialization
- Use Gunicorn for production (not Flask's dev server)
- Deploy to Railway with PostgreSQL addon
