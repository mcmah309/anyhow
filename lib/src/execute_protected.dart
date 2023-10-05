import 'dart:async';

import '../anyhow.dart';

/// Executes the function in a protected context. [func] is called inside a try catch block. If the result is not
/// catch, then return value [func] returned inside an [Ok]. If [func] throws, then the thrown value is returned
/// inside an [Err].
Result<S> executeProtected<S>(S Function() func) {
  // You want [executeProtectedResult] if this is true. Otherwise errors could be ignored.
  assert(S is! Result);
  try {
    return Ok(func());
  } catch (e) {
    return Err(Error(e));
  }
}

/// Result unwrapping version of [executeProtected]. Where [func] returns an [Result], but can still throw.
Result<S> executeProtectedResult<S>(Result<S> Function() func) {
  try {
    return func();
  } catch (e) {
    return Err(Error(e));
  }
}

/// Async version of [executeProtected]
FutureResult<S, dynamic> executeProtectedAsync<S>(Future<S> Function() func) async {
  try {
    return Ok(await func());
  } catch (e) {
    return Err(Error(e));
  }
}

/// Async version of [executeProtectedResult]
FutureResult<S, dynamic> executeProtectedAsyncResult<S>(Future<Result<S>> Function() func) async {
  try {
    return await func();
  } catch (e) {
    return Err(Error(e));
  }
}
