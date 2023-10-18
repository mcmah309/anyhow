import '../../base.dart';

extension FlattenExtension1<S,F extends Object> on Result<Result<S,F>,F> {
  /// Converts a [Result] of a [Result] into a single [Result]
  Result<S,F> flatten() {
    if(isOk()){
      return unwrap();
    }
    return Err(unwrapErr());
  }
}

// Dart does not realize this is less specific
// extension FlattenExtension2<S,F extends Object, F2 extends Object> on Result<Result<S,F>,F2> {
//   /// Converts a [Result] of a [Result] into a single [Result]
//   Result<S,Object> flatten() {
//     if(isOk()){
//       return unwrap();
//     }
//     return Err(unwrapErr());
//   }
// }

extension TransposeResult<S, F extends Object> on Result<S?, F> {

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

extension ResultIterableExtensions<S, F extends Object> on Iterable<Result<S, F>> {
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

