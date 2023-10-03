import '../anyhow.dart';

// extension FlattenExtension<S,F, F2> on Result<Result<S,F>,F2> {
//   /// Converts a [Result] of a [Result] into a single [Result]
//   Result<S,F> flatten() {
//
//   }
// }

extension TransposeResult<S, F> on Result<S?,F> {

  /// transposes a [Result] of a nullable type into a nullable [Result].
  Result<S,F>? transpose(){
    if(isOk()){
      final val = unwrap();
      if(val == null) {
        return null;
      }
      else {
        return Result.ok(val);
      }
    }
    else {
      return null;
    }
  }
}


/// Adds methods for converting any object
/// into a [Result] type ([Ok] or [Err]).
extension ResultObjectExtension<W> on W {
  /// Convert the object to a [Result] type [Err].
  ///
  /// Will throw an error if used on a [Result] or [Future] instance.
  Err<S, W> toErr<S>() {
    assert(this is! Result, 'Don\'t use the "toError()" method on instances of Result.');
    assert(this is! Future, 'Don\'t use the "toError()" method on instances of Future.');

    return Err<S, W>(this);
  }

  /// Convert the object to a [Result] type [Ok].
  ///
  /// Will throw an error if used on a [Result] or [Future] instance.
  Ok<W, F> toOk<F>() {
    assert(this is! Result, 'Don\'t use the "toOk()" method on instances of Result.');
    assert(this is! Future, 'Don\'t use the "toOk()" method on instances of Future.');
    return Ok<W, F>(this);
  }
}


