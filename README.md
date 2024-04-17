# unused

Lists all unused localization keys in a frontend project

```sh
./unused [i18n csv file] [src directory]
```

## Build

```sh
# Compile to an escript
gleam run -m gleescript

# Make escript executable
chmod +x ./unused
```

If you don't have gleam installed for building, install it via homebrew

```sh
brew update
brew install gleam
```
