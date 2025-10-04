# Repository Guidelines

## Project Structure & Module Organization
The Gleam application lives in `src/`, with `datajourney_mcp.gleam` bootstrapping Mist, `mcp_server.gleam` defining MCP tools, `router.gleam` wiring HTTP/SSE/WebSocket routes, and `types.gleam` sharing runtime types. Keep new transport code alongside `router.gleam`, and place reusable helpers in new modules under `src/`. Tests belong in `test/` using mirrored filenames (e.g., `test/router_test.gleam`). Generated artifacts land in `build/`; avoid committing edits there.

## Build, Test, and Development Commands
Run `gleam deps download` after pulling new dependencies. Use `gleam run` to start the Mist server; override `PORT` via `.env` when needed. Format code with `gleam format` before sending patches. Execute `gleam test` to run the `gleeunit` suite, or `gleam test --target erlang` when debugging BEAM output.

## Coding Style & Naming Conventions
Adopt the formatter's output (4-space indentation, trailing newline). Modules and functions use `snake_case`; exposed constants should share that pattern. Custom types and constructors follow `PascalCase`. Keep public APIs well-documented with `///` comments, and group related functions together. Prefer pattern matching and immutable updates to mutable state.

## Testing Guidelines
Write unit tests with `gleeunit` in files ending `_test.gleam`. Name test functions `test_<behavior>` and describe assertions clearly. Cover new transports and resource handlers with both happy-path and error cases. When adding external HTTP interactions, stub them in helper modules so tests stay deterministic. Run `gleam test` locally before pushing.

## Commit & Pull Request Guidelines
There is no established history yet, so start commits with a short imperative summary (≤50 chars), followed by wrapped body text explaining context and follow-up steps. Reference issue numbers (`Closes #12`) when applicable. Pull requests should outline the change, the surfaced MCP capability, and verification steps (`gleam test`, manual curl). Include screenshots or logs for client-facing changes.

## Environment & Configuration
Use a local `.env` for secrets; define `SECRET_KEY_BASE` for signed sessions and `PORT` to avoid clashes. Never commit `.env`. Document new required variables in README updates and mention defaults in PR notes.
