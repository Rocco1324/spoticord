# Local Docker build for the host architecture (Omarchy x86-64 / amd64)
# This intentionally builds only one binary instead of cross-compiling arm64.

# Builder
FROM rust:1.83.0-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    libpq-dev \
    pkg-config \
    ca-certificates \
    curl \
    bzip2 \
    && rm -rf /var/lib/apt/lists/*

COPY . .

# Cargo may update the stale Cargo.lock from older dependency versions.
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/target \
    cargo build --release

# Runtime
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/spoticord /usr/local/bin/spoticord

ENTRYPOINT ["/usr/local/bin/spoticord"]
