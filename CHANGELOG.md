## 3.0.0

* Bump `rust` version

## 2.0.1

* Bump `rust` version

## 2.0.0

* Refactor `rust` package export into `rust.dart` overlay
* Add `stackTrace` option to `bail`, `ensure`, and `anyhow`
* Rename `Error` static fields
* Modify `Error` display format

## 1.3.2

* Export rust instead of rust_core

## 1.3.1

* Update to `rust_core` 1.0.0

## 1.3.0

* Add `downcastUnchecked`
* Update rust_core

## 1.2.1

* Update dependency

## 1.2.0

* Stabilize 1.2.0  

## 1.2.0-dev.2

* Update rust_core

## 1.2.0-dev.1

* Migration of Result to the 'rust_core' package. Gaining more features and ecosystem with 100% compatibility.

## 1.1.0

* Add merge to Iterable Result
* Add more future extensions
* Add toOk and toErr to base
* Add stackTraceDisplayModifier

## 1.0.0

* Stable Release

## 1.0.0-dev.3

* Formatting

## 1.0.0-dev.2

* Fix remaining lints

## 1.0.0-dev.1

* Stable dev release

## 0.8.0

* Make match named method

## 0.7.0

* Result type now has all Rust Result type methods
* Infallible type
* iter
* mapOr
* mapOrElse
* orElse
* isErrAnd
* isOkAnd
* implement all methods and extension for FutureResult
* Default is to now collect stacktrace

## 0.6.2

* Create stacktraces earlier when needed

## 0.6.1

* Add Unit

## 0.6.0

* Update "and" and "or" to be more explicit
* Add handling for Iterable Future Result
* Add toResultEager
* Reverse Anyhow Error

## 0.5.1

* Add intoFutureResult for any Result type

## 0.5.0

* More extensions
* Better type matching
* intoUnchecked

## 0.4.0

* Separate Result into base Result and anyhow Result
* add "and" and "or"

## 0.3.1

* Initial public release