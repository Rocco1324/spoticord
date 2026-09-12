# Local Docker build for the host architecture (Omarchy x86-64 / amd64)
# Uses a modern stable Rust toolchain because the current dependency graph
# includes crates requiring Rust 1.89+ / Edition 2024.

FROM rust:1.89.0-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    libpq-dev \
    pkg-config \
    ca-certificates \
    curl \
    bzip2 \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY . .

ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    --mount=type=cache,target=/app/target \
    cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/spoticord /usr/local/bin/spoticord

ENTRYPOINT ["/usr/local/bin/spoticord"]
