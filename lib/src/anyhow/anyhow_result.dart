part of 'anyhow_error.dart';

/// {@macro futureResult}
typedef FutureResult<S> = Future<Result<S>>;
/// {@macro result}
typedef Result<S> = BaseResult<S,Error>;
/// {@macro ok}
typedef Ok<S> = BaseOk<S,Error>;
/// {@macro err}
typedef Err<S> = BaseErr<S,Error>;

// abstract class Result<S> extends BaseResult<S,Error> {
//
//   /// Adds the object as additional context to the [Error]. The context should not be an instance of
//   /// [Error].
//   Result<S> context(Object context);
//
//   /// Lazily calls the function if the [Result] is an [Err] and adds the object as additional context to the
//   /// [Error]. The context should not be an instance of [Error].
//   Result<S> withContext(Object Function() fn);
// }
//
// class Ok<S> extends BaseOk<S,Error> implements Result<S> {
//   Ok(super.ok);
//
//   /// Build a [Ok] with [Unit] value.
//   /// ```dart
//   /// Ok.unit() == Ok(unit)
//   /// ```
//   static Ok<Unit> unit() {
//     return Ok<Unit>(type_unit.unit);
//   }
//
//   Result<S> context(Object context) {
//     return this;
//   }
//
//   Result<S> withContext(Object Function() fn) {
//     return this;
//   }
// }
//
// class Err<S> extends BaseErr<S,Error> implements Result<S> {
//   Err(super.error);
//
//   Result<S> context(Object context) {
//     assert(context is! Error, "The context should not already be an instance of AnyhowError. If it is, you are "
//         "likely using the api wrong. If you need to combine AnyhowErrors see \"and\" and \"andThen\" methods. If this"
//         " is a valid use case please submit a PR.");
//     error._add(Error(context));
//     return this;
//   }
//
//   Result<S> withContext(Object Function() fn) {
//     return context(fn());
//   }
// }