# MTG MCP

![MTG MCP Logo](logo.png)

A Model Context Protocol server for Magic: The Gathering card data using the Scryfall API.

## What it does

This MCP server lets LLMs look up MTG cards and search through them. Pretty straightforward - you ask about a card, it fetches the data from Scryfall.

## Installation

```bash
cargo install mtg-mcp
```

## Usage

The server exposes these tools:

- `get_card` - Look up a specific card by name (fuzzy search works)
- `search_cards` - Search for cards using Scryfall syntax

### Examples

Get a card:
```
get_card("Lightning Bolt")
```

Search for cards:
```
search_cards("color:red type:creature cmc:3")
```

## Configuration

Add this to your MCP settings:

```json
{
  "mcpServers": {
    "mtg": {
      "command": "path/to/mtg-mcp"
    }
  }
}
```

## Development

Standard Rust project. Uses tokio for async and reqwest for HTTP requests.

```bash
cargo test
cargo run
```

## License

MIT
