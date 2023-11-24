import '../../anyhow.dart';
import '../../base.dart' as base;

part 'anyhow_extensions.dart';
part 'anyhow_result.dart';
part 'functions.dart';

/// Error ([Execution]) wrapper around an [Object] error type. Usually used for chaining [Object]s that are
/// [Exception]s or [String] messages. Essentially a 'Cons' implementation for Errors.
///
/// Dart Exception Type    | Equivalent in Rust
/// -----------------------|---------------------
/// Exception              | Error
/// Error                  | Panic
class Error implements Exception {
  /// Setting for how errors are converted to strings
  static ErrDisplayFormat displayFormat = ErrDisplayFormat.traditionalAnyhow;

  /// If Errors should be captured with a [StackTrace].
  static bool hasStackTrace = false;

  /// How to display [StackTrace]s.
  static StackTraceDisplayFormat stackTraceDisplayFormat = StackTraceDisplayFormat.one;

  Object _cause;
  Error? _parent;
  late final StackTrace? _stackTrace;

  Error(this._cause, {Error? parent}) : _parent = parent {
    _stackTrace = hasStackTrace ? StackTrace.current : null;
  }

  /// Constructor used internally when it is known a [StackTrace] is needed, so it is eagerly created.
  Error._withStackTrace(this._cause, this._stackTrace, {Error? parent}) : _parent = parent;

  /// Returns true if E is the type held by this error object. Analogous to anyhow's "is" function, but "is" is a
  /// protect keyword in dart
  bool isType<E>() {
    if (_cause is E) {
      return true;
    }
    return false;
  }

  /// Attempt to downcast the error object to a concrete type.
  Result<E> downcast<E>() {
    if (_cause is E) {
      return Ok(_cause as E);
    }
    return Err(this);
  }

  /// The lowest level cause of this error — this error’s cause’s cause’s cause etc. The root cause is the last error
  /// in the iterator produced by [chain].
  Error rootCause() => chain().last;

  /// An iterator of the chain of source errors. Starting at the this.
  Iterable<Error> chain() sync* {
    Error link = this;
    while (link._parent != null) {
      yield link;
      link = link._parent!;
    }
    yield link;
  }

  /// Is this [Error] the first error
  bool isRoot() => _parent == null;

  /// The stacktrace (backtrace) for this error if [hasStackTrace] is set to true
  StackTrace? stacktrace() => _stackTrace;

  /// Creates a clone of this [Error], cloning all [Error], but the causes are not cloned.
  Error clone<E extends Object>({E? cause, Error? parent}) {
    return Error(cause ?? _cause, parent: parent ?? _parent?.clone());
  }

  /// Human readable error representation
  @override
  String toString() {
    final StringBuffer stringBuf = StringBuffer();
    switch (displayFormat) {
      case ErrDisplayFormat.traditionalAnyhow:
        final list = chain();
        _writeErrorAndContext(stringBuf, "Error", "Caused by", list.iterator);
        _writeStackTraces(stringBuf, list.iterator);
        break;
      case ErrDisplayFormat.rootCauseFirst:
        final list = chain().toList(growable: false).reversed;
        _writeErrorAndContext(stringBuf, "Root Cause", "Additional Context", list.iterator);
        _writeStackTraces(stringBuf, list.iterator);
        break;
    }
    return stringBuf.toString();
  }

  void _writeErrorAndContext(StringBuffer stringBuf, String firstTitle, String restTitle, Iterator<Error> iter) {
    iter.moveNext();
    stringBuf.write("$firstTitle: ${iter.current._cause}\n");
    if (iter.moveNext()) {
      stringBuf.write("\n$restTitle:\n");
      stringBuf.write("\t0: ${iter.current._cause}\n");
      int index = 1;
      while (iter.moveNext()) {
        stringBuf.write("\t${index}: ${iter.current._cause}\n");
        index++;
      }
    }
  }

  void _writeStackTraces(StringBuffer stringBuf, Iterator<Error> iter) {
    if (hasStackTrace) {
      switch (stackTraceDisplayFormat) {
        case StackTraceDisplayFormat.none:
          break;
        case StackTraceDisplayFormat.one:
          stringBuf.write("\n");
          if (iter.moveNext()) {
            stringBuf.write("StackTrace:\n${iter.current._stackTrace}\n");
          }
          break;
        case StackTraceDisplayFormat.full:
          stringBuf.write("\n");
          if (iter.moveNext()) {
            stringBuf.write("Main StackTrace:\n${iter.current._stackTrace}\n");
          }
          if (iter.moveNext()) {
            stringBuf.write("\nAdditional StackTraces:\n");
            stringBuf.write("\t0: ${iter.current._stackTrace}\n");
            int index = 1;
            while (iter.moveNext()) {
              stringBuf.write("\t${index}: ${iter.current._stackTrace}\n");
              index++;
            }
            break;
          }
      }
    }
  }

  @override
  int get hashCode => _cause.hashCode;

  @override
  bool operator ==(Object other) => other is Error && other._cause == _cause && other._parent == _parent;
}

/// Controls the base [toString] format
enum ErrDisplayFormat {
  /// Top level to low level. Ex:
  /// Error: Bob ordered.
  ///
  /// Caused by:
  /// 	0: order was pizza.
  /// 	1: Hmm something went wrong making the hamburger.
  traditionalAnyhow,

  /// Root cause to additional context added above. Ex:
  /// Root Cause: Hmm something went wrong making the hamburger.
  ///
  /// Additional Context:
  /// 	0: order was pizza.
  /// 	1: Bob ordered.
  rootCauseFirst
}

/// How StackTrace should be displayed to the user. Known as "backtrace" in Rust anyhow.
enum StackTraceDisplayFormat {
  /// Every linked [Result] error will print their full stackTrace. Warning can get verbose.
  full,

  /// Only this [Result] error will print their full stackTrace.
  one,

  /// No stackTraces should be printed.
  none,
}

extension FutureAnyhowError on Future<Error> {
  /// Returns true if E is the type held by this error object. Analogous to anyhow's "is" function, but "is" is a
  /// protect keyword in dart
  Future<bool> isType<E>() {
    return then((e) => e.isType<E>());
  }

  /// Attempt to downcast the error object to a concrete type.
  Future<Result<E>> downcast<E>() {
    return then((e) => e.downcast<E>());
  }

  /// The lowest level cause of this error — this error’s cause’s cause’s cause etc. The root cause is the last error
  /// in the iterator produced by [chain].
  Future<Error> rootCause() {
    return then((e) => e.rootCause());
  }

  /// Is this [Error] the first error
  Future<bool> isRoot() {
    return then((e) => e.isRoot());
  }

  /// An iterator of the chain of source errors. Starting at the this.
  Future<Iterable<Error>> chain() {
    return then((e) => e.chain());
  }

  /// The stacktrace (backtrace) for this error if [hasStackTrace] is set to true
  Future<StackTrace?> stacktrace() {
    return then((e) => e.stacktrace());
  }
}
