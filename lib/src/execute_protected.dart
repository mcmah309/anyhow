import 'dart:async';

import '../anyhow.dart';

/// Executes the function in a protected context. [func] is called inside a try catch block. If the result is not
/// catch, then return value [func] returned inside an [Ok]. If [func] throws, then the thrown value is returned
/// inside an [Err].
Anyhow<S> executeProtected<S>(S Function() func) {
  // You want [executeProtectedResult] if this is true. Otherwise errors could be ignored.
  assert(S is! Result);
  try {
    return Ok(func());
  } catch (e) {
    return Err(AnyhowError(e));
  }
}

/// Result unwrapping version of [executeProtected]. Where [func] returns an [Anyhow], but can still throw.
Anyhow<S> executeProtectedResult<S>(Anyhow<S> Function() func) {
  try {
    return func();
  } catch (e) {
    return Err(AnyhowError(e));
  }
}

/// Async version of [executeProtected]
FutureResult<S, dynamic> executeProtectedAsync<S>(Future<S> Function() func) async {
  try {
    return Ok(await func());
  } catch (e) {
    return Err(AnyhowError(e));
  }
}

/// Async version of [executeProtectedResult]
FutureResult<S, dynamic> executeProtectedAsyncResult<S>(Future<Anyhow<S>> Function() func) async {
  try {
    return await func();
  } catch (e) {
    return Err(AnyhowError(e));
  }
}
