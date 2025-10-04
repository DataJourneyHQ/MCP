import dotenv_conf
import gleam/erlang/process
import gleam/int
import gleam/io
import mcp_server
import mcp_toolkit/transport/sse
import mist
import router
import types.{RuntimeContext, StartupContext}

pub fn main() -> Nil {
  use file <- dotenv_conf.read_file(".env")

  let startup_context =
    StartupContext(
      secret_key_base: dotenv_conf.read_string_or("SECRET_KEY_BASE", file, ""),
      port: dotenv_conf.read_int_or("PORT", file, 8000),
    )

  let server = mcp_server.build()
  let registry = sse.start_registry()

  let runtime_context =
    RuntimeContext(mcp_server: server, sse_registry: registry)
  let handler = fn(req) { router.handle_request(req, runtime_context) }

  case
    mist.new(handler)
    |> mist.port(startup_context.port)
    |> mist.bind("0.0.0.0")
    |> mist.start
  {
    Ok(_) -> {
      io.println(
        "DataJourney MCP server listening on port "
        <> int.to_string(startup_context.port),
      )
      process.sleep_forever()
    }
    Error(_) -> io.println("Failed to start DataJourney MCP server")
  }
}
