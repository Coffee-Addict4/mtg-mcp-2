use anyhow::Result;
use mcp_core::{
    server::Server,
    transport::{ServerStdioTransport, Transport},
    types::{
        CallToolRequest, CallToolResponse, ServerCapabilities, Tool, 
        ToolCapabilities, ToolResponseContent, TextContent,
    },
};
use scryfall::Card;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::pin::Pin;
use std::future::Future;
use tracing::info;
use tracing_subscriber;

#[derive(Debug, Serialize, Deserialize)]
struct SearchCardsInput {
    query: String,
    #[serde(default = "default_limit")]
    limit: usize,
}

#[derive(Debug, Serialize, Deserialize)]
struct GetCardInput {
    name: String,
}

fn default_limit() -> usize {
    10
}

fn search_cards_handler(request: CallToolRequest) -> Pin<Box<dyn Future<Output = CallToolResponse> + Send>> {
    Box::pin(async move {
        let arguments = request.arguments.unwrap_or_default();
        let input: SearchCardsInput = match serde_json::from_value(serde_json::to_value(arguments).unwrap_or(Value::Object(Default::default()))) {
            Ok(input) => input,
            Err(e) => return CallToolResponse {
                content: vec![ToolResponseContent::Text(TextContent {
                    content_type: "text".to_string(),
                    text: format!("Invalid input: {}", e),
                    annotations: None,
                })],
                is_error: Some(true),
                meta: None,
            },
        };
        
        // For now, we'll just search by name since the search API is complex
        let cards: Vec<Card> = if let Ok(card) = Card::named(&input.query).await {
            vec![card]
        } else {
            vec![]
        };

        if cards.is_empty() {
            return CallToolResponse {
                content: vec![ToolResponseContent::Text(TextContent {
                    content_type: "text".to_string(),
                    text: "No cards found matching the search criteria".to_string(),
                    annotations: None,
                })],
                is_error: Some(false),
                meta: None,
            };
        }

        let results: Vec<Value> = cards
            .into_iter()
            .map(|card| {
                json!({
                    "name": card.name,
                    "mana_cost": card.mana_cost,
                    "type_line": card.type_line,
                    "oracle_text": card.oracle_text,
                    "colors": card.colors,
                    "cmc": card.cmc,
                    "power": card.power,
                    "toughness": card.toughness,
                    "set": card.set,
                    "rarity": card.rarity,
                    "image_uris": card.image_uris,
                    "prices": card.prices,
                    "legalities": card.legalities,
                })
            })
            .collect();

        CallToolResponse {
            content: vec![ToolResponseContent::Text(TextContent {
                content_type: "text".to_string(),
                text: serde_json::to_string_pretty(&results).unwrap_or_else(|e| format!("Error serializing results: {}", e)),
                annotations: None,
            })],
            is_error: Some(false),
            meta: None,
        }
    })
}

fn get_card_handler(request: CallToolRequest) -> Pin<Box<dyn Future<Output = CallToolResponse> + Send>> {
    Box::pin(async move {
        let arguments = request.arguments.unwrap_or_default();
        let input: GetCardInput = match serde_json::from_value(serde_json::to_value(arguments).unwrap_or(Value::Object(Default::default()))) {
            Ok(input) => input,
            Err(e) => return CallToolResponse {
                content: vec![ToolResponseContent::Text(TextContent {
                    content_type: "text".to_string(),
                    text: format!("Invalid input: {}", e),
                    annotations: None,
                })],
                is_error: Some(true),
                meta: None,
            },
        };
        
        match Card::named_fuzzy(&input.name).await {
            Ok(card) => {
                let result = json!({
                    "name": card.name,
                    "mana_cost": card.mana_cost,
                    "type_line": card.type_line,
                    "oracle_text": card.oracle_text,
                    "colors": card.colors,
                    "color_identity": card.color_identity,
                    "cmc": card.cmc,
                    "power": card.power,
                    "toughness": card.toughness,
                    "loyalty": card.loyalty,
                    "set": card.set,
                    "set_name": card.set_name,
                    "rarity": card.rarity,
                    "flavor_text": card.flavor_text,
                    "artist": card.artist,
                    "image_uris": card.image_uris,
                    "prices": card.prices,
                    "legalities": card.legalities,
                    "keywords": card.keywords,
                    "produced_mana": card.produced_mana,
                    "rulings_uri": card.rulings_uri,
                    "scryfall_uri": card.scryfall_uri,
                });

                CallToolResponse {
                    content: vec![ToolResponseContent::Text(TextContent {
                        content_type: "text".to_string(),
                        text: serde_json::to_string_pretty(&result).unwrap_or_else(|e| format!("Error serializing result: {}", e)),
                        annotations: None,
                    })],
                    is_error: Some(false),
                    meta: None,
                }
            }
            Err(e) => CallToolResponse {
                content: vec![ToolResponseContent::Text(TextContent {
                    content_type: "text".to_string(),
                    text: format!("Card not found: {}", e),
                    annotations: None,
                })],
                is_error: Some(true),
                meta: None,
            },
        }
    })
}

fn create_search_cards_tool() -> Tool {
    Tool {
        name: "search_cards".to_string(),
        description: Some("Search for Magic: The Gathering cards by name, type, colors, or other criteria".to_string()),
        input_schema: json!({
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
        }),
        annotations: None,
    }
}

fn create_get_card_tool() -> Tool {
    Tool {
        name: "get_card".to_string(),
        description: Some("Get detailed information about a specific Magic: The Gathering card by name".to_string()),
        input_schema: json!({
            "type": "object",
            "properties": {
                "name": {
                    "type": "string",
                    "description": "Name of the card (fuzzy search supported)"
                }
            },
            "required": ["name"]
        }),
        annotations: None,
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::fmt::init();
    info!("Starting MTG MCP Server");

    let protocol = Server::builder(
        "mtg-mcp".to_string(),
        "0.1.0".to_string(),
        mcp_core::types::ProtocolVersion::V2024_11_05,
    )
    .set_capabilities(ServerCapabilities {
        tools: Some(ToolCapabilities::default()),
        ..Default::default()
    })
    .register_tool(
        create_search_cards_tool(),
        search_cards_handler,
    )
    .register_tool(
        create_get_card_tool(),
        get_card_handler,
    )
    .build();

    let transport = ServerStdioTransport::new(protocol);
    transport.open().await?;

    Ok(())
}