import '../../base.dart';
import 'unit.dart' as type_unit;

/// {@template result}
/// [Result] class representing the type union between [Ok] and [Err].
///
/// [S] is the ok type (aka success) and [F] is an error (aka failure).
/// Aims to implements at minimum, through methods or extensions, the Rust Result specification here: https://doc
/// .rust-lang
/// .org/std/result/enum.Result.html
/// {@endtemplate}
sealed class Result<S, F extends Object> {

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
  F unwrapErrOr(F defaultValue);

  /// Returns the encapsulated value if this instance represents [Err]
  /// or the result of [onError] function for
  /// the encapsulated a [Err] value.
  F unwrapErrOrElse(F Function(S ok) onOk);

  /// Returns the err value if [Result] is [Err], otherwise returns null.
  /// This can be used to determine is [Ok] or is [Err], since when the failure type is not nullable, so a returned
  /// null value means this is not an [Err].
  /// Same as "err()" in Rust, but "err" is a field name here
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

  /// Performs an "and" operation on the results. Returns the
  /// first result that is [Err], otherwise if both are [Ok], this [Ok] Result is returned.
  Result<dynamic, Object> and<S2, F2 extends Object>(Result<S2, F2> other);

  /// Performs an "or" operation on the results. Returns the first [Ok] value, if neither are [Ok], returns
  /// the other [Err].
  Result<dynamic, Object> or<S2, F2 extends Object>(Result<S2, F2> other);

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
  Result<S, W> mapErr<W extends Object>(W Function(F error) fn);

  /// If [Ok], Returns a new [Result] by passing the [Ok] value
  /// to the provided function.
  Result<W, F> andThen<W>(Result<W, F> Function(S ok) fn);

  //// If [Err], Returns a new [Result] by passing the [Err] value
  /// to the provided function.
  Result<S, W> andThenErr<W extends Object>(Result<S, W> Function(F error) fn);

  /// If [Ok], Calls the provided closure with the ok value, else does nothing.
  Result<S, F> inspect(void Function(S ok) fn);

  /// If [Err], Calls the provided closure with the err value, else does nothing.
  Result<S, F> inspectErr(void Function(F error) fn);

  /// Performs a shallow copy of this result.
  Result<S, F> copy();
  //************************************************************************//

  /// Changes the [Ok] type to [S2]. See [into] for a safe implementation of [intoUnchecked]. This is usually used
  /// when "this" is known to be an [Err] and you want to return to
  /// the calling function, but the returning function's [Ok] type is different from this [Ok] type.
  ///
  /// Throws a [Panic] if this is not an [Err] and cannot cast the [Ok] value to [S2].
  /// Example of proper use:
  /// ```dart
  /// Result<int,String> someFunction1 () {...}
  ///
  /// Result<String,String> someFunction2() {
  ///   Result<int,String> result = someFunction1();
  ///   if (result.isErr()) {
  ///     return result.intoUnchecked();
  ///   }
  /// ...
  ///```
  /// Note how above, the [S2] value is inferred by Dart, this is usually what be want rather than being explicit.
  /// In Rust, "intoUnchecked" is handled by the "?" operator, but there is no equivalent in Dart.
  Result<S2, F> intoUnchecked<S2>();
}

/// {@template ok}
/// Ok Result.
///
/// Returned when the result is an expected value
/// {@endtemplate}
final class Ok<S, F extends Object> implements Result<S, F> {
  /// Receives the [S] param as
  /// the ok result.
  const Ok(
    this.ok,
  );

  /// Build a [Ok] with [Unit] value.
  /// ```dart
  /// Ok.unit() == Ok(unit)
  /// ```
  static Ok<type_unit.Unit, F> unit<F extends Object>() {
    return Ok<type_unit.Unit, F>(type_unit.unit);
  }

  final S ok;

  //************************************************************************//

  @override
  S unwrap() {
    return ok;
  }

  @override
  S unwrapOr(S defaultValue) => ok;

  @override
  S unwrapOrElse(S Function(F error) onError) {
    return ok;
  }

  @override
  S unwrapOrNull() => ok;

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
    return onOk(ok);
  }

  @override
  F? unwrapErrOrNull() => null;

  @override
  S expect(String message) {
    return ok;
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
  Result<dynamic, Object> and<S2, F2 extends Object>(Result<S2, F2> other){
    if(other.isOk()){
      return this;
    }
    return other;
  }

  @override
  Result<dynamic, Object> or<S2, F2 extends Object>(Result<S2, F2> other){
    return this;
  }

  //************************************************************************//

  @override
  W match<W>(
    W Function(S ok) onOk,
    W Function(F error) onError,
  ) {
    return onOk(ok);
  }

  @override
  Result<W, F> map<W>(W Function(S ok) fn) {
    final newOk = fn(ok);
    return Ok<W, F>(newOk);
  }

  @override
  Result<S, W> mapErr<W extends Object>(W Function(F error) fn) {
    return Ok<S, W>(ok);
  }

  @override
  Result<W, F> andThen<W>(Result<W, F> Function(S ok) fn) {
    return fn(ok);
  }

  @override
  Result<S, W> andThenErr<W extends Object>(
    Result<S, W> Function(F error) fn,
  ) {
    return Ok<S, W>(ok);
  }

  @override
  Result<S, F> inspect(void Function(S ok) fn) {
    fn(ok);
    return this;
  }

  @override
  Result<S, F> inspectErr(void Function(F error) fn) {
    return this;
  }

  @override
  Result<S, F> copy() {
    return Ok(ok);
  }

  //************************************************************************//

  @override
  Result<S2, F> intoUnchecked<S2>(){
    if(ok is S2){
      return Ok(ok as S2);
    }
    throw Panic(this,"attempted to cast ${S.runtimeType} to ${S2.runtimeType}");
  }

  //************************************************************************//

  @override
  int get hashCode => ok.hashCode;

  @override
  bool operator ==(Object other) {
    return other is Ok && other.ok == ok;
  }

  @override
  String toString() {
    return "$ok";
  }
}

/// {@template err}
/// Error Result.
///
/// Returned when the result is an unexpected value
/// {@endtemplate}
final class Err<S, F extends Object> implements Result<S, F> {
  /// Receives the [F] param as
  /// the error result.
  const Err(this.err);

  final F err;

  //************************************************************************//

  @override
  S unwrap() {
    throw Panic(this, "called `unwrap()`");
  }

  @override
  S unwrapOr(S defaultValue) => defaultValue;

  @override
  S unwrapOrElse(S Function(F error) onError) {
    return onError(err);
  }

  @override
  S? unwrapOrNull() => null;

  @override
  F unwrapErr() {
    return err;
  }

  @override
  F unwrapErrOr(F defaultValue) {
    return err;
  }

  @override
  F unwrapErrOrElse(F Function(S ok) onOk) {
    return err;
  }

  @override
  F unwrapErrOrNull() => err;

  @override
  S expect(String message) {
    throw Panic(this, message);
  }

  @override
  F expectErr(String message) {
    return err;
  }

  //************************************************************************//

  @override
  bool isErr() => true;

  @override
  bool isOk() => false;

  //************************************************************************//

  @override
  Result<dynamic, Object> and<S2, F2 extends Object>(Result<S2, F2> other){
    return this;
  }

  @override
  Result<dynamic, Object> or<S2, F2 extends Object>(Result<S2, F2> other){
    return other;
  }

  //************************************************************************//

  @override
  W match<W>(
    W Function(S succcess) onOk,
    W Function(F error) onError,
  ) {
    return onError(err);
  }

  @override
  Result<W, F> map<W>(W Function(S ok) fn) {
    return Err<W, F>(err);
  }

  @override
  Result<S, W> mapErr<W extends Object>(W Function(F error) fn) {
    final newError = fn(err);
    return Err(newError);
  }

  @override
  Result<W, F> andThen<W>(Result<W, F> Function(S ok) fn) {
    return Err<W, F>(err);
  }

  @override
  Result<S, W> andThenErr<W extends Object>(
    Result<S, W> Function(F error) fn,
  ) {
    return fn(err);
  }

  @override
  Result<S, F> inspect(void Function(S ok) fn) {
    return this;
  }

  @override
  Result<S, F> inspectErr(void Function(F error) fn) {
    fn(err);
    return this;
  }

  @override
  Result<S, F> copy() {
    return Err(err);
  }

  //************************************************************************//

  @override
  Result<S2, F> intoUnchecked<S2>(){
    return Err(err);
  }

  /// Changes the [Ok] type to [S2]. This is usually used when "this" is known to be an [Err] and you want to return to
  /// the calling function, but the returning function's [Ok] type is different from this [Ok] type.
  ///
  /// Example of proper use:
  /// ```dart
  /// Result<int,String> someFunction1 () {...}
  ///
  /// Result<String,String> someFunction2() {
  ///   Result<int,String> result = someFunction1();
  ///   if (result case Err()) {
  ///     return result.into();
  ///   }
  /// ...
  ///```
  /// Note how above, the [S2] value is inferred by Dart, this is usually what be want rather than being explicit.
  /// Note: In Rust, "into" is handled by the "?" operator, but there is no equivalent in Dart.
  Err<S2, F> into<S2>(){
    return Err(err);
  }

  //************************************************************************//

  @override
  int get hashCode => err.hashCode;

  @override
  bool operator ==(Object other) => other is Err && other.err == err;

  @override
  String toString(){
    return "$err";
  }
}


