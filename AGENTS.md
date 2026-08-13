# AGENTS.md

Guidance for coding agents working in this repository.

## What this is

`flutter_adaptive_layout` — a published pub.dev package (see `homepage` in `pubspec.yaml`) that picks a widget layout based on the device's screen size. The whole library is four files under `lib/`; `example/` is a standalone Flutter app depending on the package via a `path:` reference.

## Commands

```shell
flutter pub get            # from the root; also resolves example/
flutter analyze            # analyzes both the package and example/
cd example && flutter run  # the only runnable app in the repo
cd example && flutter test # the only test suite (default counter smoke test)
flutter pub publish --dry-run
```

There is no test directory for the package itself, and no CI. `example/test/widget_test.dart` is the unmodified Flutter counter template test; run a single case with `flutter test test/widget_test.dart -n "<name>"`.

### Known pre-existing failure

`example/lib/home_page.dart:61` uses `TextTheme.headline4`, removed from Flutter after this repo was last touched. Both `flutter analyze` and `cd example && flutter test` fail on it today (analyze: 1 error; test: compilation failure). This is unrelated to any change you make — do not assume your edit broke the build, and fix it separately (`headlineMedium`) if asked. `flutter analyze lib` is clean and is the reliable signal for changes to the package itself.

## Architecture

Everything flows through one decision: `AdaptiveLayout.build` asks a `ScreenSizeQualifier` for a `ScreenSize`, then calls the matching builder.

- `lib/layout/adaptive_layout.dart` — `AdaptiveLayout`, a `StatelessWidget`. Resolves `smallBuilder`/`mediumBuilder`/`largeBuilder` with a `builder?.call(context, child) ?? child` fallback, and throws `UnimplementedError` when both the matched builder and `child` are null. `child` is built once and handed to whichever builder wins, so builders wrap rather than rebuild it.
- `lib/qualifiers/screen_size_qualifier.dart` — the extension point. Any custom sizing strategy implements `ScreenSize qualify(BuildContext)` and is passed as `AdaptiveLayout.qualifier`.
- `lib/qualifiers/breakpoints_qualifier.dart` — default qualifier plus `BreakpointsSetting`, an `InheritedWidget` for tree-wide overrides.
- `lib/flutter_adaptive_layout.dart` — the barrel. It is the only public entrypoint; a new public type is invisible to consumers until exported here.

### Breakpoint resolution order

`BreakpointsQualifier.qualify` layers three sources, first non-null wins:

1. `smallBreakpoint` / `mediumBreakpoint` passed to the `BreakpointsQualifier` constructor
2. the nearest ancestor `BreakpointsSetting` (via `dependOnInheritedWidgetOfExactType`)
3. the private `_defaultSmallBreakpoint` = 400 / `_defaultMediumBreakpoint` = 600

Comparison is against `MediaQuery.of(context).size.shortestSide` and uses `<=`, so a breakpoint value belongs to the *smaller* bucket. Using `shortestSide` is deliberate: rotating a device does not reclassify it.

Note that `AdaptiveLayout` constructs a fresh `BreakpointsQualifier()` on every build when no `qualifier` is given — qualifiers must stay cheap and stateless.

## Conventions

- Imports inside `lib/` use absolute `package:flutter_adaptive_layout/...` paths, not relative ones. Match that.
- Every public member carries a `///` doc comment referencing related types in `[Brackets]` — these render on pub.dev, so new public API needs them.
- A user-visible change means four coordinated edits, as the git history shows: the code, a new section at the top of `CHANGELOG.md`, a `version:` bump in `pubspec.yaml`, and the matching snippet in `README.md`.
- README image links point at raw GitHub URLs under `img/` because pub.dev cannot resolve repo-relative paths.
