import '../anyhow.dart';

// extension FlattenExtension1<S,F extends AnyhowError, F2 extends F> on Result<Result<S,F>,F2> {
//   /// Converts a [Result] of a [Result] into a single [Result]
//   Result<S,F> flatten() {
//     if(isOk()){
//       return unwrap();
//     }
//     return Err(unwrapErr());
//   }
// }
//
// extension FlattenExtension2<S,F extends F2, F2 extends AnyhowError> on Result<Result<S,F>,F2> {
//   /// Converts a [Result] of a [Result] into a single [Result]
//   Result<S,F2> flatten() {
//     if(isOk()){
//       return unwrap();
//     }
//     return Err(unwrapErr());
//   }
// }

extension FlattenExtension3<S,F extends Error, F2 extends Error> on AResult<AResult<S,F>,F2> {
  /// Converts a [AResult] of a [AResult] into a single [AResult]
  Result<S> flatten() {
    if(isOk()){
      return unwrap();
    }
    return Err(unwrapErr());
  }
}

extension TransposeResult<S, F extends Error> on AResult<S?, F> {

  /// transposes a [AResult] of a nullable type into a nullable [AResult].
  AResult<S, F>? transpose() {
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


/// Adds methods for converting any object
/// into a [AResult] type ([Ok] or [Err]).
extension ResultObjectNullableExtension<W> on W {

  /// Convert the object to a [AResult] type [Ok].
  ///
  /// Will throw an error if used on a [AResult] or [Future] instance.
  Ok<W, F> toOk<F extends Error>() {
    assert(this is! AResult, 'Don\'t use the "toOk()" method on instances of Result.');
    assert(this is! Future, 'Don\'t use the "toOk()" method on instances of Future.');
    return Ok<W, F>(this);
  }
}

extension ResultObjectExtension<W extends Object> on W {
  /// Convert the object to a [AResult] type [Err].
  ///
  /// Will throw an error if used on a [AResult] or [Future] instance.
  Err<S, Error> toErr<S>() {
    assert(this is! AResult, 'Don\'t use the "toError()" method on instances of Result.');
    assert(this is! Future, 'Don\'t use the "toError()" method on instances of Future.');
    return Err<S, Error>(Error(this));
  }
}

extension ResultIterableExtensions<S, F extends Error> on Iterable<AResult<S, F>> {
  /// Transforms an Iterable of results into a single result where the ok value is the list of all successes. If any
  /// error is encountered, the first error becomes the root error. Therefore, to upon encountering an error, no
  /// errors will be dropped
  Result<List<S>> toResult() {
    List<S> list = [];
    AResult<List<S>, F> finalResult = Ok(list);
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


