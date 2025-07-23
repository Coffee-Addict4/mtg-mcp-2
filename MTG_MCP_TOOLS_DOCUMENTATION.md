# MTG MCP Server Tools Documentation

## Overview
The MTG MCP Server is a Model Context Protocol (MCP) server that provides access to Magic: The Gathering card data through the Scryfall API. This server follows the MCP specification and provides tools for searching and retrieving MTG card information.

## Server Information
- **Name**: mtg-mcp
- **Version**: 0.1.0
- **Protocol Version**: 2024-11-05
- **Capabilities**: Tools support enabled

## Available Tools

### 1. search_cards
{
  "name": "search_cards",
  "description": "Search for Magic: The Gathering cards by name, type, colors, or other criteria",
  "input_schema": {
    "type": "object",
    "properties": {
      "query": {
        "type": "string",
        "description": "Scryfall search query (e.g., 'lightning bolt', 'color:red type:creature', 'cmc:3')"
      },
      "limit": {
        "type": "number",
        "description": "Maximum number of results to return (default: 10)",
        "minimum": 1,
        "maximum": 100
      }
    },
    "required": ["query"]
  }
}
```

#### Usage Examples
```json
// Search for a specific card
{
  "query": "lightning bolt"
}

// Search by color and type
{
  "query": "color:red type:creature"
}

// Search by converted mana cost
{
  "query": "cmc:3"
}

// Search with custom limit
{
  "query": "color:blue",
  "limit": 20
}
```

#### Response Format
Returns an array of card objects with the following properties:
- `name`: Card name
- `mana_cost`: Mana cost string
- `type_line`: Type line (e.g., "Creature — Human Wizard")
- `oracle_text`: Rules text
- `colors`: Array of card colors
- `cmc`: Converted mana cost (number)
- `power`: Creature power (if applicable)
- `toughness`: Creature toughness (if applicable)
  "description": "Get detailed information about a specific Magic: The Gathering card by name",
  "input_schema": {
    "type": "object",
    "properties": {
      "name": {
        "type": "string",
        "description": "Name of the card (fuzzy search supported)"
      }
    },
    "required": ["name"]
  }
}
```

#### Usage Examples
```json
// Exact name
{
  "name": "Lightning Bolt"
}

// Fuzzy search (typos allowed)
{
  "name": "lightening bolt"
}

// Partial name
{
  "name": "bolt"
}
```

#### Response Format
Returns a detailed card object with extended properties:
- `name`: Card name
- `mana_cost`: Mana cost string
- `type_line`: Type line
- `oracle_text`: Rules text
- `colors`: Array of card colors
- `color_identity`: Color identity for Commander format
- `cmc`: Converted mana cost
- `power`: Creature power
      "text": "Error message description"
    }
  ],
  "is_error": true
}
```

## Integration Instructions

### For MCP Clients (like Claude Desktop)
Add this server to your MCP configuration:

```json
{
  "mcpServers": {
    "mtg-mcp": {
      "command": "path/to/mtg-mcp",
      "args": []
    }
  }
}
```

### For Docker Usage
```bash
# Build the image
docker build -t mtg-mcp .

# Run interactively
docker run -i mtg-mcp

# Or use docker-compose
docker-compose up mtg-mcp-server
```

### For Development
```bash
# Run directly
cargo run

# Build release
cargo build --release

# Test with sample input
echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "get_card", "arguments": {"name": "Lightning Bolt"}}, "id": 1}' | ./target/release/mtg-mcp
```

## Data Source
All card data is sourced from the Scryfall API (https://scryfall.com/docs/api), which provides comprehensive and up-to-date Magic: The Gathering card information.

## Performance Notes
- The server uses fuzzy search for card names, making it tolerant of typos and partial matches
- Card searches are performed in real-time against the Scryfall API
- Consider implementing caching for production use to reduce API calls
- Default search limit is 10 cards, configurable up to 100

## Compliance
This server adheres to the MTG Optimizer Guidelines specified in the Copilot-Guidelines file:
- Maintains core functionality integrity
## Support
For issues or feature requests, please refer to the project repository and follow the established development guidelines.
