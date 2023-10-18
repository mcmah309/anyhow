import '../../anyhow.dart';

/// Convenience function for turning an object into an [Err] Result.
Err<S> bail<S>(Object err){
  assert(err is! Error, "err should not already be an Error.");
  return Err(Error(err));
}

/// Convenience function for creating a [Result] to return with the [err] if the condition does not hold.
///
/// ```dart
/// final check = ensure(() => x > 1, "x should be greater than 1");
/// if(check.isErr()) return check;
/// ```
Result<Null> ensure(bool Function() fn, Object err) {
  assert(err is! Error, "err should not already be an Error.");
  if(fn()) {
    return Ok(null);
  }
  return Err(Error(err));
}

/// Convenience function for turning an object into an [Error]. Same as the original "anyhow" macro.
Error anyhow<S>(Object err){
  assert(err is! Error, "err should not already be an Error.");
  return Error(err);
}
