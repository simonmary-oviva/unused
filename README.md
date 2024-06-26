# unused

Lists all unused localization keys in a frontend project.
If a i18n.csv is specified, it will scan if the keys are used anywhere in the source code.

If a hook file is specified, it will print the unused hook params.
E.g. if hook file returns `patientsTableTitle: t('table.patientsTitle')` and patientsTableTitle is not used, it will print this out

```sh
./unused [i18n.csv OR hook file like useLocaleTranslation] [src directory]
```

<img width="1129" alt="image" src="https://github.com/simonmary-oviva/unused/assets/112623456/08a78163-56ab-4bec-a7ad-4e8c7e46cd5a">


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
