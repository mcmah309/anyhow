part of 'anyhow_error.dart';

const _isAlreadyErrorAssertionMessage =
    "should not already be an instance of Error. If it is, you are likely using the api wrong. "
    "If you need to combine Errors see \"and\", \"or\", \"toResult\", \"toResultEager\" methods. If this"
    " is a valid use case please submit a PR.";

extension AnyhowResultExtensions<S> on Result<S> {
  /// If [Result] is [Ok] returns this. Otherwise, returns an [Err] with the additional context. The context
  /// should not be an instance of [Error].
  Result<S> context(Object context) {
    if (isOk()) {
      return this;
    }
    assert(context is! Error, _isAlreadyErrorAssertionMessage);
    if (Error.hasStackTrace) {
      return Err(Error._withStackTrace(context, StackTrace.current,
          parent: (this as Err).err));
    }
    return Err(Error(context, parent: (this as Err).err));
  }

  /// If [Result] is [Ok] returns this. Otherwise, Lazily calls the function and returns an [Err] with the additional
  /// context. The context should not be an instance of [Error].
  Result<S> withContext(Object Function() fn) {
    if (isOk()) {
      return this;
    }
    final context = fn();
    assert(context is! Error, _isAlreadyErrorAssertionMessage);
    if (Error.hasStackTrace) {
      return Err(Error._withStackTrace(context, StackTrace.current,
          parent: (this as Err).err));
    }
    return Err(Error(context, parent: (this as Err).err));
  }

  /// Overrides the base Extension.
  Result<S> toAnyhowResult() => this;
}

extension AnyhowOkExtensions<S> on Ok<S> {
  /// returns this
  Ok<S> context(Object context) {
    return this;
  }

  /// returns this
  Ok<S> withContext(Object Function() fn) {
    return this;
  }
}

extension AnyhowErrExtensions<S> on Err<S> {
  /// Returns an [Error] with the additional context. The context should not be an instance of [Error].
  Err<S> context(Object context) {
    assert(context is! Error, _isAlreadyErrorAssertionMessage);
    if (Error.hasStackTrace) {
      return Err(
          Error._withStackTrace(context, StackTrace.current, parent: err));
    }
    return Err(Error(context, parent: err));
  }

  /// Lazily calls the function if the [Result] is an [Err] and returns an [Error] with the additional context.
  /// The context should not be an instance of [Error].
  Err<S> withContext(Object Function() fn) {
    final context = fn();
    assert(context is! Error, _isAlreadyErrorAssertionMessage);
    if (Error.hasStackTrace) {
      return Err(
          Error._withStackTrace(context, StackTrace.current, parent: err));
    }
    return Err(Error(context, parent: err));
  }
}

extension AnyhowFutureResultExtension<S> on FutureResult<S> {
  FutureResult<S> context(Object context) {
    return then((result) => result.context(context));
  }

  FutureResult<S> withContext(Object Function() fn) {
    return then((result) => result.withContext(fn));
  }
}

extension AnyhowIterableResultExtensions<S> on Iterable<Result<S>> {
  /// Transforms an Iterable of results into a single result where the [Ok] value is the list of all successes. The
  /// [Err] type is an [Error] with list of all errors [List<Error>]. Similar to [merge].
  Result<List<S>> toResult() {
    List<S> list = [];
    late List<Error> errors;
    Result<List<S>> finalResult = Ok(list);
    for (final result in this) {
      if (finalResult.isOk()) {
        if (result.isErr()) {
          errors = [];
          finalResult = bail(errors);
        } else {
          list.add(result.unwrap());
        }
      }
      if (result.isErr()) {
        errors.add(result.unwrapErr());
      }
    }
    return finalResult;
  }

  /// Merges an Iterable of results into a single result where the [Ok] value is the list of all successes. If any
  /// [Error] is encountered, the first [Error] becomes the root to the rest of the [Error]s. Similar to [toResult].
  Result<List<S>> merge() {
    List<S> list = [];
    Result<List<S>> finalResult = Ok(list);
    for (final result in this) {
      if (finalResult.isOk()) {
        if (result.isErr()) {
          finalResult = Err(result.unwrapErr());
        } else {
          list.add(result.unwrap());
        }
      }
      if (result.isErr()) {
        finalResult = finalResult.context(result.unwrapErr()._cause);
      }
    }
    return finalResult;
  }
}

extension AnyhowFutureIterableResultExtensions<S>
    on Future<Iterable<Result<S>>> {
  FutureResult<List<S>> toResult() {
    return then((result) => result.toResult());
  }

  FutureResult<List<S>> merge() {
    return then((result) => result.merge());
  }
}

/// Adds methods for converting any object
/// into a [Result] type ([Ok] or [Err]).
extension ToOkExtension<S> on S {
  /// Convert the object to a [Result] type [Ok].
  Ok<S> toOk() {
    assert(this is! Result,
        'Don\'t use the "toOk()" method on instances of Result.');
    return Ok(this);
  }
}

extension ToErrExtension<E extends Object> on E {
  /// Convert the object to a [Result] type [Err].
  Err<S> toErr<S>() {
    assert(this is! Result,
        'Don\'t use the "toErr()" method on instances of Result.');
    return Err(Error(this));
  }
}

extension ToErrForErrorExtension<E extends Error> on E {
  /// Convert the error to a [Result] type [Err].
  Err<S> toErr<S>() {
    return Err(this);
  }
}

extension BaseResultExtension<S, F extends Object> on base.Result<S, F> {
  /// When this Result is a base [base.Result] and not already an "anyhow" [Result], converts to anyhow [Result].
  /// Otherwise returns this.
  Result<S> toAnyhowResult() {
    if (isOk()) {
      return Ok((this as base.Ok<S, F>).unwrap());
    }
    return bail((this as base.Err<S, F>).unwrapErr());
  }
}

extension BaseOkExtension<S, F extends Object> on base.Ok<S, F> {
  /// When this Result is a base [base.Result] and not already an "anyhow" [Result], converts to anyhow [Result].
  /// Otherwise returns this.
  Result<S> toAnyhowResult() {
    return Ok(unwrap());
  }
}

extension BaseErrExtension<S, F extends Object> on base.Err<S, F> {
  /// When this Result is a base [base.Result] and not already an "anyhow" [Result], converts to anyhow [Result].
  /// Otherwise returns this.
  Result<S> toAnyhowResult() {
    return bail(unwrapErr());
  }
}
