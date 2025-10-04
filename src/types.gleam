import gleam/erlang/process.{type Subject}
import mcp_toolkit
import mcp_toolkit/transport/sse

pub type RuntimeContext {
  RuntimeContext(
    mcp_server: mcp_toolkit.Server,
    sse_registry: Subject(sse.RegistryMsg),
  )
}

pub type StartupContext {
  StartupContext(secret_key_base: String, port: Int)
}
