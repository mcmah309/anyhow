part of 'error.dart';

/// {@macro futureResult}
typedef FutureResult<S> = Future<Result<S>>;

/// {@macro result}
typedef Result<S> = rust.Result<S, Error>;
