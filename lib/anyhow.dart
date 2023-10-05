library result;

import 'base.dart' as base;
import 'src/anyhow/anyhow_error.dart';

export 'base.dart' hide executeProtected, executeProtectedAsync, executeProtectedAsyncResult, executeProtectedResult,
Result, Ok, Err, FutureResult;
export 'src/anyhow/anyhow_error.dart';
export 'src/anyhow/execute_protected.dart';
export 'src/anyhow/functions.dart';
export 'src/anyhow/anyhow_extensions.dart';

/// {@macro result}
typedef BaseResult<S,F extends Object> = base.Result<S,F>;
/// {@macro ok}
typedef BaseOk<S,F extends Object> = base.Ok<S,F>;
/// {@macro err}
typedef BaseErr<S,F extends Object> = base.Err<S,F>;
/// {@macro futureResult}
typedef BaseFutureResult<S, F extends Object> = base.FutureResult<S, F>;