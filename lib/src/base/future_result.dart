import 'dart:async';

import '../../base.dart';

/// {@macro futureResult}
typedef FutureResult<S, F extends Object> = Future<Result<S, F>>;

/// {@template futureResult}
/// [FutureResult] represents an asynchronous [Result]. And as such, inherits all of [Result]s methods.
/// {@endtemplate}
extension FutureResultExtension<S, F extends Object> on FutureResult<S, F> {
  Future<S> unwrap() {
    return then((result) => result.unwrap());
  }

  Future<S> unwrapOr(S defaultValue) {
    return then((result) => result.unwrapOr(defaultValue));
  }

  Future<S> unwrapOrElse(FutureOr<S> Function(F) onError) {
    return match(
      (ok) {
        return ok;
      },
      (error) {
        return onError(error);
      },
    );
  }

  Future<S?> unwrapOrNull() {
    return then((result) => result.unwrapOrNull());
  }

  Future<F> unwrapErr() {
    return then((result) => result.unwrapErr());
  }

  Future<F> unwrapErrOr(F defaultValue) {
    return then((result) => result.unwrapErrOr(defaultValue));
  }

  Future<F> unwrapErrOrElse(FutureOr<F> Function(S ok) onOk) {
    return match(
      (ok) {
        return onOk(ok);
      },
      (error) {
        return error;
      },
    );
  }

  Future<F?> unwrapErrOrNull() {
    return then((result) => result.unwrapErrOrNull());
  }

  //************************************************************************//

  Future<bool> isErr() {
    return then((result) => result.isErr());
  }

  Future<bool> isErrOr(bool Function(F) fn) {
    return then((result) => result.isErrAnd(fn));
  }

  Future<bool> isOk() {
    return then((result) => result.isOk());
  }

  Future<bool> isOkOr(bool Function(S) fn) {
    return then((result) => result.isOkAnd(fn));
  }

  //************************************************************************//

  Future<Iterable<S>> iter() {
    return then((result) => result.iter());
  }

  //************************************************************************//

  FutureResult<S2, F> and<S2>(Result<S2, F> other) {
    return then((result) => result.and(other));
  }

  FutureResult<S, F2> or<F2 extends Object>(Result<S, F2> other) {
    return then((result) => result.or(other));
  }

  //************************************************************************//

  Future<W> match<W>(FutureOr<W> Function(S ok) onOk, FutureOr<W> Function(F error) onError) {
    return then<W>((result) => result.match(onOk, onError));
  }

  FutureResult<W, F> map<W>(FutureOr<W> Function(S ok) fn) {
    return match(
      (ok) async {
        return Ok(await fn(ok));
      },
      (error) {
        return Err(error);
      },
    );
  }

  Future<W> mapOr<W>(W defaultValue, FutureOr<W> Function(S ok) fn) {
    return match(
      (ok) {
        return fn(ok);
      },
      (error) {
        return defaultValue;
      },
    );
  }

  Future<W> mapOrElse<W>(FutureOr<W> Function(F err) defaultFn, FutureOr<W> Function(S ok) fn) {
    return match(
      (ok) {
        return fn(ok);
      },
      (error) {
        return defaultFn(error);
      },
    );
  }

  FutureResult<S, W> mapErr<W extends Object>(FutureOr<W> Function(F error) fn) {
    return match(
      (ok) {
        return Ok(ok);
      },
      (error) async {
        return Err(await fn(error));
      },
    );
  }

  FutureResult<W, F> andThen<W>(FutureOr<Result<W, F>> Function(S ok) fn) {
    return match(fn, Err.new);
  }

  FutureResult<S, W> andThenErr<W extends Object>(FutureOr<Result<S, W>> Function(F error) fn) {
    return match(Ok.new, fn);
  }

  FutureResult<S, F> inspect(FutureOr<void> Function(S ok) fn) {
    return then((result) => result.inspect(fn));
  }

  FutureResult<S, F> inspectErr(FutureOr<void> Function(F error) fn) {
    return then((result) => result.inspectErr(fn));
  }

  //************************************************************************//

  FutureResult<S, F> copy() {
    return then((result) => result.copy());
  }
}
