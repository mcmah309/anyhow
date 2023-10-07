import '../../anyhow.dart';
import '../../base.dart' as base;


part 'anyhow_result.dart';
part 'anyhow_extensions.dart';

/// Error ([Execution]) wrapper around an [Object] error type. Usually used for chaining [Object]s that are
/// [Exception]s or [String] messages. Essentially a 'Cons' implementation for Errors.
/// This is named "AnyhowError" over "AnyhowException" since this is used as the error type of [Result] and to be
/// consistent with Rust/ the anyhow crate.
///```html
///<h1>Exception Mapping</h1>
///<table border="1">
///  <tr>
///    <th>Dart Exception Type</th>
///    <th>Equivalent in Rust</th>
///  </tr>
///  <tr>
///    <td>Exception</td>
///    <td>Error</td>
///  </tr>
///  <tr>
///    <td>Error</td>
///    <td>Panic</td>
///  </tr>
///</table>
///```
class Error implements Exception {
  Object _cause;
  Error? _additionalContext;
  late final StackTrace? _stackTrace;

  Error(this._cause, {Error? additionalContext})
      : _additionalContext = additionalContext {
      _stackTrace = hasStackTrace ? StackTrace.current : null;
  }

  /// Setting for how errors are converted to strings
  static ErrDisplayFormat displayFormat = ErrDisplayFormat.traditionalAnyhow;

  /// if Errors should be captured with a [StackTrace]. Known as "backtrace" in Rust anyhow;
  static bool hasStackTrace = false;
  static StackTraceDisplayFormat stackTraceDisplayFormat = StackTraceDisplayFormat.one;

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

  /// The latest context that was added to this error
  Error latest() => _errors().lastOrNull!;

  /// An iterator of the chain of source errors contained by this Error. Starting at the root cause (this [Error]).
  Iterable<Object> chain() sync* {
    Error link = this;
    while (link._additionalContext != null) {
      yield link._cause;
      link = link._additionalContext!;
    }
    yield link._cause;
  }

  /// Additional context has been added to this error
  bool hasContext() => _additionalContext != null;

  /// The stacktrace (backtrace) for this error if [hasStackTrace] is set to true
  StackTrace? stacktrace() => _stackTrace;

  /// Implemented to override the "toErr" extension applied to all objects
  Err toErr() => Err(this);

  /// An iterator of [Error]s that were added as additional context to this error. Starting at the root cause
  /// (this [Error]).
  Iterable<Error> _errors() sync* {
    Error link = this;
    while (link._additionalContext != null) {
      yield link;
      link = link._additionalContext!;
    }
    yield link;
  }

  void _add(Error error){
    latest()._additionalContext = error;
  }

  /// Creates a deep copy of this
  Error clone<E extends Object>({E? cause, Error? additionalContext}) {
    return Error(cause ?? _cause,
        additionalContext: additionalContext ?? _additionalContext?.clone());
  }

  /// Human readable error representation
  @override
  String toString() {
    final StringBuffer stringBuf = StringBuffer();
    switch (displayFormat) {
      case ErrDisplayFormat.traditionalAnyhow:
        _writeErrorAndContext(stringBuf, "Error", "Caused by", chain().toList(growable: false).reversed.iterator);
        _writeStackTraces(stringBuf, _errors().toList(growable: false).reversed.iterator);
        break;
      case ErrDisplayFormat.stackTrace:
        _writeErrorAndContext(stringBuf, "Root Cause", "Additional Context", chain().iterator);
        _writeStackTraces(stringBuf, _errors().iterator);
        break;
    }
    return stringBuf.toString();
  }

  void _writeErrorAndContext(StringBuffer stringBuf, String firstTitle, String restTitle, Iterator<Object> iter) {
    iter.moveNext();
    stringBuf.write("$firstTitle: ${iter.current}\n");
    if (iter.moveNext()) {
      stringBuf.write("\n$restTitle:\n");
      stringBuf.write("\t0: ${iter.current}\n");
      int index = 1;
      while (iter.moveNext()) {
        stringBuf.write("\t${index}: ${iter.current}\n");
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
  bool operator ==(Object other) =>
      other is Error && other._cause == _cause && other._additionalContext == _additionalContext;
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
  stackTrace
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

  /// The latest context that was added to this error
  Future<Error> latest() {
    return then((e) => e.latest());
  }

  /// Additional context has been added to this error
  Future<bool> hasContext() {
    return then((e) => e.hasContext());
  }

  /// The stacktrace (backtrace) for this error if [hasStackTrace] is set to true
  Future<StackTrace?> stacktrace() {
    return then((e) => e.stacktrace());
  }

  /// Implemented to override the "toErr" extension applied to all objects
  Future<Err> toErr() {
    return then((e) => e.toErr());
  }
}
