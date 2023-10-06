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

  Future<S> unwrapOrElse(S Function(F) onError) {
    return then((result) => result.unwrapOrElse(onError));
  }

  Future<S?> unwrapOrNull() {
    return then((result) => result.unwrapOrNull());
  }

  Future<F> unwrapErr(){
    return then((result) => result.unwrapErr());
  }

  Future<F> unwrapErrOr(F defaultValue){
    return then((result) => result.unwrapErrOr(defaultValue));
  }

  Future<F> unwrapErrOrElse(F Function(S ok) onOk){
    return then((result) => result.unwrapErrOrElse(onOk));
  }

  Future<F?> unwrapErrOrNull() {
    return then((result) => result.err());
  }

  //************************************************************************//

  Future<bool> isErr() {
    return then((result) => result.isErr());
  }

  Future<bool> isOk() {
    return then((result) => result.isOk());
  }

  //************************************************************************//

  FutureResult<dynamic, Object> and<S2, F2 extends Object>(Result<S2, F2> other){
    return then((result) => result.and(other));
  }

  FutureResult<dynamic, Object> or<S2, F2 extends Object>(Result<S2, F2> other){
    return then((result) => result.or(other));
  }

  //************************************************************************//

  Future<W> match<W>(
      W Function(S ok) onOk,
      W Function(F error) onError,
      ) {
    return then<W>((result) => result.match(onOk, onError));
  }

  FutureResult<W, F> map<W>(
      FutureOr<W> Function(S ok) fn,
      ) {
    return then(
          (result) => result.map(fn).match(
            (ok) async {
          return Ok(await ok);
        },
            (error) {
          return Err(error);
        },
      ),
    );
  }

  FutureResult<S, W> mapErr<W extends Object>(
      FutureOr<W> Function(F error) fn,
      ) {
    return then(
          (result) => result.match(
            (ok) {
          return Ok(ok);
        },
            (error) async {
          return Err(await fn(error));
        },
      ),
    );
  }

  FutureResult<W, F> andThen<W>(
      FutureOr<Result<W, F>> Function(S ok) fn,
      ) {
    return then((result) => result.match(fn, Err.new));
  }

  FutureResult<S, W> andThenErr<W extends Object>(
      FutureOr<Result<S, W>> Function(F error) fn,
      ) {
    return then((result) => result.match(Ok.new, fn));
  }

  FutureResult<S,F> inspect(void Function(S ok) fn){
    return then((result) => result.inspect(fn));
  }

  FutureResult<S,F> inspectErr(void Function(F error) fn){
    return then((result) => result.inspectErr(fn));
  }

  //************************************************************************//

  FutureResult<S, F> copy() {
    return then((result) => result.copy());
  }
}
