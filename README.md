# DataJourney MCP

A Gleam-based Model Context Protocol (MCP) server that exposes DataJourney
interfaces over HTTP, Server-Sent Events (SSE), and WebSocket transports. It
publishes official DataJourney documentation as an MCP resource and is ready to
host additional DataJourney tools and prompts as they are implemented.

## Features

- **Documentation resource** `datajourney-documentation` pointing to
  <https://github.com/DataJourneyHQ/DataJourney/blob/main/README.md>.
- **HTTP JSON-RPC** endpoint at `POST /mcp` for direct request/response flows.
- **SSE transport** at `GET /mcp/sse` (subscribe) and `POST /mcp/sse`
  (publish responses) for long-lived connections.
- **WebSocket transport** at `GET /mcp/ws` for bidirectional MCP sessions.

All transports share a single in-memory MCP server instance and a reusable SSE
registry so multiple clients can connect simultaneously.

## Getting Started

### Install Gleam

Install the Gleam toolchain before running the project:

```sh
# macOS (Homebrew)
brew install gleam

# Linux (asdf)
asdf plugin add gleam
```

See <https://gleam.run/getting-started/installing/> for additional options and
platform-specific guidance.

```sh
gleam deps download
```

Create a `.env` file (optional) to override defaults:

```
SECRET_KEY_BASE=some-long-secret
PORT=8000
```

Run the Mist HTTP server:

```sh
gleam run
```

You should see a log entry similar to `DataJourney MCP server listening on
port 8000`. The health endpoint responds with `GET /health`.

### MCP Testing Helpers

With the server running (`gleam run`), you can exercise MCP endpoints via the
utility scripts in `scripts/`:

- `./scripts/read_resource.sh [resource_uri]` streams a `resources/read`
  request. Override `HOST`, `PORT`, or `REQUEST_ID` via environment variables to
  target different deployments.
- `./scripts/list_resources.sh` issues `resources/list`. Set `CURSOR` if you
  need to paginate through longer lists.


## Talking to the MCP Server

### SSE Transport

1. `GET /mcp/sse` to establish an event stream. The response includes an
   `X-Conn-Id` header.
2. `POST /mcp/sse?id=<value>` with JSON-RPC payloads to send MCP messages.
   Responses are delivered both in the HTTP response body and streamed as SSE
   events named `mcp-message`.

### WebSocket Transport

Upgrade a WebSocket connection at `ws://localhost:8000/mcp/ws` and exchange
JSON-RPC payloads as plain-text frames. Each inbound message is forwarded to the
MCP server; responses are emitted back to the client.

## Project Layout

```
src/
├── datajourney_mcp.gleam   # Application entrypoint and Mist bootstrapping
├── mcp_server.gleam        # MCP server builder and documentation resource handler
├── router.gleam            # Mist request routing and transport glue
└── types.gleam             # Runtime/Startup context definitions
```

## Development

```sh
gleam format
gleam test
```

Extend `mcp_server.gleam` with new tools, prompts, or resources to broaden the
DataJourney experience exposed through MCP.

## Container Workflow

The repository includes a `Dockerfile` targeting the official Gleam Erlang
image so you can bundle the MCP server for deployments where installing Gleam
directly is inconvenient. The container runs `gleam run` by default and exposes
port `8080`; set `PORT` in the environment if you want the application to listen
elsewhere.

For local testing, the `Makefile` wraps a few common Docker commands:

```sh
make build             # Build the container image (defaults to datajourney_mcp)
make run PORT=8000     # Run the container and publish the chosen port
make stop              # Stop an existing container named datajourney_mcp
make clean             # Remove the container and image artifacts
```

Override `DOCKER`, `IMAGE_NAME`, `CONTAINER_NAME`, or `PORT` to suit your
environment (e.g. `DOCKER=podman make run`).
