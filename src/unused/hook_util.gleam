import gleam/string

pub fn parse_key(line: String) -> String {
  let #(key_raw, _) = {
    let valid_line_str = case string.contains(line, " t(") {
      True -> line
      _ -> ""
    }
    let key = string.split_once(valid_line_str, ":")
    let default = #("", "")
    case key {
      Ok(key) -> key
      Error(_) -> default
    }
  }
  key_raw
  |> string.trim
}
