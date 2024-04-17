import gleam/io
import gleam/result
import gleam/string
import gleam/list
import simplifile
import file_streams/read_text_stream.{type ReadTextStream}
import file_streams/read_stream_error
import argv

fn get_key(line: String) -> #(String, String) {
  let key = string.split_once(line, ",")
  let default = #("", "")
  case key {
    Ok(key) -> key
    Error(_) -> default
  }
}

fn parse_key(line: String) -> String {
  let #(key_raw, _) = get_key(line)

  key_raw
  |> string.replace("\"", "")
}

fn collect_keys(rts: ReadTextStream, keys: List(String)) {
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
    Ok(_) -> collect_keys(rts, updated)
  }
}

fn get_keys_from_file(filepath: String) {
  let assert Ok(rts) = read_text_stream.open(filepath)
  let keys = collect_keys(rts, [])
  let _ = read_text_stream.close(rts)
  keys
}

fn walk_dir(path: String, files: List(String)) -> List(String) {
  let assert Ok(is_path_dir) = simplifile.verify_is_directory(path)
  case is_path_dir {
    True ->
      get_filepaths_from_dir(path)
      |> collect_files(files)

    False -> [path, ..files]
  }
}

fn collect_files(elements: List(String), all: List(String)) -> List(String) {
  case elements {
    [first, ..rest] -> collect_files(rest, walk_dir(first, all))
    [] -> all
  }
}

fn prepend_path(
  directory_elements: List(String),
  dir_path: String,
) -> List(String) {
  list.map(directory_elements, fn(e) { dir_path <> "/" <> e })
}

fn get_filepaths_from_dir(dir: String) -> List(String) {
  let assert Ok(files) = simplifile.read_directory(dir)
  prepend_path(files, dir)
}

fn get_file_content(filepath: String) -> String {
  let file = simplifile.read(filepath)
  case file {
    Ok(content) -> content
    _ -> ""
  }
}

fn is_key_in_file(key: String, filepath: String) -> Bool {
  let file_content = get_file_content(filepath)
  string.contains(file_content, key)
}

fn is_key_in_files(
  key: String,
  files: List(String),
  all: List(String),
) -> List(String) {
  case list.any(files, fn(path) { is_key_in_file(key, path) }) {
    False -> [key, ..all]
    _ -> all
  }
}

fn collect_unused(
  keys: List(String),
  files: List(String),
  all: List(String),
) -> List(String) {
  case keys {
    [first, ..rest] ->
      collect_unused(rest, files, is_key_in_files(first, files, all))
    [] -> all
  }
}

fn runner(i18n_file: String, src_dir: String) -> Nil {
  let keys = get_keys_from_file(i18n_file)
  let all_files = walk_dir(src_dir, list.new())
  let filtered = list.filter(all_files, fn(f) { !string.contains(f, "i18n") })
  let unused = collect_unused(keys, filtered, list.new())
  let assert Ok(all) =
    list.reduce(unused, fn(acc, curr) { acc <> "\n " <> curr })
  io.println(all)
}

pub fn main() {
  case argv.load().arguments {
    [i18n_file, src_dir] -> runner(i18n_file, src_dir)
    _ -> io.println("Usage: ./unused [I18N_FILE] [SRC_DIR]")
  }
}
