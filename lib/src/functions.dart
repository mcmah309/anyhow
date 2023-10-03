import '../anyhow.dart';

/// Shorthand to create an [Ok] result from an object. See also [toOk] extension function.
Result<S, F> ok<S, F extends Object>(S ok) {
  return Result<S, F>.ok(ok);
}

/// Shorthand to create an [Err] result from an object. See also [toErr] extension function.
Result<S, F> err<S, F extends Object>(F error) {
  return Result<S, F>.err(error);
}
