import 'package:meta/meta.dart';

import '../anyhow.dart';
import 'async_result.dart';
import 'unit.dart' as type_unit;

/// When a function will return a [Result] and the [Err] value may be the union of any number of [Object]s use [Anyhow].
typedef Anyhow<S> = Result<S, Object>;

/// [Result] class representing the type union between [Ok] and [Err].
///
/// [S] is the ok type (aka success) and [F] is an error (aka failure).
@sealed
abstract class Result<S, F extends Object> {
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
  Result<S, W> mapError<W extends Object>(W Function(F error) fn);

  /// If [Ok], Returns a new [Result] mapping the [Ok] value with
  /// the given transformation and unwrapping the produced [Result].
  Result<W, F> flatMap<W>(Result<W, F> Function(S ok) fn);

  /// If [Err], Returns a new [Result] mapping the [Err] value with
  /// the given transformation and unwrapping the produced [Result].
  Result<S, W> flatMapError<W extends Object>(Result<S, W> Function(F error) fn);

  /// If [Ok], Calls the provided closure with the ok value, else does nothing.
  Result<S, F> inspect(void Function(S ok) fn);

  /// If [Err], Calls the provided closure with the err value, else does nothing.
  Result<S, F> inspectErr(void Function(F error) fn);

  //************************************************************************//

  /// Return a [AsyncResult].
  AsyncResult<S, F> toAsyncResult();

  /// Up casts this [Result] to [Anyhow].
  Anyhow<S> upCast();

  /// Performs a shallow copy of this result.
  Result<S, F> copy();

  //************************************************************************//

  Result<S, F> context(Object context);

  Result<S, F> withContext(Object Function() fn);

  @mustBeOverridden
  String toString();
}

/// Ok Result.
///
/// Returned when the result is an expected value
@immutable
class Ok<S, F extends Object> implements Result<S, F> {
  /// Receives the [S] param as
  /// the ok result.
  const Ok(
    this._ok,
  );

  /// Build a [Ok] with [Unit] value.
  /// ```dart
  /// Ok.unit() == Ok(unit)
  /// ```
  static Ok<type_unit.Unit, F> unit<F extends Object>() {
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
  Result<S, W> mapError<W extends Object>(W Function(F error) fn) {
    return Ok<S, W>(_ok);
  }

  @override
  Result<W, F> flatMap<W>(Result<W, F> Function(S ok) fn) {
    return fn(_ok);
  }

  @override
  Result<S, W> flatMapError<W extends Object>(
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
  AsyncResult<S, F> toAsyncResult() async => this;

  Anyhow<S> upCast() {
    return this;
  }

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
    return "Ok( $_ok )";
  }
}

/// Error Result.
///
/// Returned when the result is an unexpected value
@immutable
class Err<S, F extends Object> implements Result<S, F>, Exception {
  /// Receives the [F] param as
  /// the error result.
  Err(F _error) {
    _contexts.add(_error);
  }

  /// Build a [Err] with [Unit] value.
  /// ```dart
  /// Error.unit() == Error(unit)
  /// ```
  static Err<S, type_unit.Unit> unit<S>() {
    return Err<S, type_unit.Unit>(type_unit.unit);
  }

  static ErrDisplayFormat displayFormat = ErrDisplayFormat.contextBased;

  final List<Object> _contexts = [];

  //************************************************************************//

  @override
  S unwrap() {
    throw Panic(this, "called `unwrap()`");
  }

  @override
  S unwrapOr(S defaultValue) => defaultValue;

  @override
  S unwrapOrElse(S Function(F error) onError) {
    return onError(_contexts.first as F);
  }

  @override
  S? unwrapOrNull() => null;

  @override
  F unwrapErr() {
    return _contexts.first as F;
  }

  @override
  F unwrapErrOr(F defaultValue) {
    return _contexts.first as F;
  }

  @override
  F unwrapErrOrElse(F Function(S ok) onOk) {
    return _contexts.first as F;
  }

  @override
  F unwrapErrOrNull() => _contexts.first as F;

  @override
  S expect(String message) {
    throw Panic(this, message);
  }

  @override
  F expectErr(String message) {
    return _contexts.first as F;
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
    return onError(_contexts.first as F);
  }

  @override
  Result<W, F> map<W>(W Function(S ok) fn) {
    return Err<W, F>(_contexts.first as F);
  }

  @override
  Result<S, W> mapError<W extends Object>(W Function(F error) fn) {
    final newError = fn(_contexts.first as F);
    return Err(newError);
  }

  @override
  Result<W, F> flatMap<W>(Result<W, F> Function(S ok) fn) {
    return Err<W, F>(_contexts.first as F);
  }

  @override
  Result<S, W> flatMapError<W extends Object>(
    Result<S, W> Function(F error) fn,
  ) {
    return fn(_contexts.first as F);
  }

  Result<S, F> inspect(void Function(S ok) fn) {
    return this;
  }

  Result<S, F> inspectErr(void Function(F error) fn) {
    fn(_contexts.first as F);
    return this;
  }

  //************************************************************************//

  @override
  AsyncResult<S, F> toAsyncResult() async => this;

  Anyhow<S> upCast() {
    return this;
  }

  Result<S, F> copy() {
    return Err(_contexts.first as F);
  }

  //************************************************************************//

  Result<S, F> context(Object context) {
    _contexts.add(context);
    return this;
  }

  Result<S, F> withContext(Object Function() fn) {
    return context(fn());
  }

  //************************************************************************//

  @override
  int get hashCode => (_contexts.first as F).hashCode;

  @override
  bool operator ==(Object other) => other is Err && other._contexts.first == _contexts.first;

  @override
  String toString() {
    final StringBuffer stringBuf = StringBuffer();
    switch (displayFormat) {
      case ErrDisplayFormat.traditionalAnyhow:
        final reversed = _contexts.reversed.iterator;
        reversed.moveNext();
        stringBuf.write("Error: ${reversed.current}\n");
        int length = _contexts.length;
        if (length > 1) {
          stringBuf.write("\nCaused by:\n");
          int index = 0;
          while (reversed.moveNext()) {
            stringBuf.write("\t${index}: ${reversed.current}\n");
            index++;
          }
        }
        break;
      case ErrDisplayFormat.contextBased:
        final iter = _contexts.iterator;
        iter.moveNext();
        stringBuf.write("Root Cause: ${_contexts.first}\n");
        int length = _contexts.length;
        if (length > 1) {
          stringBuf.write("\nAdditional Context:\n");
          int index = 0;
          while (iter.moveNext()) {
            stringBuf.write("\t${index}: ${iter.current}\n");
            index++;
          }
        }
        break;
    }
    return stringBuf.toString();
  }
}

enum ErrDisplayFormat { traditionalAnyhow, contextBased }
