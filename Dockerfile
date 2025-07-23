# Multi-stage build for MTG MCP Server
# Stage 1: Build
FROM rust:1.82-slim as builder

WORKDIR /app

# Install necessary system dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy manifests
COPY Cargo.toml Cargo.lock ./

# Copy source code
COPY src/ ./src/

# Build for release
RUN cargo build --release

# Stage 2: Runtime
FROM debian:bookworm-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/* \
    && adduser --disabled-password --gecos '' --shell /bin/sh --uid 1001 appuser

# Copy the binary from builder stage
COPY --from=builder /app/target/release/mtg-mcp /app/mtg-mcp

# Copy guidelines to maintain integrity as per requirements
COPY Copilot-Guidelines /app/Copilot-Guidelines

# Change ownership to appuser
RUN chown -R appuser:appuser /app

# Switch to non-root user for security
USER appuser

# Expose the standard MCP server port (if needed for future TCP transport)
EXPOSE 3000

# Health check to ensure the server is responsive
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD echo '{"jsonrpc": "2.0", "method": "initialize", "params": {"protocolVersion": "2024-11-05", "capabilities": {}, "clientInfo": {"name": "health-check"}}, "id": 1}' | ./mtg-mcp || exit 1

# Set environment variables for optimal performance
ENV RUST_LOG=info
ENV RUST_BACKTRACE=1

# Run the MCP server
CMD ["./mtg-mcp"]
