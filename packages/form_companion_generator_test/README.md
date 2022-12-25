This is not a real package
===

This is a dummy package to host sources for testing of form_companion_generator package, and integration tests.

Usage
---

Run `fvm flutter pub global run grinder` when `form_companion_generator` or dependent `flutter_form_builder` is updated.

How to debug the generator in context of build_runner
---

1. Configure debug settings for your development environment. If you use VSCode, add launch settings like following:

```json
{
    "name": "form_companion_generator_test (build_runner debug mode)",
    "cwd": "packages\\form_companion_generator_test",
    "request": "launch",
    "type": "dart",
    "program": ".dart_tool/build/entrypoint/build.dart",
    "args": ["build", "-d"]
}
```

Note:

* `cwd` is relative from the workspace.
* `request` must be `launch` instead of `attach`. You can attach debugger with general "Run with Debug" command of VSCode.
* `args` should be same as `dart pub run build_runner`. Run `dart pub run build_runner --help` to check other options.

2. Run `dart pub run build_runner` (you can use `flutter` instead of `dart` if you like) in this project root (same as `cwd` value). The command will make `.dart_tool/build/entrypoint/build.dart`.

3. Run this project with the configuration which you added.

