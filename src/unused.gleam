import gleam/io
import gleam/string
import gleam/list
import simplifile
import argv
import unused/csv_util
import unused/hook_util
import unused/keys

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

fn parse_key_list(keys: List(String)) -> String {
  let assert Ok(all) = list.reduce(keys, fn(acc, curr) { acc <> "\n" <> curr })
  all
}

fn runner(key_file: String, src_dir: String) -> Nil {
  let parse_key = case string.contains(key_file, ".csv") {
    True -> csv_util.parse_key
    False -> hook_util.parse_key
  }

  let keys = keys.get_keys_from_file(key_file, parse_key)
  let all_files = walk_dir(src_dir, list.new())
  let filtered =
    list.filter(all_files, fn(f) {
      !string.contains(f, "i18n.csv") && !string.contains(f, key_file)
    })
  let unused = collect_unused(keys, filtered, list.new())
  case unused {
    [] -> "There are no unused keys"
    _ -> parse_key_list(unused)
  }
  |> io.println
}

pub fn main() {
  case argv.load().arguments {
    [i18n_file, src_dir] -> runner(i18n_file, src_dir)
    _ -> io.println("Usage: ./unused [I18N_FILE/LOCALIZATION_HOOK] [SRC_DIR]")
  }
}
