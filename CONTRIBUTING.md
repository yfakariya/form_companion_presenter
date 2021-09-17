# How to contribute this project

## General

* Check again you truly want to file a new issue for this repository. There are many repositories in GitHub :)
* Search existing issues before you submit a new issue.
* It is welcome to file new issue with bugs, feature requests, or documentation fixes.

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

### References

There are some design docs in `/doc` directory.
