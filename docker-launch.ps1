# MTG MCP Docker Build and Launch Script (PowerShell)
# Maintains core behavior while enabling containerization

$ErrorActionPreference = "Stop"

Write-Host "=== MTG MCP Docker Build & Launch ===" -ForegroundColor Green
Write-Host "Maintaining core behavior as per Copilot Guidelines..." -ForegroundColor Yellow

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker first." -ForegroundColor Red
    exit 1
}

# Build the Docker image
Write-Host "🔨 Building MTG MCP Docker image..." -ForegroundColor Blue
docker build -t mtg-mcp:latest .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Docker image built successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Docker build failed" -ForegroundColor Red
    exit 1
}

# Stop any existing container
Write-Host "🧹 Cleaning up existing containers..." -ForegroundColor Blue
docker-compose down 2>$null

# Launch the container
Write-Host "🚀 Launching MTG MCP container..." -ForegroundColor Blue
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ MTG MCP container launched successfully" -ForegroundColor Green
    Write-Host ""
    Write-Host "Container Status:" -ForegroundColor Yellow
    docker-compose ps
    Write-Host ""
    Write-Host "To view logs: docker-compose logs -f mtg-mcp-server" -ForegroundColor Cyan
    Write-Host "To stop: docker-compose down" -ForegroundColor Cyan
    Write-Host "To enter container: docker-compose exec mtg-mcp-server sh" -ForegroundColor Cyan
} else {
    Write-Host "❌ Failed to launch container" -ForegroundColor Red
    exit 1
}

Write-Host "=== Docker Setup Complete ===" -ForegroundColor Green
