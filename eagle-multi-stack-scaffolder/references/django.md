# Django Reference

## Research Queries
- "Django best practices 2025 2026"
- "Django REST Framework vs Django Ninja 2025"
- "Django project structure large applications"
- "Railway Django deployment 2025"
- "Django S3 MinIO storage"

## Package Manager
**uv** - 10-100x faster than pip.

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv init my-project && cd my-project
uv add django djangorestframework
```

## When to Choose Django

- Full-featured web applications with admin
- Projects needing built-in ORM, auth, admin
- Rapid development with batteries included
- Teams familiar with Django ecosystem
- Content-heavy applications

---

## Database Selection

| Database | Use Case | Driver |
|----------|----------|--------|
| **PostgreSQL** | Production (recommended) | `psycopg[binary]` or `psycopg2-binary` |
| **SQLite** | Development, small apps | Built-in |
| **MongoDB** | Document-based (via Djongo) | `djongo` (limited support) |

### PostgreSQL Configuration
```python
# settings/base.py
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': config('DB_NAME'),
        'USER': config('DB_USER'),
        'PASSWORD': config('DB_PASSWORD'),
        'HOST': config('DB_HOST', default='localhost'),
        'PORT': config('DB_PORT', default='5432'),
        'CONN_MAX_AGE': 60,  # Connection pooling
        'OPTIONS': {
            'connect_timeout': 10,
        },
    }
}
```

### Database URL Pattern (Railway)
```python
import dj_database_url

DATABASES = {
    'default': dj_database_url.config(
        default=config('DATABASE_URL'),
        conn_max_age=60,
        conn_health_checks=True,
    )
}
```

---

## Django ORM

Django's built-in ORM is powerful and well-integrated.

### Base Model
```python
# apps/core/models.py
import uuid
from django.db import models

class TimeStampedModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True
```

### Model with Relationships
```python
# apps/users/models.py
from django.contrib.auth.models import AbstractUser
from apps.core.models import TimeStampedModel
from django.db import models

class User(AbstractUser, TimeStampedModel):
    email = models.EmailField(unique=True)
    avatar_url = models.URLField(blank=True, null=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    class Meta:
        db_table = 'users'
        indexes = [
            models.Index(fields=['email']),
        ]

# apps/posts/models.py
class Post(TimeStampedModel):
    title = models.CharField(max_length=200)
    content = models.TextField(blank=True)
    published = models.BooleanField(default=False)
    author = models.ForeignKey(
        'users.User',
        on_delete=models.CASCADE,
        related_name='posts'
    )

    class Meta:
        db_table = 'posts'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['author', 'published']),
        ]
```

### Custom Manager & QuerySet
```python
# apps/posts/models.py
class PostQuerySet(models.QuerySet):
    def published(self):
        return self.filter(published=True)

    def by_author(self, user):
        return self.filter(author=user)

class PostManager(models.Manager):
    def get_queryset(self):
        return PostQuerySet(self.model, using=self._db)

    def published(self):
        return self.get_queryset().published()

class Post(TimeStampedModel):
    # ... fields ...
    objects = PostManager()
```

---

## Object Storage: MinIO

```bash
uv add django-storages boto3
```

**settings/base.py:**
```python
# MinIO / S3 Storage
if config('MINIO_ENDPOINT', default=None):
    STORAGES = {
        "default": {
            "BACKEND": "storages.backends.s3boto3.S3Boto3Storage",
        },
        "staticfiles": {
            "BACKEND": "django.contrib.staticfiles.storage.StaticFilesStorage",
        },
    }

    AWS_S3_ENDPOINT_URL = config('MINIO_ENDPOINT')
    AWS_ACCESS_KEY_ID = config('MINIO_ACCESS_KEY')
    AWS_SECRET_ACCESS_KEY = config('MINIO_SECRET_KEY')
    AWS_STORAGE_BUCKET_NAME = config('MINIO_BUCKET', default='uploads')
    AWS_S3_FILE_OVERWRITE = False
    AWS_DEFAULT_ACL = None
    AWS_S3_SIGNATURE_VERSION = 's3v4'
    AWS_S3_REGION_NAME = 'us-east-1'
```

**Model with File Upload:**
```python
from django.db import models

def upload_to(instance, filename):
    import uuid
    ext = filename.split('.')[-1]
    return f"uploads/{uuid.uuid4()}.{ext}"

class Document(TimeStampedModel):
    file = models.FileField(upload_to=upload_to)
    name = models.CharField(max_length=255)
```

---

## Migrations

```bash
# Create migrations
uv run python manage.py makemigrations

# Apply migrations
uv run python manage.py migrate

# Show migrations
uv run python manage.py showmigrations

# Rollback
uv run python manage.py migrate app_name 0001
```

### Data Migrations
```python
# apps/users/migrations/0002_seed_data.py
from django.db import migrations

def create_initial_users(apps, schema_editor):
    User = apps.get_model('users', 'User')
    User.objects.create(
        email='admin@example.com',
        username='admin',
        is_staff=True,
        is_superuser=True,
    )

def reverse_func(apps, schema_editor):
    User = apps.get_model('users', 'User')
    User.objects.filter(email='admin@example.com').delete()

class Migration(migrations.Migration):
    dependencies = [
        ('users', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(create_initial_users, reverse_func),
    ]
```

---

## Project Structure

```
src/
├── config/
│   ├── __init__.py
│   ├── settings/
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
├── apps/
│   ├── core/
│   │   ├── __init__.py
│   │   ├── models.py           # Base models
│   │   ├── permissions.py
│   │   └── pagination.py
│   ├── users/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── services.py
│   │   └── admin.py
│   └── posts/
│       ├── __init__.py
│       ├── models.py
│       ├── serializers.py
│       ├── views.py
│       ├── urls.py
│       └── services.py
├── lib/
│   └── storage.py              # Storage helpers
└── manage.py
```

---

## Essential Libraries

```bash
# Core
uv add django djangorestframework

# Database
uv add "psycopg[binary]"            # PostgreSQL
uv add dj-database-url              # Parse DATABASE_URL

# API
uv add django-filter                # Filtering
uv add drf-spectacular              # OpenAPI docs

# Storage
uv add django-storages boto3        # S3/MinIO

# Security & Auth
uv add django-cors-headers          # CORS
uv add djangorestframework-simplejwt # JWT

# Config
uv add python-decouple              # Environment config

# Async Tasks (optional)
uv add celery redis                 # Background tasks

# Dev
uv add --dev pytest pytest-django ruff mypy
```

---

## Configuration

**config/settings/base.py:**
```python
from pathlib import Path
from decouple import config, Csv
import dj_database_url

BASE_DIR = Path(__file__).resolve().parent.parent.parent

SECRET_KEY = config('SECRET_KEY')
DEBUG = config('DEBUG', default=False, cast=bool)
ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='', cast=Csv())

# Apps
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # Third party
    'rest_framework',
    'corsheaders',
    'django_filters',
    'drf_spectacular',
    'storages',
    # Local apps
    'apps.core',
    'apps.users',
    'apps.posts',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',  # Static files
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'config.urls'
AUTH_USER_MODEL = 'users.User'

# Database
DATABASES = {
    'default': dj_database_url.config(
        default=config('DATABASE_URL'),
        conn_max_age=60,
    )
}

# REST Framework
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ],
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
}

# CORS
CORS_ALLOWED_ORIGINS = config('CORS_ORIGINS', default='', cast=Csv())
CORS_ALLOW_ALL_ORIGINS = DEBUG

# Static files
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STORAGES = {
    "staticfiles": {
        "BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage",
    },
}
```

**config/settings/development.py:**
```python
from .base import *

DEBUG = True
ALLOWED_HOSTS = ['*']
CORS_ALLOW_ALL_ORIGINS = True
```

**config/settings/production.py:**
```python
from .base import *

DEBUG = False
SECURE_SSL_REDIRECT = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
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
    "startCommand": "uv run gunicorn config.wsgi:application --bind 0.0.0.0:$PORT",
    "healthcheckPath": "/health/"
  }
}
```

### Procfile
```
web: uv run gunicorn config.wsgi:application --bind 0.0.0.0:$PORT
release: uv run python manage.py migrate --noinput && uv run python manage.py collectstatic --noinput
```

### Environment Variables (Railway)
```bash
DATABASE_URL=postgresql://...
SECRET_KEY=your-secret-key
DEBUG=False
ALLOWED_HOSTS=your-app.railway.app
CORS_ORIGINS=https://your-frontend.com
MINIO_ENDPOINT=https://...
MINIO_ACCESS_KEY=...
MINIO_SECRET_KEY=...
MINIO_BUCKET=uploads
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
uv add gunicorn whitenoise
```

---

## Code Patterns

### Serializer
```python
# apps/users/serializers.py
from rest_framework import serializers
from apps.users.models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'username', 'avatar_url', 'created_at']
        read_only_fields = ['id', 'created_at']

class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ['email', 'username', 'password']

    def create(self, validated_data):
        return User.objects.create_user(**validated_data)
```

### Service Layer
```python
# apps/users/services.py
from django.db import transaction
from apps.users.models import User

class UserService:
    @staticmethod
    @transaction.atomic
    def create_user(*, email: str, username: str, password: str) -> User:
        user = User.objects.create_user(
            email=email,
            username=username,
            password=password,
        )
        return user

    @staticmethod
    def get_by_id(user_id: str) -> User:
        return User.objects.get(id=user_id)

    @staticmethod
    def update(user: User, **kwargs) -> User:
        for key, value in kwargs.items():
            if value is not None:
                setattr(user, key, value)
        user.save()
        return user
```

### ViewSet
```python
# apps/users/views.py
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny

from apps.users.models import User
from apps.users.serializers import UserSerializer, UserCreateSerializer

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    filterset_fields = ['is_active']
    search_fields = ['email', 'username']
    ordering_fields = ['created_at', 'email']

    def get_permissions(self):
        if self.action == 'create':
            return [AllowAny()]
        return [IsAuthenticated()]

    def get_serializer_class(self):
        if self.action == 'create':
            return UserCreateSerializer
        return UserSerializer

    @action(detail=False, methods=['get'])
    def me(self, request):
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)
```

### URLs
```python
# apps/users/urls.py
from rest_framework.routers import DefaultRouter
from apps.users.views import UserViewSet

router = DefaultRouter()
router.register('users', UserViewSet, basename='users')

urlpatterns = router.urls

# config/urls.py
from django.contrib import admin
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/', include('apps.users.urls')),
    path('api/v1/', include('apps.posts.urls')),
    # OpenAPI
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger'),
    # Health check
    path('health/', lambda r: JsonResponse({'status': 'healthy'})),
]
```

---

## Setup Commands

```bash
# Create project
uv init my-project && cd my-project

# Add dependencies
uv add django djangorestframework
uv add "psycopg[binary]" dj-database-url
uv add django-cors-headers django-filter drf-spectacular
uv add djangorestframework-simplejwt
uv add django-storages boto3 python-decouple
uv add --dev pytest pytest-django ruff gunicorn whitenoise

# Create Django project
uv run django-admin startproject config src
cd src

# Create apps
mkdir -p apps/{core,users,posts}
uv run python manage.py startapp core apps/core
uv run python manage.py startapp users apps/users
uv run python manage.py startapp posts apps/posts

# Environment
cat > .env << EOF
SECRET_KEY=$(openssl rand -hex 32)
DEBUG=True
DATABASE_URL=postgresql://user:pass@localhost/myapp
ALLOWED_HOSTS=localhost,127.0.0.1
EOF

# Database
uv run python manage.py migrate
uv run python manage.py createsuperuser

# Run
uv run python manage.py runserver
```

---

## Key Rules

- Use service layer for business logic, keep views thin
- Use custom managers for complex querysets
- Use `select_related` and `prefetch_related` for query optimization
- Use Django's built-in ORM - it's excellent
- Use drf-spectacular for API documentation
- Use Django admin for quick CRUD interfaces
- Use transactions for multi-model operations
- Deploy to Railway with PostgreSQL addon
