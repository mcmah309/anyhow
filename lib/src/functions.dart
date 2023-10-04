import '../anyhow.dart';

/// Convenience function for turning an object into an [AnyhowError] Result. If [err] is already an [AnyhowError],
/// you may want to actually unwrap the error.
Err<S, AnyhowError> anyhow<S>(Object err){
  return Err(AnyhowError(err));
}
