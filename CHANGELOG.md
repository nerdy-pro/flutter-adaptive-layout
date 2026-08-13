## 1.1.0

* Added Dart 3 support — the SDK constraint is now `>=2.18.5 <4.0.0`
* Relicensed from BSD 3-Clause to MIT
* Rewrote `README.md` with a breakpoint reference table, an API reference and an FAQ
* Added golden tests covering screen size selection, the inclusive breakpoint boundaries, both breakpoint override paths and the `child` fallback
* Added a GitHub Actions workflow that analyzes and tests pull requests targeting `main`
* No changes to the public API — upgrading from 1.0.x requires no code changes

## 1.0.2

* Fixed gallery in `README.md`

## 1.0.1

* Added flutter docs
* Switched to `UnimplementedError` if neither builder function nor `child` widget is provided to `AdaptiveLayout`
* Added gallery section to `README.md` 

## 1.0.0

* Initial release
