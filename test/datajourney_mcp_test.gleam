import gleam/option.{Some}
import gleeunit
import gleeunit/should
import mcp_server
import mcp_toolkit/core/protocol as mcp

pub fn main() {
  gleeunit.main()
}

pub fn read_resource_uses_supplied_fetcher_test() {
  let request = mcp.ReadResourceRequest(uri: mcp_server.documentation_uri)
  let expected = "# DataJourney\n"
  let fetcher = fn() { Ok(expected) }
  let result = should.be_ok(mcp_server.handle_resource_with(fetcher, request))

  case result.contents {
    [content] ->
      case content {
        mcp.TextResource(mcp.TextResourceContents(text:, mime_type:, ..)) -> {
          should.equal(text, expected)
          should.equal(mime_type, Some("text/markdown"))
        }
        _ -> should.fail()
      }
    _ -> should.fail()
  }
}
