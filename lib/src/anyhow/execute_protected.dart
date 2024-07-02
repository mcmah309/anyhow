import 'dart:async';

import 'package:anyhow/anyhow.dart';

@Deprecated("Use 'guard' instead")
Result<S> executeProtected<S>(S Function() func) => guard(func);

@Deprecated("Use 'guardResult' instead")
Result<S> executeProtectedResult<S>(Result<S> Function() func) => guardResult(func);

@Deprecated("Use 'guardAsync' instead")
FutureResult<S> executeProtectedAsync<S>(Future<S> Function() func) => guardAsync<S>(func);

@Deprecated("Use 'guardAsyncResult' instead")
FutureResult<S> executeProtectedAsyncResult<S>(
    Future<Result<S>> Function() func) => guardAsyncResult(func);

/// Executes the function in a protected context. [func] is called inside a try catch block. If the result is not
/// catch, then return value [func] returned inside an [Ok]. If [func] throws, then the thrown value is returned
/// inside an [Err].
Result<S> guard<S>(S Function() func) {
  assert(S is! Result, "Use guardResult instead");
  try {
    return Ok(func());
  } catch (e) {
    return Err(Error(e));
  }
}

/// Result unwrapping version of [guard]. Where [func] returns an [Result], but can still throw.
Result<S> guardResult<S>(Result<S> Function() func) {
  try {
    return func();
  } catch (e) {
    return Err(Error(e));
  }
}

/// Async version of [guard]
FutureResult<S> guardAsync<S>(Future<S> Function() func) async {
  assert(S is! Result, "Use guardAsyncResult instead");
  try {
    return Ok(await func());
  } catch (e) {
    return Err(Error(e));
  }
}

/// Async version of [guardResult]
FutureResult<S> guardAsyncResult<S>(
    Future<Result<S>> Function() func) async {
  try {
    return await func();
  } catch (e) {
    return Err(Error(e));
  }
}
