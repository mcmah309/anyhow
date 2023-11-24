import 'package:anyhow/base.dart';

/// The error type for errors that can never happen
typedef Infallible = Never;

extension InfallibleOkExtension<S> on Result<S, Infallible> {
  S intoOk() {
    return unwrap();
  }
}

extension InfallibleErrExtension<F extends Object> on Result<Infallible, F> {
  F intoErr() {
    return unwrapErr();
  }
}
