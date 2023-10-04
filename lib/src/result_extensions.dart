import '../anyhow.dart';

// extension FlattenExtension1<S,F extends Object, F2 extends F> on Result<Result<S,F>,F2> {
//   /// Converts a [Result] of a [Result] into a single [Result]
//   Result<S,F> flatten() {
//     if(isOk()){
//       return unwrap();
//     }
//     return Err(unwrapErr());
//   }
// }
//
// extension FlattenExtension2<S,F extends F2, F2 extends Object> on Result<Result<S,F>,F2> {
//   /// Converts a [Result] of a [Result] into a single [Result]
//   Result<S,F2> flatten() {
//     if(isOk()){
//       return unwrap();
//     }
//     return Err(unwrapErr());
//   }
// }

extension FlattenExtension3<S,F extends Object, F2 extends Object> on Result<Result<S,F>,F2> {
  /// Converts a [Result] of a [Result] into a single [Result]
  Result<S,Object> flatten() {
    if(isOk()){
      return unwrap();
    }
    return Err(unwrapErr());
  }
}

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


/// Adds methods for converting any object
/// into a [Result] type ([Ok] or [Err]).
extension ResultObjectNullableExtension<W> on W {

  /// Convert the object to a [Result] type [Ok].
  ///
  /// Will throw an error if used on a [Result] or [Future] instance.
  Ok<W, F> toOk<F extends Object>() {
    assert(this is! Result, 'Don\'t use the "toOk()" method on instances of Result.');
    assert(this is! Future, 'Don\'t use the "toOk()" method on instances of Future.');
    return Ok<W, F>(this);
  }
}

extension ResultObjectExtension<W extends Object> on W {
  /// Convert the object to a [Result] type [Err].
  ///
  /// Will throw an error if used on a [Result] or [Future] instance.
  Err<S, W> toErr<S>() {
    assert(this is! Result, 'Don\'t use the "toError()" method on instances of Result.');
    assert(this is! Future, 'Don\'t use the "toError()" method on instances of Future.');
    return Err<S, W>(this);
  }
}

extension ResultIterableExtensions<S, F extends Object> on Iterable<Result<S, F>> {
  /// Transforms an Iterable of results into a single result where the ok value is the list of all successes. If any
  /// error is encountered, the first error is returned as the error result, with the subsequent errors as it's context.
  Anyhow<List<S>> toResult() {
    List<S> list = [];
    Result<List<S>, F> finalResult = Ok(list);
    for (final result in this) {
      if (finalResult.isOk()) {
        if (result.isErr()) {
          finalResult = Err(result.unwrapErr());
        }
        list.add(result.unwrap());
      }
      if (result.isErr()) {
        finalResult.context(result.unwrapErr().toString());
      }
    }
    return finalResult;
  }
}

