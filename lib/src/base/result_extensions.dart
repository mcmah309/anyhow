import 'dart:async';

import '../../base.dart';

extension FlattenExtension<S, F extends Object> on Result<Result<S, F>, F> {
  /// Converts a [Result] of a [Result] into a single [Result]
  Result<S,F> flatten() {
    if(isOk()){
      return unwrap();
    }
    return Err(unwrapErr());
  }
}

extension FlattenFutureExtension<S, F extends Object> on FutureResult<Result<S, F>, F> {
  FutureResult<S, F> flatten() {
    return then((result) => result.flatten());
  }
}

extension TransposeResultExtension<S, F extends Object> on Result<S?, F> {
  /// transposes a [Result] of a nullable type into a nullable [Result].
  Result<S, F>? transpose() {
    if (isOk()) {
      final val = unwrap();
      if (val == null) {
        return null;
      }
      else {
        return Ok(val);
      }
    }
    else {
      return Err(unwrapErr());
    }
  }
}

extension TransposeFutureResultExtension<S, F extends Object> on FutureResult<S?, F> {
  Future<Result<S, F>?> transpose() {
    return then((result) => result.transpose());
  }
}

extension IterableResultExtensions<S, F extends Object> on Iterable<Result<S, F>> {
  /// Transforms an Iterable of results into a single result where the ok value is the list of all successes. If any
  /// error is encountered, the first error is used as the error result.
  Result<List<S>, F> toResultEager() {
    List<S> list = [];
    Result<List<S>, F> finalResult = Ok(list);
    for (final result in this) {
        if (result.isErr()) {
          return Err(result.unwrapErr());
        }
        list.add(result.unwrap());
    }
    return finalResult;
  }

  /// Transforms an Iterable of results into a single result where the ok value is the list of all successes and err
  /// value is a list of all failures.
  Result<List<S>, List<F>> toResult() {
    List<S> okList = [];
    late List<F> errList;
    Result<List<S>, List<F>> finalResult = Ok(okList);
    for (final result in this) {
      if (finalResult.isOk()) {
        if (result.isOk()) {
          okList.add(result.unwrap());
        } else {
          errList = [result.unwrapErr()];
          finalResult = Err(errList);
        }
      } else if (result.isErr()) {
        errList.add(result.unwrapErr());
      }
    }
    return finalResult;
  }
}

extension FutureIterableResultExtensions<S, F extends Object> on Future<Iterable<Result<S, F>>> {
  FutureResult<List<S>, F> toResultEager() {
    return then((result) => result.toResultEager());
  }

  FutureResult<List<S>, List<F>> toResult() {
    return then((result) => result.toResult());
  }
}

extension IterableFutureResultExtensions<S, F extends Object> on Iterable<FutureResult<S, F>> {
  /// Transforms an Iterable of [FutureResult]s into a single result where the ok value is the list of all successes. If
  /// any error is encountered, the first error is used as the error result. The order of [S] and [F] is determined by
  /// the order in which futures complete.
  FutureResult<List<S>, F> toResultEager() async {
    List<S> list = [];
    Result<List<S>, F> finalResult = Ok(list);
    await for (final result in _streamFuturesInOrderOfCompletion(this)) {
      if (result.isErr()) {
        return Err(result.unwrapErr());
      }
      list.add(result.unwrap());
    }
    return finalResult;
  }

  /// Transforms an Iterable of [FutureResult]s into a single result where the ok value is the list of all successes
  /// and err value is a list of all failures. The order of [S] and [F] is determined by
  /// the order in which futures complete.
  FutureResult<List<S>, List<F>> toResult() async {
    List<S> okList = [];
    late List<F> errList;
    Result<List<S>, List<F>> finalResult = Ok(okList);
    await for (final result in _streamFuturesInOrderOfCompletion(this)) {
      if (finalResult.isOk()) {
        if (result.isOk()) {
          okList.add(result.unwrap());
        } else {
          errList = [result.unwrapErr()];
          finalResult = Err(errList);
        }
      } else if (result.isErr()) {
        errList.add(result.unwrapErr());
      }
    }
    return finalResult;
  }
}

extension FutureIterableFutureResultExtensions<S, F extends Object> on Future<Iterable<FutureResult<S, F>>> {
  FutureResult<List<S>, F> toResultEager() async {
    return then((result) => result.toResultEager());
  }

  FutureResult<List<S>, List<F>> toResult() async {
    return then((result) => result.toResult());
  }
}

extension ResultToFutureResultExtension<S,F extends Object> on Result<S,F> {
  /// Turns a [Result] into a [FutureResult].
  FutureResult<S,F> toFutureResult() async {
    return this;
  }
}

extension ResultFutureToFutureResultExtension<S,F extends Object> on Result<Future<S>,F> {
  /// Turns a [Result] of a [Future] into a [FutureResult].
  FutureResult<S,F> toFutureResult() async {
    if(isErr()){
      return (this as Err<Future<S>,F>).into();
    }
    return Ok(await unwrap());
  }
}

//************************************************************************//

/// Returns futures in the order they complete
Stream<T> _streamFuturesInOrderOfCompletion<T>(Iterable<Future<T>> futures) {
  var controller = StreamController<T>();
  int yetToComplete = futures.length;
  if (yetToComplete == 0) {
    controller.close();
  }

  for (var future in futures) {
    future.then((value) {
      controller.add(value);
      yetToComplete--;
      if (yetToComplete == 0) {
        controller.close();
      }
    }).catchError((error) {
      controller.addError(error);
      yetToComplete--;
      if (yetToComplete == 0) {
        controller.close();
      }
    });
  }

  return controller.stream;
}
