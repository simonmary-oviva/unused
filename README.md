# unused

Lists all unused localization keys in a frontend project.
If a i18n.csv is specified, it will scan if the keys are used anywhere in the source code.

If a hook file is specified, it will print the unused hook params.
E.g. if hook file returns `patientsTableTitle: t('table.patientsTitle')` and patientsTableTitle is not used, it will print this out

```sh
./unused [i18n.csv OR hook file like useLocaleTranslation] [src directory]
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
