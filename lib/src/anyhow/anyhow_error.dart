import 'package:rust/rust.dart' as rust;
import 'package:rust/rust.dart';

part 'anyhow_extensions.dart';
part 'anyhow_result.dart';
part 'functions.dart';

/// [Error] is a wrapper around an [Object] that represents an error or context around a parent error.
/// Used for chaining error [Object]s that are related.
class Error implements Exception {
  /// If Errors should be captured with a [StackTrace].
  static bool hasStackTrace = true;

  /// Setting for how errors are converted to strings
  static ErrDisplayFormat displayFormat = ErrDisplayFormat.traditionalAnyhow;

  /// How to display [StackTrace]s. Requires [hasStackTrace] = true
  static StackTraceDisplayFormat stackTraceDisplayFormat =
      StackTraceDisplayFormat.one;

  /// Modifies the stacktrace during display. Useful for adjusting number of frames to include during
  /// display/logging. Stacktraces that are captured internally through "bail", "context", etc. or directly by calling
  /// "Error", are always captured as
  /// soon as possible - one stack frame below your calling code. Therefore, if you decide to prune during display,
  /// you can comfortably prune 1 off the root and then leave as many other frames as you desire. See also the
  /// [stack_trace] package.
  /// Requires [hasStackTrace] = true
  static StackTrace Function(StackTrace) stackTraceDisplayModifier = (s) => s;

  Object _cause;
  Error? _parent;
  late final StackTrace? _stackTrace;

  Error(this._cause, {Error? parent}) : _parent = parent {
    _stackTrace = hasStackTrace ? StackTrace.current : null;
  }

  /// Constructor used internally when it is known a [StackTrace] is needed, so it is eagerly created.
  Error._withStackTrace(this._cause, this._stackTrace, {Error? parent})
      : _parent = parent;

  /// Returns true if [E] is the type held by this error object.
  bool isType<E extends Object>() {
    return _cause is E;
  }

  /// Attempt to downcast the error object to a concrete type.
  Result<E> downcast<E extends Object>() {
    if (_cause is E) {
      return Ok(_cause as E);
    }
    return Err(this);
  }

  /// Attempt to downcast the error object to a concrete type without error handling. If the downcast fails, this will throw an exception.
  /// This is useful when you know the downcast should always succeed, like when casting to [Object] for use in a case statement.
  E downcastUnchecked<E extends Object>() {
    return _cause as E;
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

  /// The stacktrace for this error, if [hasStackTrace] is set to true, this will not be null.
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
        _writeErrorAndContext(
            stringBuf, "Root Cause", "Additional Context", list.iterator);
        _writeStackTraces(stringBuf, list.iterator);
        break;
    }
    return stringBuf.toString();
  }

  void _writeErrorAndContext(StringBuffer stringBuf, String firstTitle,
      String restTitle, Iterator<Error> iter) {
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
            stringBuf.write(
                "StackTrace:\n${stackTraceDisplayModifier(iter.current._stackTrace!)}\n");
          }
          break;
        case StackTraceDisplayFormat.full:
          stringBuf.write("\n");
          if (iter.moveNext()) {
            stringBuf.write(
                "Main StackTrace:\n${stackTraceDisplayModifier(iter.current._stackTrace!)}\n");
          }
          if (iter.moveNext()) {
            stringBuf.write("\nAdditional StackTraces:\n");
            stringBuf.write(
                "\t0: ${stackTraceDisplayModifier(iter.current._stackTrace!)}\n");
            int index = 1;
            while (iter.moveNext()) {
              stringBuf.write(
                  "\t${index}: ${stackTraceDisplayModifier(iter.current._stackTrace!)}\n");
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
  bool operator ==(Object other) =>
      other is Error && other._cause == _cause && other._parent == _parent;
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

/// How StackTrace should be displayed to the user.
enum StackTraceDisplayFormat {
  /// Every linked [Error]'s stackTrace will be included. Warning can get verbose.
  full,

  /// Only first [StackTrace] will be included.
  one,

  /// No stackTraces should be printed.
  none,
}

extension FutureAnyhowError on Future<Error> {
  /// Returns true if [E] is the type held by this error object.
  Future<bool> isType<E extends Object>() {
    return then((e) => e.isType<E>());
  }

  /// Attempt to downcast the error object to a concrete type.
  Future<Result<E>> downcast<E extends Object>() {
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

  /// The stacktrace for this error, if [hasStackTrace] is set to true, this will not be null.
  Future<StackTrace?> stacktrace() {
    return then((e) => e.stacktrace());
  }
}
