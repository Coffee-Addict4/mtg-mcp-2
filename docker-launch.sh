#!/bin/bash

# MTG MCP Docker Build and Launch Script
# Maintains core behavior while enabling containerization

set -e

echo "=== MTG MCP Docker Build & Launch ==="
echo "Maintaining core behavior as per Copilot Guidelines..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker is running"

# Build the Docker image
echo "🔨 Building MTG MCP Docker image..."
docker build -t mtg-mcp:latest .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully"
else
    echo "❌ Docker build failed"
    exit 1
fi

# Stop any existing container
echo "🧹 Cleaning up existing containers..."
docker-compose down 2>/dev/null || true

# Launch the container
echo "🚀 Launching MTG MCP container..."
docker-compose up -d

if [ $? -eq 0 ]; then
    echo "✅ MTG MCP container launched successfully"
    echo ""
    echo "Container Status:"
    docker-compose ps
    echo ""
    echo "To view logs: docker-compose logs -f mtg-mcp-server"
    echo "To stop: docker-compose down"
    echo "To enter container: docker-compose exec mtg-mcp-server sh"
else
    echo "❌ Failed to launch container"
    exit 1
fi

echo "=== Docker Setup Complete ==="
