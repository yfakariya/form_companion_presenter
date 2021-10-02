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
3. Run `melos bootstrap` in this (repository root) directory.
4. Open this (repository root) directory in your favorite IDE.

### Lint

This project uses customized [pedantic mono](https://github.com/mono0926/pedantic_mono/).
Please ensure your contribution does not introduce additional warnings except `TODO` which is TODO item you will resolve in future contribution :)

### Test

* Add reproducing test if you find a bug and fix it.
* Add a set of unit tests and optional widget tests when you add new feature.
  * You should add example in `/example` directory if you add new features to describe it for users and verify its effectivity for yourself.

### Commit

Ensure you use [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) in your message. Because we use melos to create changelog, it requires conventional commits format.

### Documentation

Many of us are not native English speaker, many of us are not expert of foreign language, and so many of us are not technical writer. So, documents and comments may include many bugs (grammer, spelling, etc) and wrong expressions. So it is welcome to PR to fix them.

### References

There are some design docs in `/doc` directory.

### Tips for run pub commands

#### Run melos scripts

`fvm flutter pub global run <command>` in root directory.

Note that any scripts in `melos.yaml` commands should not include `fvm`, which causes bizzare error like "Could not find a file named 'pubspec.yaml' in...".

#### Pub upgrade

Do not use 'flutter pub upgrade'. Do as following instead:

1. Run `fvm flutter pub global run melos exec -- flutter pub outdated` in the root directory.
2. Update `pubspec.yaml` manually in each packages and examples as above `flutter pub outdated` results.
3. Run `fvm flutter pub global run melos bs` in the root directory.

However, sometimes, such as running build_runner, flutter complains that pubspec.lock and pubspec.yaml are not synchronized. In addition, flutter widget tester automatically run `pub get` in target directory, it may cause wrong dependecy resolution.
So, if you hit synchronization problem, or run widget test in the package, you have to tweak pubspec.yaml termporary and run pub get in **each package**.

1. Move to target package or example project directory.
2. Add or uncomment `dependency_overrides:` with path reference in `pubspec.yaml`.
3. Run `fvm flutter pub get` and ensure success.
4. Run `fvm flutter pub run <anything>` or run widget test.
    * You can uncomment logging for some widget testing for diagnostics.
5. Comment `dependency_overrides:` in `pubspec.yaml`
    * You must comment logging for some widget testing if you uncomment them.

### Code generation

`example` project uses some code generation for localization and state management.

#### freezed

We use [freezed](https://pub.dev/packages/freezed) to help state management of example application. It generates pattern matching methods, constructors, and properties. If you update "state" class which has companion part file named `.freezed.dart`, you must re-run `freezed` as following:

```shell
fvm flutter pub run build_runner build --delete-conflicting-outputs
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

#### libraries in example

We use [riverpod](https://pub.dev/packages/riverpod) and [state notifier](https://pub.dev/packages/state_notifier) to implement examples.
