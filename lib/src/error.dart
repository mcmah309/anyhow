import 'package:rust/rust.dart' as rust;

part 'extensions.dart';
part 'result.dart';
part 'functions.dart';

/// [Error] is a wrapper around an [Object] that represents an error or context around a parent error.
/// Used for chaining error [Object]s that are related.
class Error implements Exception {
  /// If Errors should be captured with a [StackTrace].
  static bool hasStackTrace = true;

  /// Setting for how errors are converted to strings
  static ErrorDisplayOrder displayOrder = ErrorDisplayOrder.rootLast;

  /// How to display [StackTrace]s. Requires [hasStackTrace] = true
  static StackTraceDisplayFormat stackTraceDisplayFormat = StackTraceDisplayFormat.one;

  /// Modifies the stacktrace during display. Useful for adjusting number of frames to include during
  /// display/logging. Stacktraces that are captured internally through [bail], [anyhow],
  /// [AnyhowResultExtension.context], etc.
  /// or directly by calling [Error.new], are always captured as soon as possible - one stack frame
  /// below the calling code. Therefore, if pruning during display is desired,
  /// one can comfortably prune 1 off the root and then leave as many other frames as you desire.
  /// Note passing the optional stackTrace param for functions like [bail] obviously will not hold
  /// this guarantee.
  ///
  /// See also the [stack_trace](https://pub.dev/packages/stack_trace) package.
  /// Requires [hasStackTrace] = true
  static StackTrace Function(StackTrace) stackTraceDisplayModifier = (s) => s;

  Object _inner;
  Error? _parent;
  late final StackTrace? _stackTrace;

  Error(this._inner, {Error? parent}) : _parent = parent {
    _stackTrace = hasStackTrace ? StackTrace.current : null;
  }

  /// Constructor used internally when it is known a [StackTrace] is needed, so it is eagerly created.
  Error._withStackTrace(this._inner, this._stackTrace, {Error? parent}) : _parent = parent;

  /// Returns true if [E] is the type held by this error object.
  bool isType<E extends Object>() {
    return _inner is E;
  }

  /// Attempt to downcast the error object to a concrete type.
  Result<E> downcast<E extends Object>() {
    if (_inner is E) {
      return Ok(_inner as E);
    }
    return Err(this);
  }

  /// Attempt to downcast the error object to a concrete type without error handling. If the downcast fails, this will throw an exception.
  /// This is useful when you know the downcast should always succeed, like when casting to [Object] for use in a case statement.
  E downcastUnchecked<E extends Object>() {
    return _inner as E;
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
  Error clone({Object? inner, Error? parent}) {
    return Error(inner ?? _inner, parent: parent ?? _parent?.clone());
  }

  /// Human readable error representation
  @override
  String toString() {
    final StringBuffer stringBuf = StringBuffer();
    switch (displayOrder) {
      case ErrorDisplayOrder.rootLast:
        final list = chain();
        const restTitle = "Caused By";
        _writeErrorAndContext(stringBuf, restTitle, list.iterator);
        _writeStackTraces(stringBuf, restTitle, list.iterator);
        break;
      case ErrorDisplayOrder.rootFirst:
        final list = chain().toList(growable: false).reversed;
        const restTitle = "Additional Context";
        _writeErrorAndContext(stringBuf, restTitle, list.iterator);
        _writeStackTraces(stringBuf, restTitle, list.iterator);
        break;
    }
    return stringBuf.toString();
  }

  void _writeErrorAndContext(StringBuffer stringBuf, String restTitle, Iterator<Error> iter) {
    iter.moveNext();
    stringBuf.write("${iter.current._inner}\n");
    if (iter.moveNext()) {
      stringBuf.write("\n$restTitle:\n");
      stringBuf.write("\t0: ${iter.current._inner}\n");
      int index = 1;
      while (iter.moveNext()) {
        stringBuf.write("\t${index}: ${iter.current._inner}\n");
        index++;
      }
    }
  }

  void _writeStackTraces(StringBuffer stringBuf, String restTitle, Iterator<Error> iter) {
    if (hasStackTrace) {
      switch (stackTraceDisplayFormat) {
        case StackTraceDisplayFormat.none:
          break;
        case StackTraceDisplayFormat.one:
          if (iter.moveNext()) {
            stringBuf.write("\nStackTrace:\n");
            stringBuf.write(stackTraceDisplayModifier(iter.current._stackTrace!));
            stringBuf.write("\n");
          }
        case StackTraceDisplayFormat.full:
          if (iter.moveNext()) {
            stringBuf.write("\nStackTrace:\n");
            stringBuf.write(stackTraceDisplayModifier(iter.current._stackTrace!));
            stringBuf.write("\n");
          }
          if (iter.moveNext()) {
            stringBuf.write("\n");
            stringBuf.write("\n$restTitle StackTraces:\n");
            stringBuf.write("\t0: ${stackTraceDisplayModifier(iter.current._stackTrace!)}\n");
            int index = 1;
            while (iter.moveNext()) {
              stringBuf
                  .write("\t${index}: ${stackTraceDisplayModifier(iter.current._stackTrace!)}\n");
              index++;
            }
          }
      }
    }
  }

  @override
  int get hashCode => _inner.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Error && other._inner == _inner && other._parent == _parent;
}

/// Controls the base [toString] format
enum ErrorDisplayOrder {
  /// Traditional anyhow display. The most recent context to the root cause. E.g.:
  ///
  /// Bob ordered.
  ///
  /// Caused By:
  /// 	0: Order was pizza.
  /// 	1: Pizza was missing a topping.
  rootLast,

  /// Root cause to additional context added above. E.g.:
  ///
  /// Pizza was missing a topping.
  ///
  /// Additional Context:
  /// 	0: Order was pizza.
  /// 	1: Bob ordered.
  rootFirst
}

/// How StackTrace should be displayed to the user.
enum StackTraceDisplayFormat {
  /// Every linked [Error]'s stackTrace will be included. Note - this can get verbose.
  full,

  /// Only first [StackTrace] will be included.
  one,

  /// No [StackTrace]s should be included.
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
