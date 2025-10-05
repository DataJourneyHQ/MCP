import gleam/http/request
import gleam/http/response
import mcp_toolkit/transport/rpc
import mcp_toolkit/transport/sse
import mcp_toolkit/transport/util
import mcp_toolkit/transport/websocket
import mist
import types.{type RuntimeContext}

pub fn handle_request(
  req: request.Request(mist.Connection),
  ctx: RuntimeContext,
) -> response.Response(mist.ResponseData) {
  case request.path_segments(req) {
    [] -> util.json_response(200, "{\"status\":\"ok\"}")
    ["health"] -> util.json_response(200, "{\"status\":\"ok\"}")
    ["mcp", "ws"] -> websocket.handle(req, ctx.mcp_server)
    ["mcp", "sse"] -> sse.handle_sse(req, ctx.sse_registry, ctx.mcp_server)
    ["mcp"] -> rpc.handle_http_rpc(req, ctx.mcp_server, 1_000_000)
    _ -> util.json_response(404, "{\"error\":\"not_found\"}")
  }
}
