#!/bin/bash

# Test script for MTG MCP Server

echo "=== Testing MTG MCP Server ==="
echo

echo "1. Testing server initialization:"
timeout 10 bash -c 'echo -e "{\"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"initialize\", \"params\": {\"protocolVersion\": \"2024-11-05\", \"capabilities\": {\"roots\": {\"listChanged\": true}}}}\n{\"jsonrpc\": \"2.0\", \"method\": \"notifications/initialized\"}\n{\"jsonrpc\": \"2.0\", \"id\": 2, \"method\": \"tools/list\", \"params\": {}}" | ./target/debug/mtg-mcp' 2>/dev/null | tail -1 | jq -r '.result.tools[]?.name // empty'

echo
echo "2. Testing get_card tool with Lightning Bolt:"
timeout 15 bash -c 'echo -e "{\"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"initialize\", \"params\": {\"protocolVersion\": \"2024-11-05\", \"capabilities\": {\"roots\": {\"listChanged\": true}}}}\n{\"jsonrpc\": \"2.0\", \"method\": \"notifications/initialized\"}\n{\"jsonrpc\": \"2.0\", \"id\": 2, \"method\": \"tools/call\", \"params\": {\"name\": \"get_card\", \"arguments\": {\"name\": \"lightning bolt\"}}}" | ./target/debug/mtg-mcp' 2>/dev/null | tail -1 | jq -r '.result.content[0].text' | jq -r '.name // empty'

echo
echo "3. Testing search_cards tool:"
timeout 15 bash -c 'echo -e "{\"jsonrpc\": \"2.0\", \"id\": 1, \"method\": \"initialize\", \"params\": {\"protocolVersion\": \"2024-11-05\", \"capabilities\": {\"roots\": {\"listChanged\": true}}}}\n{\"jsonrpc\": \"2.0\", \"method\": \"notifications/initialized\"}\n{\"jsonrpc\": \"2.0\", \"id\": 2, \"method\": \"tools/call\", \"params\": {\"name\": \"search_cards\", \"arguments\": {\"query\": \"lightning\", \"limit\": 3}}}" | ./target/debug/mtg-mcp' 2>/dev/null | tail -1 | jq -r '.result.content[0].text' | jq -r '.[].name // empty'

echo
echo "=== Test Complete ==="