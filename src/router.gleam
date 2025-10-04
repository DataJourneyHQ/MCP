import gleam/bit_array
import gleam/bytes_tree
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/json
import gleam/option
import gleam/result
import gleam/string
import mcp_toolkit
import mcp_toolkit/transport/sse
import mcp_toolkit/transport/websocket
import mist
import types.{type RuntimeContext}

pub fn handle_request(
  req: request.Request(mist.Connection),
  ctx: RuntimeContext,
) -> response.Response(mist.ResponseData) {
  case request.path_segments(req) {
    [] -> text_response(200, "ok")
    ["health"] -> json_response(200, "{\"status\":\"ok\"}")
    ["mcp", "ws"] -> websocket.handle(req, ctx.mcp_server)
    ["mcp", "sse"] -> handle_sse(req, ctx)
    ["mcp"] -> handle_http_rpc(req, ctx)
    _ -> text_response(404, "not found")
  }
}

fn handle_http_rpc(
  req: request.Request(mist.Connection),
  ctx: RuntimeContext,
) -> response.Response(mist.ResponseData) {
  case req.method {
    http.Post -> process_rpc(req, ctx)
    _ -> method_not_allowed(["POST"])
  }
}

fn process_rpc(
  req: request.Request(mist.Connection),
  ctx: RuntimeContext,
) -> response.Response(mist.ResponseData) {
  case mist.read_body(req, 1_000_000) {
    Ok(read_req) -> {
      let body =
        bit_array.to_string(read_req.body)
        |> result.unwrap("")

      case mcp_toolkit.handle_message(ctx.mcp_server, body) {
        Ok(option.Some(json)) | Error(json) ->
          json_response(200, json.to_string(json))
        Ok(option.None) ->
          response.new(204)
          |> response.set_body(mist.Bytes(bytes_tree.new()))
      }
    }
    Error(_) -> text_response(400, "invalid body")
  }
}

fn handle_sse(
  req: request.Request(mist.Connection),
  ctx: RuntimeContext,
) -> response.Response(mist.ResponseData) {
  case req.method {
    http.Get -> sse.handle_get(req, ctx.sse_registry)
    http.Post -> sse.handle_post(req, ctx.sse_registry, ctx.mcp_server)
    _ -> method_not_allowed(["GET", "POST"])
  }
}

fn method_not_allowed(
  allowed: List(String),
) -> response.Response(mist.ResponseData) {
  response.new(405)
  |> response.set_header("Allow", string_join(allowed))
  |> response.set_body(mist.Bytes(bytes_tree.from_string("method not allowed")))
}

fn text_response(
  status: Int,
  body: String,
) -> response.Response(mist.ResponseData) {
  response.new(status)
  |> response.set_header("Content-Type", "text/plain")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

fn json_response(
  status: Int,
  body: String,
) -> response.Response(mist.ResponseData) {
  response.new(status)
  |> response.set_header("Content-Type", "application/json")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

fn string_join(values: List(String)) -> String {
  string.join(values, ", ")
}
