part of 'anyhow_error.dart';

/// {@macro result}
typedef BaseResult<S,F extends Object> = base.Result<S,F>;
/// {@macro ok}
typedef BaseOk<S,F extends Object> = base.Ok<S,F>;
/// {@macro err}
typedef BaseErr<S,F extends Object> = base.Err<S,F>;
/// {@macro futureResult}
typedef BaseFutureResult<S, F extends Object> = base.FutureResult<S, F>;

/// {@macro futureResult}
typedef FutureResult<S> = Future<Result<S>>;
/// {@macro result}
typedef Result<S> = BaseResult<S,Error>;
/// {@macro ok}
typedef Ok<S> = BaseOk<S,Error>;
/// {@macro err}
typedef Err<S> = BaseErr<S,Error>;