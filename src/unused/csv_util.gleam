import gleam/string

pub fn parse_key(line: String) -> String {
  let #(key_raw, _) = {
    let key = string.split_once(line, ",")
    let default = #("", "")
    case key {
      Ok(key) -> key
      Error(_) -> default
    }
  }
  key_raw
  |> string.replace("\"", "")
}
