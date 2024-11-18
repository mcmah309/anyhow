part of 'anyhow_error.dart';

/// {@macro futureResult}
typedef FutureResult<S> = Future<Result<S>>;

/// {@macro result}
typedef Result<S> = rust.Result<S, Error>;
