# Local Docker build for the host architecture (Omarchy x86-64 / amd64)
# This intentionally builds only one binary instead of cross-compiling arm64.

# Builder
FROM rust:1.83.0-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    git \
    libpq-dev \
    pkg-config \
    ca-certificates \
    curl \
    bzip2 \
    && rm -rf /var/lib/apt/lists/*

COPY . .

# Use the system git client for git dependencies. This avoids Cargo/libgit2
# authentication failures when fetching the public Spoticord librespot fork.
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

# Cargo may update the stale Cargo.lock from older dependency versions.
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
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
