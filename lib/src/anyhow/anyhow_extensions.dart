import 'dart:async';

import '../../anyhow.dart';

extension AnyhowResultExtensions<S> on Result<S> {
  /// Adds the object as additional context to the [Error]. The context should not be an instance of
  /// [Error].
  Result<S> context(Object context){
    if(isOk()){
      return (this as Ok<S>).context(context);
    }
    return (this as Err<S>).context(context);
  }

  /// Lazily calls the function if the [Result] is an [Err] and adds the object as additional context to the
  /// [Error]. The context should not be an instance of [Error].
  Result<S> withContext(Object Function() fn){
    if(isOk()){
      return (this as Ok<S>).withContext(fn);
    }
    return (this as Err<S>).withContext(fn);
  }
}

extension AnyhowOkExtensions<S> on Ok<S> {
  /// Adds the object as additional context to the [Error]. The context should not be an instance of
  /// [Error].
  Ok<S> context(Object context){
    return this;
  }

  /// Lazily calls the function if the [Result] is an [Err] and adds the object as additional context to the
  /// [Error]. The context should not be an instance of [Error].
  Ok<S> withContext(Object Function() fn){
    return this;
  }
}

extension AnyhowErrExtensions<S> on Err<S> {
  /// Adds the object as additional context to the [Error]. The context should not be an instance of
  /// [Error].
  Err<S> context(Object context) {
    assert(context is! Error, "The context should not already be an instance of AnyhowError. If it is, you are "
        "likely using the api wrong. If you need to combine AnyhowErrors see \"and\" and \"andThen\" methods. If this"
        " is a valid use case please submit a PR.");
    error.add(Error(context));
    return this;
  }

  /// Lazily calls the function if the [Result] is an [Err] and adds the object as additional context to the
  /// [Error]. The context should not be an instance of [Error].
  Err<S> withContext(Object Function() fn) {
    return context(fn());
  }
}

extension AnyhowFutureResultExtension<S> on FutureResult<S> {

  /// Adds the object as additional context to the [Error]. The context should not be an instance of
  /// [Error].
  FutureResult<S> context(Object context){
    return then((result) => result.context(context));
  }

  /// Lazily calls the function if the [Result] is an [Err] and adds the object as additional context to the
  /// [Error]. The context should not be an instance of [Error].
  FutureResult<S> withContext(Object Function() fn){
    return then((result) => result.withContext(fn));
  }
}

extension AnyhowResultIterableExtensions<S> on Iterable<Result<S>> {
  /// Transforms an Iterable of results into a single result where the ok value is the list of all successes. If any
  /// error is encountered, the first error becomes the head to the rest of the errors.
  Result<List<S>> toResult() {
    List<S> list = [];
    Result<List<S>> finalResult = Ok(list);
    for (final result in this) {
      if (finalResult.isOk()) {
        if (result.isErr()) {
          finalResult = Err(result.unwrapErr());
        }
        list.add(result.unwrap());
      }
      if (result.isErr()) {
        finalResult = finalResult.context(result.unwrapErr());
      }
    }
    return finalResult;
  }
}

/// Adds methods for converting any object
/// into a [Result] type ([Ok] or [Err]).
extension ResultObjectNullableExtension<S> on S {

  /// Convert the object to a [Result] type [Ok].
  ///
  /// Will throw an error if used on a [Result] or [Future] instance.
  Ok<S> toOk() {
    assert(this is! Result, 'Don\'t use the "toOk()" method on instances of Result.');
    assert(this is! Future, 'Don\'t use the "toOk()" method on instances of Future.');
    return Ok<S>(this);
  }
}

extension ResultObjectExtension<S extends Object> on S {
  /// Convert the object to a [Result] type [Err].
  ///
  /// Will throw an error if used on a [Result] or [Future] instance.
  Err<S> toErr<S>() {
    assert(this is! Result, 'Don\'t use the "toError()" method on instances of Result.');
    assert(this is! Future, 'Don\'t use the "toError()" method on instances of Future.');
    assert(this is! Error, 'Don\'t use the "toOk()" method on instances of Error.');
    return Err<S>(Error(this));
  }
}