part of 'error.dart';

/// {@macro futureResult}
typedef FutureResult<S> = Future<Result<S>>;

/// {@macro result}
typedef Result<S> = rust.Result<S, Error>;

/// {@macro ok}
typedef Ok<S> = rust.Ok<S, Error>;

/// {@macro err}
typedef Err<S> = rust.Err<S, Error>;
