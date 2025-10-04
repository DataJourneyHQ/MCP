import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/option.{None, Some}
import gleam/result
import mcp_toolkit
import mcp_toolkit/core/protocol as mcp

pub const documentation_uri = "https://github.com/DataJourneyHQ/DataJourney/blob/main/README.md"

const documentation_fetch_uri = "https://raw.githubusercontent.com/DataJourneyHQ/DataJourney/main/README.md"

const documentation_resource = mcp.Resource(
  annotations: None,
  description: Some("DataJourney product documentation"),
  mime_type: Some("text/markdown"),
  name: "datajourney-documentation",
  size: None,
  uri: documentation_uri,
)

pub fn build() -> mcp_toolkit.Server {
  mcp_toolkit.new("DataJourney MCP", "1.0.0")
  |> mcp_toolkit.resource_capabilities(False, False)
  |> mcp_toolkit.add_resource(documentation_resource, handle_resource)
  |> mcp_toolkit.build()
}

pub fn handle_resource(
  request: mcp.ReadResourceRequest,
) -> Result(mcp.ReadResourceResult, String) {
  handle_resource_with(fetch_documentation, request)
}

pub fn handle_resource_with(
  fetch: fn() -> Result(String, String),
  request: mcp.ReadResourceRequest,
) -> Result(mcp.ReadResourceResult, String) {
  case request.uri == documentation_uri {
    True -> {
      use text <- result.try(fetch())
      mcp.ReadResourceResult(meta: None, contents: [
        mcp.TextResourceContents(
          mime_type: Some("text/markdown"),
          text: text,
          uri: documentation_uri,
        )
        |> mcp.TextResource,
      ])
      |> Ok
    }
    False -> Error("Unknown resource")
  }
}

fn fetch_documentation() -> Result(String, String) {
  use req <- result.try(
    request.to(documentation_fetch_uri)
    |> result.map_error(fn(_) {
      "Unable to read documentation: Invalid documentation URI"
    }),
  )

  let req =
    req
    |> request.set_header("accept", "text/markdown, text/plain")

  let config =
    httpc.configure()
    |> httpc.follow_redirects(True)

  use response <- result.try(
    httpc.dispatch(config, req)
    |> result.map_error(fn(error) {
      "Unable to read documentation: " <> describe_http_error(error)
    }),
  )

  case response.status {
    200 -> Ok(response.body)
    status ->
      Error(
        "Unable to read documentation: Received status "
        <> int.to_string(status),
      )
  }
}

fn describe_http_error(error: httpc.HttpError) -> String {
  case error {
    httpc.InvalidUtf8Response -> "Invalid UTF-8 response"
    httpc.ResponseTimeout -> "Timed out waiting for response"
    httpc.FailedToConnect(ip4, ip6) ->
      "Failed to connect (IPv4: "
      <> describe_connect_error(ip4)
      <> ", IPv6: "
      <> describe_connect_error(ip6)
      <> ")"
  }
}

fn describe_connect_error(error: httpc.ConnectError) -> String {
  case error {
    httpc.Posix(code) -> code
    httpc.TlsAlert(code, detail) -> code <> ": " <> detail
  }
}
