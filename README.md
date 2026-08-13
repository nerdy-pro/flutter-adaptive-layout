# flutter_adaptive_layout — Responsive & Adaptive Layouts for Flutter

[![Pub Version](https://img.shields.io/pub/v/flutter_adaptive_layout)](https://pub.dev/packages/flutter_adaptive_layout)
[![Pub Likes](https://img.shields.io/pub/likes/flutter_adaptive_layout)](https://pub.dev/packages/flutter_adaptive_layout)
[![Pub Points](https://img.shields.io/pub/points/flutter_adaptive_layout)](https://pub.dev/packages/flutter_adaptive_layout/score)
[![License](https://img.shields.io/github/license/nerdy-pro/flutter-adaptive-layout)](https://github.com/nerdy-pro/flutter-adaptive-layout/blob/main/LICENSE)

**flutter_adaptive_layout is a Flutter package that builds a different widget layout for small, medium, and large screens.** Wrap a widget in `AdaptiveLayout`, give it one builder per screen size, and the package measures the device with `MediaQuery`, applies your breakpoints, and renders the matching variant — one responsive UI that fits phones, tablets, and desktops.

```dart
AdaptiveLayout(
  smallBuilder: (context, child) => child!,          // phone
  mediumBuilder: (context, child) => Center(child: child),  // tablet
  largeBuilder: (context, child) => Row(children: [const Sidebar(), Expanded(child: child!)]), // desktop
  child: const MyHomePage(),
)
```

## Table of contents

- [Why use it](#why-use-it)
- [Installation](#installation)
- [Quick start](#quick-start)
- [How screen size is decided](#how-screen-size-is-decided)
- [Changing the breakpoints](#changing-the-breakpoints)
- [Writing a custom qualifier](#writing-a-custom-qualifier)
- [API reference](#api-reference)
- [FAQ](#faq)
- [Gallery](#gallery)
- [Compatibility](#compatibility)

## Why use it

- **Screen-size-driven layouts.** Declare `smallBuilder`, `mediumBuilder`, and `largeBuilder` instead of scattering `if (width > 600)` checks through your widget tree.
- **Breakpoints you control.** Defaults are 400 and 600 logical pixels; override them per widget or for the whole app.
- **Build the child once.** The `child` widget is created a single time and passed into whichever builder matches, so switching layouts wraps your content rather than rebuilding it from scratch.
- **Pluggable sizing logic.** Implement `ScreenSizeQualifier` to classify screens however your design system does.
- **No dependencies.** Pure Flutter, built on `MediaQuery` — works on iOS, Android, web, macOS, Windows, and Linux.

## Installation

Add the package with the Flutter CLI:

```shell
flutter pub add flutter_adaptive_layout
```

Or add it to `pubspec.yaml` directly:

```yaml
dependencies:
  flutter_adaptive_layout: ^1.0.2
```

Then import it:

```dart
import 'package:flutter_adaptive_layout/flutter_adaptive_layout.dart';
```

## Quick start

Wrap the widget whose layout should adapt:

```dart
@override
Widget build(BuildContext context) {
  return AdaptiveLayout(
    smallBuilder: (context, child) => child!,
    mediumBuilder: (context, child) => Center(
      child: Material(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints.tight(const Size.square(400)),
          child: child,
        ),
      ),
    ),
    largeBuilder: (context, child) => Center(
      child: Material(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints.tight(const Size.square(600)),
          child: child,
        ),
      ),
    ),
    child: const MyHomePage(),
  );
}
```

Every builder is optional. If the builder for the current screen size is missing, `AdaptiveLayout` falls back to `child` — so you can style just the sizes you care about:

```dart
AdaptiveLayout(
  largeBuilder: (context, child) => Center(child: SizedBox(width: 600, child: child)),
  child: const ArticleView(), // used as-is on small and medium screens
)
```

If neither a matching builder nor a `child` is provided, `AdaptiveLayout` throws an `UnimplementedError`.

A complete, runnable app lives in the [`/example`](https://github.com/nerdy-pro/flutter-adaptive-layout/tree/main/example) directory.

## How screen size is decided

The default `BreakpointsQualifier` reads `MediaQuery.of(context).size.shortestSide` and compares it against two breakpoints:

| Screen size          | Condition                                     | Default range              | Typical device       |
|----------------------|-----------------------------------------------|----------------------------|----------------------|
| `ScreenSize.small`   | `shortestSide <= smallBreakpoint`             | 0 – 400 logical pixels     | Phones               |
| `ScreenSize.medium`  | `shortestSide <= mediumBreakpoint`            | 401 – 600 logical pixels   | Small tablets        |
| `ScreenSize.large`   | anything above `mediumBreakpoint`             | 601+ logical pixels        | Large tablets, desktop |

Two details worth knowing:

- Comparisons are inclusive (`<=`), so a value exactly equal to a breakpoint belongs to the **smaller** bucket.
- Using `shortestSide` rather than width is deliberate: **rotating a device does not change its screen size classification**, so a phone stays "small" in landscape instead of jumping to a tablet layout.

## Changing the breakpoints

### Per widget

Pass a configured `BreakpointsQualifier` to a single `AdaptiveLayout`:

```dart
AdaptiveLayout(
  qualifier: BreakpointsQualifier(
    smallBreakpoint: 300,
    mediumBreakpoint: 700,
  ),
  smallBuilder: ...,
  mediumBuilder: ...,
  largeBuilder: ...,
  child: ...,
)
```

### For the whole app

Wrap your widget tree in `BreakpointsSetting`, an `InheritedWidget` that every `AdaptiveLayout` below it will read:

```dart
BreakpointsSetting(
  smallScreenBreakpoint: 200,
  mediumScreenBreakpoint: 500,
  child: MaterialApp(...),
)
```

### Which value wins

Breakpoints resolve in this order, first defined value winning:

1. The values passed to `BreakpointsQualifier`'s constructor
2. The nearest ancestor `BreakpointsSetting`
3. The built-in defaults — `400` and `600`

## Writing a custom qualifier

Need to classify by width, by platform, by hinge state, or by anything else? Implement `ScreenSizeQualifier` and hand it to `AdaptiveLayout`:

```dart
class WidthQualifier extends ScreenSizeQualifier {
  @override
  ScreenSize qualify(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return ScreenSize.small;
    if (width < 1024) return ScreenSize.medium;
    return ScreenSize.large;
  }
}

AdaptiveLayout(
  qualifier: WidthQualifier(),
  smallBuilder: ...,
  child: ...,
)
```

`qualify` runs on every build, so keep the implementation cheap and free of side effects.

## API reference

| Type                      | Description                                                                                       |
|---------------------------|---------------------------------------------------------------------------------------------------|
| `AdaptiveLayout`          | Stateless widget that picks and builds a layout for the current screen size.                        |
| `AdaptiveBuilder`         | `Widget Function(BuildContext context, Widget? child)` — the signature of each builder.              |
| `ScreenSize`              | Enum: `small`, `medium`, `large`.                                                                   |
| `ScreenSizeQualifier`     | Abstract class with a single `ScreenSize qualify(BuildContext context)` method. The extension point. |
| `BreakpointsQualifier`    | Default qualifier. Applies `smallBreakpoint` / `mediumBreakpoint` to `MediaQuery` shortest side.     |
| `BreakpointsSetting`      | `InheritedWidget` that overrides the default breakpoints for its subtree.                            |

### `AdaptiveLayout` parameters

| Parameter       | Type                    | Description                                                        |
|-----------------|-------------------------|--------------------------------------------------------------------|
| `child`         | `Widget?`               | Built once, then passed to the matching builder.                     |
| `smallBuilder`  | `AdaptiveBuilder?`      | Layout for `ScreenSize.small`.                                       |
| `mediumBuilder` | `AdaptiveBuilder?`      | Layout for `ScreenSize.medium`.                                      |
| `largeBuilder`  | `AdaptiveBuilder?`      | Layout for `ScreenSize.large`.                                       |
| `qualifier`     | `ScreenSizeQualifier?`  | Sizing strategy. Defaults to `BreakpointsQualifier()`.               |

## FAQ

### How do I make a Flutter layout respond to screen size?

Wrap the widget in `AdaptiveLayout` and provide `smallBuilder`, `mediumBuilder`, and `largeBuilder`. The package reads the device size from `MediaQuery`, maps it to a `ScreenSize`, and builds only the matching variant.

### How do I change the default breakpoints?

Either pass `BreakpointsQualifier(smallBreakpoint: ..., mediumBreakpoint: ...)` to one `AdaptiveLayout`, or wrap your app in `BreakpointsSetting` to change them everywhere. Constructor values take precedence over `BreakpointsSetting`, which takes precedence over the defaults of 400 and 600.

### Does the layout change when the device rotates?

No. Classification uses `MediaQuery.of(context).size.shortestSide`, which stays the same in portrait and landscape. A phone remains `ScreenSize.small` when rotated. To make layouts orientation-sensitive, implement a custom `ScreenSizeQualifier` that reads `size.width` instead.

### What is the difference between this and `LayoutBuilder`?

`LayoutBuilder` reports the constraints handed down by the parent widget, which may be far smaller than the display. `AdaptiveLayout` classifies the **device or window** via `MediaQuery`, so a widget nested deep inside your tree still knows it is running on a tablet. Use `LayoutBuilder` to fit an available box; use `AdaptiveLayout` to choose a layout for the device.

### Do I have to provide all three builders?

No. Any builder can be omitted, and the `child` is used instead for that screen size. Providing neither a builder nor a `child` throws an `UnimplementedError`.

### Does it work on web and desktop?

Yes. It depends only on `MediaQuery`, so it works on every Flutter target. On web and desktop, the measured size is the window, meaning layouts respond as the user resizes the window.

## Gallery

The example app rendered at three screen sizes:

| iPhone 14 (small) | iPad Mini (medium) | iPad Pro 12.9" (large) |
|---|---|---|
| ![flutter_adaptive_layout small screen layout on iPhone 14](https://raw.githubusercontent.com/nerdy-pro/flutter-adaptive-layout/main/img/iphone_14.png) | ![flutter_adaptive_layout medium screen layout on iPad Mini](https://raw.githubusercontent.com/nerdy-pro/flutter-adaptive-layout/main/img/ipad_mini.png) | ![flutter_adaptive_layout large screen layout on iPad Pro 12.9 inch](https://raw.githubusercontent.com/nerdy-pro/flutter-adaptive-layout/main/img/ipad_12_inch.png) |

## Compatibility

| Requirement | Version              |
|-------------|----------------------|
| Dart SDK    | `>=2.18.5 <3.0.0`    |
| Flutter     | `>=1.17.0`           |
| Platforms   | iOS, Android, web, macOS, Windows, Linux |

## Contributing

Issues and pull requests are welcome on [GitHub](https://github.com/nerdy-pro/flutter-adaptive-layout). See [CHANGELOG.md](https://github.com/nerdy-pro/flutter-adaptive-layout/blob/main/CHANGELOG.md) for the release history.

## License

MIT © [Nerdy Pro](https://nerdy.pro). See [LICENSE](https://github.com/nerdy-pro/flutter-adaptive-layout/blob/main/LICENSE).

## About

`flutter_adaptive_layout` is built and maintained by **[Nerdy Pro](https://nerdy.pro)** — a mobile and Flutter development studio. Visit [nerdy.pro](https://nerdy.pro) to see what else we build, or find more of our open source work on [GitHub](https://github.com/nerdy-pro).
