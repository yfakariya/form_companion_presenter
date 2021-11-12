# How to contribute this project

## General

* Check again you truly want to file a new issue for this repository. There are many repositories in GitHub :)
* Search existing issues before you submit a new issue.
* It is welcome to file new issue with bugs, feature requests, or documentation fixes.
* Use English except pasted your actual output to report issues and PRs.
* Be professional. Remember your familier project's CoC.

## How to develop your own patch

### Setup

This project depends on [melos](https://melos.invertase.dev/) and [fvm](https://fvm.app/), so you have to set up these tools first.

1. Setup `fvm` as [official docs](https://fvm.app/docs/getting_started/installation).
    * Note that `PATH` order is important on Windows. See [issue #227](https://github.com/leoafarias/fvm/issues/227#issuecomment-811592228) for details.
2. Setup `melos` as [official docs](https://melos.invertase.dev/getting-started#installation).
3. Setup `grinder` with `fvm flutter pub global activate grinder`.
4. Run `melos bootstrap` in this (repository root) directory.
5. Move to `tool/dev_env` directory.
6. Run `grind` command.
7. Open this (repository root) directory in your favorite IDE.

### Lint

This project uses customized [pedantic mono](https://github.com/mono0926/pedantic_mono/).
Please ensure your contribution does not introduce additional warnings except `TODO` which is TODO item you will resolve in future contribution :)

### Test

* Add reproducing test if you find a bug and fix it.
* Add a set of unit tests and optional widget tests when you add new feature.
  * You should add example in `/example` directory if you add new features to describe it for users and verify its effectivity for yourself.

### Commit

Ensure you use [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) in your message. Because we use melos to create changelog, it requires conventional commits format.

### Prepare push

**CAUTION** Before push your change to the origin and make PR, you must revert your local setup made by grinder.

1. Move to `tool/dev_env` directory.
2. Run `grind prepare-publish` command.
    * This script runs following tasks:
        1. Code formatting for `*.dart` files except `*.g.dart`, `*.freezed.dart`, and `.**/**/*.dart`.
        2. Run `grind assemble` in projects under `examples/`.
        3. Run `grind distrubute` in projects under `examples/`.
        4. Run code analysis with `melos run analyze` for all projects.
        5. Run unit testings and widget testings with `melos run test` for all projects.
        6. Reverts `pubspec.yaml` tweaks done by `grind` in bootstrap.
        7. Re-run `melos bootstrap` to verify reverted configuration.


### Documentation

Many of us are not native English speaker, many of us are not expert of foreign language, and so many of us are not technical writer. So, documents and comments may include many bugs (grammer, spelling, etc) and wrong expressions. So it is welcome to PR to fix them.

## References

There are some design docs in `/doc` directory.

## Miscs

### Tips for run pub commands

#### Run melos scripts

`fvm flutter pub global run <command>` in root directory.

Note that any scripts in `melos.yaml` commands should not include `fvm`, which causes bizzare error like "Could not find a file named 'pubspec.yaml' in...".

### Code generation

`example` project uses some code generation for localization and state management.

#### freezed

We use [freezed](https://pub.dev/packages/freezed) to help state management of example application. It generates pattern matching methods, constructors, and properties. If you update "state" class which has companion part file named `.freezed.dart`, you must re-run `freezed` as following:

```shell
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

or just run following melos script in repository root:

```shell
fvm flutter pub global run melos run build_runner
```

You can run `build_runner` in background as following:

```shell
fvm flutter pub run build_runner watch
```

Note that `freezed` fails to generate code if your modifying code have syntactic error to prevent code analysis.

#### easy_localization

We use [easy localization](https://pub.dev/packages/easy_localization) to add localization. We choose code generation for l10n resource loading instead of assets.

We adopt some rules as following:

* We put generated code in `lib/l10n` directory.
* We adopt file naming conventions.
  * `codegen_loader.g.dart` (default) for `CodegenLoader` class and its constants (strings from json).
  * `locale_keys.g.dart` for `LocaleKeys` which defines constants for localized message keys.
* We put source json l10n resource in `resources/l10n` directory. And their names are `{language-code}.json`.
  * We cannot create regional l10n resources like `en-us` or `en-gb` because we do not want to put our time to refine example L10N. We are sorry if you feel uncomfortable for it.

Run following command to generate `codegen_loader.g.dart`.

```shell
fvm flutter pub run easy_localization:generate -O lib/l10n -f json
```

Run following command to generate `locale_keys.g.dart`.

```shell
fvm flutter pub run easy_localization:generate -O lib/l10n -f keys -o locale_keys.g.dart
```

or just run following melos script in repository root, this script generates both of  `codegen_loader.g.dart` and `locale_keys.g.dart`:

```shell
fvm flutter pub global run melos run easy_localization
```

#### libraries in example

We use [riverpod](https://pub.dev/packages/riverpod) and [state notifier](https://pub.dev/packages/state_notifier) to implement examples.
