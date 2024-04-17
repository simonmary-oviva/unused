import gleam/string
import gleam/result
import file_streams/read_text_stream.{type ReadTextStream}
import file_streams/read_stream_error

fn collect_keys(
  rts: ReadTextStream,
  parse_key: fn(String) -> String,
  keys: List(String),
) {
  let line = read_text_stream.read_line(rts)
  let unwrapped = result.unwrap(line, "")
  let key = parse_key(unwrapped)
  let updated = case string.is_empty(key) {
    True -> keys
    _ -> [key, ..keys]
  }
  case line {
    Error(read_stream_error.EndOfStream) -> updated
    Error(_) -> updated
    // todo: proper error handling
    Ok(_) -> collect_keys(rts, parse_key, updated)
  }
}

pub fn get_keys_from_file(filepath: String, parse_key: fn(String) -> String) {
  let assert Ok(rts) = read_text_stream.open(filepath)
  let keys = collect_keys(rts, parse_key, [])
  let _ = read_text_stream.close(rts)
  keys
}
