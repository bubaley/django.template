FROM ghcr.io/astral-sh/uv:python3.12-alpine

# Write all packages in 1 row
# RUN apk add
# geos-dev gcc musl-dev (for shapely)
# gettext gettext (for localization. Check scripts/start_app.sh for compilemessages)

WORKDIR /app

ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

COPY . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

ENV PATH="/app/.venv/bin:$PATH"

ENTRYPOINT []
