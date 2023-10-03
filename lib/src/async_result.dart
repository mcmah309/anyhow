import 'dart:async';

import '../anyhow.dart';

/// [AsyncResult] represents an asynchronous computation.
typedef AsyncResult<S, F> = Future<Result<S, F>>;

extension AsyncResultExtension<S, F> on AsyncResult<S, F> {

  /// Returns the ok value as a throwing expression.
  Future<S> unwrap() {
    return then((result) => result.unwrap());
  }

  /// Returns the encapsulated value if this instance represents
  /// [Ok] or the [defaultValue] if it is [Err].
  Future<S> unwrapOr(S defaultValue) {
    return then((result) => result.unwrapOr(defaultValue));
  }

  /// Returns the encapsulated value if this instance represents [Ok]
  /// or the result of [onError] function for
  /// the encapsulated a [Err] value.
  Future<S> unwrapOrElse(S Function(F) onError) {
    return then((result) => result.unwrapOrElse(onError));
  }

  /// Returns the future value of [S] if any.
  Future<S?> unwrapOrNull() {
    return then((result) => result.unwrapOrNull());
  }

  Future<F> err(){
    return then((result) => result.err());
  }

  Future<F> errOr(F defaultValue){
    return then((result) => result.errOr(defaultValue));
  }

  Future<F> errOrElse(F Function(S ok) onOk){
    return then((result) => result.errOrElse(onOk));
  }

  /// Returns the future value of [F] if any.
  Future<F?> errOrNull() {
    return then((result) => result.errOrNull());
  }

  //************************************************************************//

  /// Returns true if the current result is an [Err].
  Future<bool> isErr() {
    return then((result) => result.isErr());
  }

  /// Returns true if the current result is a [Ok].
  Future<bool> isOk() {
    return then((result) => result.isOk());
  }

  //************************************************************************//

  /// Returns the Future result of [onOk] for the encapsulated value
  /// if this instance represents [Ok] or the result of onError function
  /// for the encapsulated value if it is [Err].
  Future<W> match<W>(
      W Function(S ok) onOk,
      W Function(F error) onError,
      ) {
    return then<W>((result) => result.match(onOk, onError));
  }

  /// Returns a new [AsyncResult], mapping any [Ok] value
  /// using the given transformation.
  AsyncResult<W, F> map<W>(
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

  /// Returns a new [Result], mapping any [Err] value
  /// using the given transformation.
  AsyncResult<S, W> mapError<W>(
      FutureOr<W> Function(F error) fn,
      ) {
    return then(
          (result) => result.mapError(fn).match(
            (ok) {
          return Ok(ok);
        },
            (error) async {
          return Err(await error);
        },
      ),
    );
  }

  /// Returns a new [Result], mapping any [Ok] value
  /// using the given transformation and unwrapping the produced [Result].
  AsyncResult<W, F> flatMap<W>(
      FutureOr<Result<W, F>> Function(S ok) fn,
      ) {
    return then((result) => result.match(fn, Err.new));
  }

  /// Returns a new [Result], mapping any [Err] value
  /// using the given transformation and unwrapping the produced [Result].
  AsyncResult<S, W> flatMapError<W>(
      FutureOr<Result<S, W>> Function(F error) fn,
      ) {
    return then((result) => result.match(Ok.new, fn));
  }

  //************************************************************************//

  /// Swap the values contained inside the [Ok] and [Err]
  /// of this [AsyncResult].
  AsyncResult<F, S> swap() {
    return then((result) => result.swap());
  }
}
