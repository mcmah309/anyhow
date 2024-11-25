part of 'error.dart';

/// Convenience function for turning an object into an anyhow [Err] Result.
/// [stackTrace] will be ignored if [Error.hasStackTrace] is false.
Err<S> bail<S>(Object err, [StackTrace? stackTrace]) {
  assert(err is! Error, _isAlreadyErrorAssertionMessage);
  if (Error.hasStackTrace) {
    if (stackTrace == null) {
      return Err(Error._withStackTrace(err, StackTrace.current));
    }
    return Err(Error._withStackTrace(err, stackTrace));
  }
  return Err(Error(err));
}

/// Convenience function for creating a [Result] to return with the [err] if the condition does not hold.
///
/// ```dart
/// final check = ensure(() => x > 1, "x should be greater than 1");
/// if(check.isErr()) return check;
/// ```
/// [stackTrace] will be ignored if [Error.hasStackTrace] is false.
Result<()> ensure(bool Function() fn, Object err, [StackTrace? stackTrace]) {
  assert(err is! Error, _isAlreadyErrorAssertionMessage);
  if (fn()) {
    return const Ok(());
  }
  if (Error.hasStackTrace) {
    if (stackTrace == null) {
      return Err(Error._withStackTrace(err, StackTrace.current));
    }
    return Err(Error._withStackTrace(err, stackTrace));
  }
  return Err(Error(err));
}

/// Convenience function for turning an object into an [Error].
/// [stackTrace] will be ignored if [Error.hasStackTrace] is false.
Error anyhow<S>(Object err, [StackTrace? stackTrace]) {
  assert(err is! Error, _isAlreadyErrorAssertionMessage);
  if (Error.hasStackTrace) {
    if (stackTrace == null) {
      return Error._withStackTrace(err, StackTrace.current);
    }
    return Error._withStackTrace(err, stackTrace);
  }
  return Error(err);
}
