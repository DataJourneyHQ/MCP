Here's a streamlined version:

# Contributing to DataJourney MCP

## Code of Conduct

We follow the [Contributor Covenant](CODE_OF_CONDUCT.md). Report violations to contact@datajourneyhq.com.

## How to Contribute

- **Issues**: Report bugs with reproduction steps, environment details, and relevant logs. Specify which transport you used (`/mcp`, `/mcp/sse`, `/mcp/ws`).
- **Pull requests**: Propose features or fixes on a feature branch.
- **Documentation**: Improve README, scripts, or examples.

## Setup

1. Fork and create a feature branch: `git checkout -b feature/my-change`
2. Install Gleam: `brew install gleam` or use asdf
3. Install dependencies: `gleam deps download`
4. (Optional) Create `.env` with `SECRET_KEY_BASE` and `PORT`
5. Run: `gleam run` (defaults to port 8000)

Container workflow: Use the `Makefile` with the included `Dockerfile`.

## Project Structure

- `src/datajourney_mcp.gleam` - Server bootstrap
- `src/router.gleam` - HTTP routing
- `src/mcp_server.gleam` - MCP resources and tools
- `test/` - Tests mirror `src/` structure
- Use snake_case filenames, 4-space formatting

## Workflow

1. Write code on a feature branch
2. Add tests in `test/` covering success and error cases
3. Run checks:
   ```sh
   gleam format
   gleam test
   ```
4. Test manually if needed:
   ```sh
   gleam run
   ./scripts/read_resource.sh
   ./scripts/list_resources.sh
   ```
5. Commit with clear messages, link issues when relevant

## Pull Requests

- Rebase on `main` before opening
- Describe what changed, why, and how you tested it
- Document new configuration requirements

## Security

Report security issues privately to contact@datajourneyhq.com per [SECURITY.md](SECURITY.md).
