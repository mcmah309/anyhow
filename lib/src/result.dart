import 'package:meta/meta.dart';

import '../anyhow.dart';
import 'unit.dart' as type_unit;

part 'anyhow_error.dart';

/// When a function will return a [Result] and the [Err] value may be the union of any number of [Object]s use [Anyhow].
typedef Anyhow<S> = Result<S, AnyhowError>;

/// [Result] class representing the type union between [Ok] and [Err].
///
/// [S] is the ok type (aka success) and [F] is an error (aka failure).
@sealed
abstract class Result<S, F extends AnyhowError> {
  /// Build a [Result] that returns a [Err].
  factory Result.ok(S s) => Ok(s);

  /// Build a [Result] that returns a [Err].
  factory Result.err(F e) => Err(e);

  //************************************************************************//

  /// Returns the ok value if [Result] is [Ok].
  /// Throws a [Panic] if the [Result] is [Err].
  S unwrap();

  /// Returns the encapsulated value if this instance represents
  /// [Ok] or the [defaultValue] if it is [Err].
  /// Note: This should not be used to determine is [Ok] or is [Err], since when the success type is nullable, a
  /// default value of null can be provided, which is ambiguous in meaning.
  S unwrapOr(S defaultValue);

  /// Returns the encapsulated value if this instance represents [Ok]
  /// or the result of [onError] function for
  /// the encapsulated a [Err] value.
  /// Note: This should not be used to determine is [Ok] or is [Err], since when the success type is nullable,
  /// the value returned can be null, which is ambiguous in meaning.
  S unwrapOrElse(S Function(F error) onError);

  /// Returns the value of [Ok] or null.
  /// Note: This should not be used to determine is [Ok] or is [Err], since when the success type is nullable, a
  /// null is ambiguous in meaning.
  S? unwrapOrNull();

  /// Returns the err value if [Result] is [Err].
  /// Throws a [Panic] if the [Result] is [Ok].
  F unwrapErr();

  /// Returns the encapsulated value if this instance represents
  /// [Err] or the [defaultValue] if it is [Ok].
  /// Note: This should not be used to determine is [Ok] or is [Err], since when the failure type is nullable, a
  /// default value of null can be provided, which is ambiguous in meaning.
  F unwrapErrOr(F defaultValue);

  /// Returns the encapsulated value if this instance represents [Err]
  /// or the result of [onError] function for
  /// the encapsulated a [Err] value.
  /// Note: This should not be used to determine is [Ok] or is [Err], since when the failure type is nullable,
  /// the value returned can be null, which is ambiguous in meaning.
  F unwrapErrOrElse(F Function(S ok) onOk);

  /// Returns the err value if [Result] is [Err].
  /// returns null if the [Result] is [Ok].
  /// Note: This should not be used to determine is [Ok] or is [Err], since when the failure type is nullable, a
  /// null is ambiguous in meaning.
  F? unwrapErrOrNull();

  /// Returns the ok value if [Result] is [Ok].
  /// Throws a [Panic] if the [Result] is [Err], with the provided [message].
  S expect(String message);

  /// Returns the err value if [Result] is [Err].
  /// Throws a [Panic] if the [Result] is [Ok], with the provided [message].
  F expectErr(String message);

  //************************************************************************//

  /// Returns true if the current result is an [Err].
  bool isErr();

  /// Returns true if the current result is a [Ok].
  bool isOk();

  //************************************************************************//

  /// Returns the result of [onOk] for the encapsulated value
  /// if this instance represents [Ok] or the result of [onError] function
  /// for the encapsulated value if it is [Err].
  W match<W>(
    W Function(S ok) onOk,
    W Function(F err) onError,
  );

  /// Returns a new [Result], mapping any [Ok] value
  /// using the given transformation.
  Result<W, F> map<W>(W Function(S ok) fn);

  /// Returns a new [Result], mapping any [Err] value
  /// using the given transformation.
  Result<S, W> mapErr<W extends AnyhowError>(W Function(F error) fn);

  /// If [Ok], Returns a new [Result] mapping the [Ok] value with
  /// the given transformation and unwrapping the produced [Result].
  Result<W, F> flatMap<W>(Result<W, F> Function(S ok) fn);

  /// If [Err], Returns a new [Result] mapping the [Err] value with
  /// the given transformation and unwrapping the produced [Result].
  Result<S, W> flatMapErr<W extends AnyhowError>(Result<S, W> Function(F error) fn);

  /// If [Ok], Calls the provided closure with the ok value, else does nothing.
  Result<S, F> inspect(void Function(S ok) fn);

  /// If [Err], Calls the provided closure with the err value, else does nothing.
  Result<S, F> inspectErr(void Function(F error) fn);

  //************************************************************************//

  /// Return a [FutureResult].
  FutureResult<S, F> toFutureResult();

  /// Performs a shallow copy of this result.
  Result<S, F> copy();

  //************************************************************************//

  /// Adds the object as additional context to the [AnyhowError]. The context should not be an instance of
  /// [AnyhowError].
  Result<S, F> context(Object context);

  /// Lazily calls the function if the [Result] is an [Err] and adds the object as additional context to the
  /// [AnyhowError]. The context should not be an instance of [AnyhowError].
  Result<S, F> withContext(Object Function() fn);

  @mustBeOverridden
  String toString();
}

/// Ok Result.
///
/// Returned when the result is an expected value
@immutable
class Ok<S, F extends AnyhowError> implements Result<S, F> {
  /// Receives the [S] param as
  /// the ok result.
  const Ok(
    this._ok,
  );

  /// Build a [Ok] with [Unit] value.
  /// ```dart
  /// Ok.unit() == Ok(unit)
  /// ```
  static Ok<type_unit.Unit, F> unit<F extends AnyhowError>() {
    return Ok<type_unit.Unit, F>(type_unit.unit);
  }

  final S _ok;

  //************************************************************************//

  @override
  S unwrap() {
    return _ok;
  }

  @override
  S unwrapOr(S defaultValue) => _ok;

  @override
  S unwrapOrElse(S Function(F error) onError) {
    return _ok;
  }

  @override
  S unwrapOrNull() => _ok;

  @override
  F unwrapErr() {
    throw Panic(this, "called `err`");
  }

  @override
  F unwrapErrOr(F defaultValue) {
    return defaultValue;
  }

  @override
  F unwrapErrOrElse(F Function(S ok) onOk) {
    return onOk(_ok);
  }

  @override
  F? unwrapErrOrNull() => null;

  @override
  S expect(String message) {
    return _ok;
  }

  @override
  F expectErr(String message) {
    throw Panic(this, message);
  }

  //************************************************************************//

  @override
  bool isErr() => false;

  @override
  bool isOk() => true;

  //************************************************************************//

  @override
  W match<W>(
    W Function(S ok) onOk,
    W Function(F error) onError,
  ) {
    return onOk(_ok);
  }

  @override
  Result<W, F> map<W>(W Function(S ok) fn) {
    final newOk = fn(_ok);
    return Ok<W, F>(newOk);
  }

  @override
  Result<S, W> mapErr<W extends AnyhowError>(W Function(F error) fn) {
    return Ok<S, W>(_ok);
  }

  @override
  Result<W, F> flatMap<W>(Result<W, F> Function(S ok) fn) {
    return fn(_ok);
  }

  @override
  Result<S, W> flatMapErr<W extends AnyhowError>(
    Result<S, W> Function(F error) fn,
  ) {
    return Ok<S, W>(_ok);
  }

  Result<S, F> inspect(void Function(S ok) fn) {
    fn(_ok);
    return this;
  }

  Result<S, F> inspectErr(void Function(F error) fn) {
    return this;
  }

  //************************************************************************//

  @override
  FutureResult<S, F> toFutureResult() async => this;

  Result<S, F> copy() {
    return Ok(_ok);
  }

  //************************************************************************//

  Result<S, F> context(Object context) {
    return this;
  }

  Result<S, F> withContext(Object Function() fn) {
    return this;
  }

  //************************************************************************//

  @override
  int get hashCode => _ok.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Ok && other._ok == _ok;
  }

  @override
  String toString() {
    return "$_ok";
  }
}

/// Error Result.
///
/// Returned when the result is an unexpected value
@immutable
class Err<S, F extends AnyhowError> implements Result<S, F> {
  /// Receives the [F] param as
  /// the error result.
  const Err(this._error);

  /// Shorthand for creating an anyhow error. See also [anyhow] in functions.dart for an evens shorter style.
  static Err<S,AnyhowError> anyhow<S>(Object error) => Err<S,AnyhowError>(AnyhowError(error));

  final F _error;

  //************************************************************************//

  @override
  S unwrap() {
    throw Panic(this, "called `unwrap()`");
  }

  @override
  S unwrapOr(S defaultValue) => defaultValue;

  @override
  S unwrapOrElse(S Function(F error) onError) {
    return onError(_error);
  }

  @override
  S? unwrapOrNull() => null;

  @override
  F unwrapErr() {
    return _error;
  }

  @override
  F unwrapErrOr(F defaultValue) {
    return _error;
  }

  @override
  F unwrapErrOrElse(F Function(S ok) onOk) {
    return _error;
  }

  @override
  F unwrapErrOrNull() => _error;

  @override
  S expect(String message) {
    throw Panic(this, message);
  }

  @override
  F expectErr(String message) {
    return _error;
  }

  //************************************************************************//

  @override
  bool isErr() => true;

  @override
  bool isOk() => false;

  //************************************************************************//

  @override
  W match<W>(
    W Function(S succcess) onOk,
    W Function(F error) onError,
  ) {
    return onError(_error);
  }

  @override
  Result<W, F> map<W>(W Function(S ok) fn) {
    return Err<W, F>(_error);
  }

  @override
  Result<S, W> mapErr<W extends AnyhowError>(W Function(F error) fn) {
    final newError = fn(_error);
    return Err(newError);
  }

  @override
  Result<W, F> flatMap<W>(Result<W, F> Function(S ok) fn) {
    return Err<W, F>(_error);
  }

  @override
  Result<S, W> flatMapErr<W extends AnyhowError>(
    Result<S, W> Function(F error) fn,
  ) {
    return fn(_error);
  }

  Result<S, F> inspect(void Function(S ok) fn) {
    return this;
  }

  Result<S, F> inspectErr(void Function(F error) fn) {
    fn(_error);
    return this;
  }

  //************************************************************************//

  @override
  FutureResult<S, F> toFutureResult() async => this;

  Result<S, F> copy() {
    return Err(_error);
  }

  //************************************************************************//

  Result<S, F> context(Object context) {
    assert(context is! AnyhowError, "The context should not already be an instance of AnyhowError. If it is, you are "
        "likely using the api wrong. If you need to combine AnyhowErrors see \"and\" and \"andThen\" methods. If this"
        " is a valid use case please submit a PR.");
    _error.latest()._additionalContext = AnyhowError(context);
    return this;
  }

  Result<S, F> withContext(Object Function() fn) {
    return context(fn());
  }

  //************************************************************************//

  @override
  int get hashCode => _error.hashCode;

  @override
  bool operator ==(Object other) => other is Err && other._error == _error;

  @override
  String toString(){
    return "$_error";
  }
}


