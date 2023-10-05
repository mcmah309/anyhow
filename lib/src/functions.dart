import '../anyhow.dart';

/// Convenience function for turning an object into an [Error] Result. If [err] is already an [Error],
/// you may want to actually unwrap the error.
Err<S, Error> bail<S>(Object err){
  return Err(Error(err));
}

Error anyhow<S>(Object err){
  return Error(err);
}
