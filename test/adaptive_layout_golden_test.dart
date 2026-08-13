import 'package:flutter/widgets.dart';
import 'package:flutter_adaptive_layout/flutter_adaptive_layout.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests for [AdaptiveLayout].
///
/// Each screen size renders a deliberately different shape so that a golden
/// which picked the wrong [ScreenSize] fails on pixels rather than on subtle
/// spacing. Layouts are built from solid colours only — no text, no Material
/// theming — because glyph metrics and theme defaults drift between Flutter
/// versions and would make these goldens flaky for reasons unrelated to this
/// package.
///
/// Regenerate after an intentional layout change:
///
/// ```shell
/// flutter test --update-goldens
/// ```
void main() {
  group('default breakpoints', () {
    testWidgets('short side below 400 renders the small layout',
        (tester) async {
      await _pumpLayout(tester, surface: const Size(320, 640));

      await expectLater(_root, matchesGoldenFile('goldens/small.png'));
    });

    testWidgets('rotating a phone keeps the small layout', (tester) async {
      // shortestSide is orientation independent, so landscape must not promote
      // this phone to a tablet layout.
      await _pumpLayout(tester, surface: const Size(640, 320));

      await expectLater(
        _root,
        matchesGoldenFile('goldens/small_landscape.png'),
      );
    });

    testWidgets('short side between 400 and 600 renders the medium layout',
        (tester) async {
      await _pumpLayout(tester, surface: const Size(500, 900));

      await expectLater(_root, matchesGoldenFile('goldens/medium.png'));
    });

    testWidgets('short side above 600 renders the large layout',
        (tester) async {
      await _pumpLayout(tester, surface: const Size(800, 1200));

      await expectLater(_root, matchesGoldenFile('goldens/large.png'));
    });
  });

  group('breakpoint boundaries are inclusive', () {
    testWidgets('exactly 400 is still small', (tester) async {
      await _pumpLayout(tester, surface: const Size(400, 900));

      await expectLater(
        _root,
        matchesGoldenFile('goldens/boundary_400_is_small.png'),
      );
    });

    testWidgets('exactly 600 is still medium', (tester) async {
      await _pumpLayout(tester, surface: const Size(600, 900));

      await expectLater(
        _root,
        matchesGoldenFile('goldens/boundary_600_is_medium.png'),
      );
    });
  });

  group('breakpoint overrides', () {
    testWidgets('qualifier breakpoints reclassify the same surface',
        (tester) async {
      // 800 is large by default; a 900/1000 qualifier makes it small. Compare
      // against goldens/large.png, which is the same surface untouched.
      await _pumpLayout(
        tester,
        surface: const Size(800, 1200),
        qualifier: BreakpointsQualifier(
          smallBreakpoint: 900,
          mediumBreakpoint: 1000,
        ),
      );

      await expectLater(
        _root,
        matchesGoldenFile('goldens/qualifier_override.png'),
      );
    });

    testWidgets('BreakpointsSetting reclassifies the subtree', (tester) async {
      // 500 is medium by default; a 200/400 setting makes it large.
      await _pumpLayout(
        tester,
        surface: const Size(500, 900),
        settingSmallBreakpoint: 200,
        settingMediumBreakpoint: 400,
      );

      await expectLater(
        _root,
        matchesGoldenFile('goldens/setting_override.png'),
      );
    });
  });

  testWidgets('falls back to the bare child when no builder matches',
      (tester) async {
    // Medium surface, but only largeBuilder is supplied.
    await _pumpLayout(
      tester,
      surface: const Size(500, 900),
      smallBuilder: null,
      mediumBuilder: null,
    );

    await expectLater(_root, matchesGoldenFile('goldens/child_fallback.png'));
  });
}

const _rootKey = Key('golden-root');
final Finder _root = find.byKey(_rootKey);

const _contentColor = Color(0xFF1565C0);
const _frameColor = Color(0xFFE0E0E0);
const _sidebarColor = Color(0xFFFFA000);

/// The widget every builder wraps. Built once by [AdaptiveLayout] and handed to
/// whichever builder matches.
const Widget _content = ColoredBox(
  color: _contentColor,
  child: SizedBox.expand(),
);

/// Full bleed — the whole surface is content.
Widget _smallLayout(BuildContext context, Widget? child) => child!;

/// A 200x200 content square centred on a grey frame.
Widget _mediumLayout(BuildContext context, Widget? child) => ColoredBox(
      color: _frameColor,
      child: Center(
        child: SizedBox.square(dimension: 200, child: child),
      ),
    );

/// A 120px sidebar beside the content.
Widget _largeLayout(BuildContext context, Widget? child) => ColoredBox(
      color: _frameColor,
      child: Row(
        // stretch, so the sidebar's ColoredBox gets a tight height instead of
        // collapsing to zero and leaving the frame showing through.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 120, child: ColoredBox(color: _sidebarColor)),
          Expanded(child: child!),
        ],
      ),
    );

/// Pumps an [AdaptiveLayout] at [surface], with no Material or font dependency.
///
/// Pass [settingSmallBreakpoint] and [settingMediumBreakpoint] to wrap the
/// layout in a [BreakpointsSetting]. Builders default to the three reference
/// layouts above; pass `null` explicitly to omit one and exercise the fallback
/// to `child`.
Future<void> _pumpLayout(
  WidgetTester tester, {
  required Size surface,
  ScreenSizeQualifier? qualifier,
  num? settingSmallBreakpoint,
  num? settingMediumBreakpoint,
  AdaptiveBuilder? smallBuilder = _smallLayout,
  AdaptiveBuilder? mediumBuilder = _mediumLayout,
  AdaptiveBuilder? largeBuilder = _largeLayout,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = surface;
  addTearDown(tester.view.reset);

  Widget layout = AdaptiveLayout(
    qualifier: qualifier,
    smallBuilder: smallBuilder,
    mediumBuilder: mediumBuilder,
    largeBuilder: largeBuilder,
    child: _content,
  );

  if (settingSmallBreakpoint != null && settingMediumBreakpoint != null) {
    layout = BreakpointsSetting(
      smallScreenBreakpoint: settingSmallBreakpoint,
      mediumScreenBreakpoint: settingMediumBreakpoint,
      child: layout,
    );
  }

  await tester.pumpWidget(
    RepaintBoundary(
      key: _rootKey,
      child: MediaQuery.fromView(
        view: tester.view,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: layout,
        ),
      ),
    ),
  );
}
