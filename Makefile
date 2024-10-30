ifneq (,$(wildcard .env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif

MANAGE := python manage.py
DOCKER_COMPOSE := docker compose

CELERY_WORKERS ?= 4
CELERY_CONCURRENCY ?= 4

# ----------- SHORT COMMANDS -----------

r: run ## short run runserver
m: migrate ## short run migrate
mm: makemigrations ## short run makemigrations
mr: migrate run ## short run migrate && runserver

# ----------- BASE COMMANDS -----------

run: ## run runserver
	$(MANAGE) runserver

migrate: ## run migrate
	$(MANAGE) migrate

makemigrations: ## run makemigrations
	$(MANAGE) makemigrations

createsuperuser: ## run createsuperuser
	$(MANAGE) createsuperuser

test: ## run test --keepdb
	$(MANAGE) test --keepdb

gunicorn: migrate ## run gunicorn
	# django-admin compilemessages -l ru --ignore=env # Check Dockerfile for gettext
	gunicorn core.wsgi:application --forwarded-allow-ips="*" --timeout=300 --workers=$(CELERY_WORKERS) --bind 0.0.0.0:8000

celery: ## run celery workers with beat
	celery -A core worker -B -E -n worker --loglevel=INFO --concurrency=$(CELERY_CONCURRENCY)

secret: ## generate secret_key
	@python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key().replace('#', '+'))"

init-project: ## install all requirements, set pre-commit. Use setup project
	uv add Django \
      django-cors-headers \
      django-environ \
      djangorestframework \
      djangorestframework-simplejwt \
      loguru \
      requests \
      sentry-sdk \
      gunicorn \
      air-drf-relation \
      django-filter \
      redis \
      celery \
      django-extensions \
      "psycopg[binary]"
	uv add ruff pre-commit --group dev
	pre-commit install

help:
	@echo "Usage: make <target>"
	@awk 'BEGIN {FS = ":.*##"} /^[0-9a-zA-Z_-]+:.*?## / { printf "  * %-20s -%s\n", $$1, $$2 }' $(MAKEFILE_LIST)
