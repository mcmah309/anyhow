# anyhow

[![Pub Version](https://img.shields.io/pub/v/anyhow.svg)](https://pub.dev/packages/anyhow)
[![Dart Package Docs](https://img.shields.io/badge/documentation-pub.dev-blue.svg)](https://pub.dev/documentation/anyhow/latest/)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://github.com/mcmah309/anyhow/actions/workflows/dart.yml/badge.svg)](https://github.com/mcmah309/anyhow/actions)

Anyhow offers versatile and idiomatic error handling capabilities to make your code safer and errors easier to debug.

This is accomplished through providing a Dart implementation of the Rust [Result] monad type, and
an implementation of the popular Rust crate with the same name - [anyhow].
Anyhow will allow you to never throw another exception again and have a predictable control flow. When
errors do arise, you can add `context` to better understand the situation tha lead to the errors.
See [Anyhow Result Type Error Handling](#anyhow-result-type-error-handling) to jump right into an example.

## Table of Contents

* [What Is a Result Monad Type And Why Use it?](#what-is-a-result-monad-type-and-why-use-it)
* [Intro to Usage](#intro-to-usage)
    - [Regular Dart Error handling](#regular-dart-error-handling)
        - [What's Wrong with Solution?](#whats-wrong-with-solution)
    - [The Better Ways To Handle Errors With Anyhow](#the-better-ways-to-handle-errors-with-anyhow)
        - [Base Result Type Error Handling](#base-result-type-error-handling)
        - [Anyhow Result Type Error Handling](#anyhow-result-type-error-handling)
        - [Base Result Type vs Anyhow Result Type](#base-result-type-vs-anyhow-result-type)
* [Configuration Options](#configuration-options)
* [Adding Predictable Control Flow To Legacy Dart Code](#adding-predictable-control-flow-to-legacy-dart-code)
* [Dart Equivalent To The Rust "?" Operator](#dart-equivalent-to-the-rust--operator)
* [How to Never Unwrap Incorrectly](#how-to-never-unwrap-incorrectly)
* [Misc](#misc)
    - [Working with Futures](#working-with-futures)
    - [Working With Iterable Results](#working-with-iterable-results)
    - [Panic](#panic)
  - [Null and Unit](#null-and-unit)
  - [Infallible](#infallible)

## What Is a Result Monad Type And Why Use it?
A monad is just a wrapper around an object that provides a standard way of interacting with the inner object. The
`Result` monad is used in place of throwing exceptions. Instead of a function throwing an exception, the function
returns a `Result`, which can either be a `Ok` (Success) or `Err` (Error/Failure), `Result` is the type union
between the two. Before unwrapping the inner object, you check the type of the `Result` through conventions like
`case Ok(:final ok)` and `isOk()`. Checking allows you to
either resolve any potential issues in the calling function or pass the error up the chain until a function resolves
the issue. This provides predictable control flow to your program, eliminating many potential bugs and countless
hours of debugging.

## Intro to Usage
### Regular Dart Error handling
```dart
void main() {
  try {
    print(order("Bob", 1));
  } catch(e) {
    print(e);
  }
}

String order(String user, int orderNumber) {
  final result = makeFood(orderNumber);
  return "Order of $result is complete for $user";
}

String makeFood(int orderNumber) {
  if (orderNumber == 1) {
    return makeHamburger();
  }
  else {
    return "pasta";
  }
}

String makeHamburger() {
  // Who catches this??
  // How do we know we won't forget to catch this??
  // What is the context around this error??
  throw "Hmm something went wrong making the hamburger.";
}
```
#### Output
```text
Hmm something went wrong making the hamburger.
```
#### What's Wrong with Solution?
* If we forget to catch in the correct spot, we just introduced a bug or worse - crashed our entire program.
* We may later reuse `makeHamburger`, `makeFood`, or `order`, and forget that it can throw.
* The more we reuse functions 
that can throw, the less maintainable and error-prone our program becomes. 
* Throwing is also an expensive operation, as it requires stack unwinding.

## The Better Ways To Handle Errors With Anyhow
Other languages address the throwing exception issue by preventing them entirely. Most that do use a `Result` monad.
### Base Result Type Error Handling
With the base `Result` type, implemented based on the Rust standard [Result] type, there are no more undefined 
behaviours due to control flow.
```dart
import 'package:anyhow/base.dart';

void main() {
  print(order("Bob", 1));
}

Result<String, String> order(String user, int orderNumber) {
  final result = makeFood(orderNumber);
  switch (result) {
    case Ok(:final ok):
      return Ok("Order of $ok is complete for $user");
    case Err():
      return result;
  }
}

Result<String, String> makeFood(int orderNumber) {
  if (orderNumber == 1) {
    return makeHamburger();
  }
  else {
    return Ok("pasta");
  }
}

Result<String,String> makeHamburger() {
  // What is the context around this error??
  return Err("Hmm something went wrong making the hamburger.");
}
```
##### Output
```text
Hmm something went wrong making the hamburger.
```

### Anyhow Result Type Error Handling
With the Anyhow `Result` type, we can now add any `Object` as context around errors. To do so, we can use `context` or 
`withContext` (lazily). Either will only have an effect if a `Result` is the `Err` subclass.
```dart
import 'package:anyhow/anyhow.dart';

void main() {
  print(order("Bob", 1));
}

Result<String> order(String user, int orderNumber) {
  final result = makeFood(orderNumber).context("Could not order for user: $user.");
  switch (result) { // Could also use "if(result.isOk())" and "unwrap()"
    case Ok(:final ok):
      return Ok("Order of $ok is complete for $user");
    case Err():
      return result;
  }
}

Result<String> makeFood(int orderNumber) {
  if (orderNumber == 1) {
    return makeHamburger().context("Order number $orderNumber failed.");
  }
  else {
    return Ok("pasta");
  }
}

Result<String> makeHamburger() {
  return bail("Hmm something went wrong making the hamburger.");
}
```
#### Output
```text
Error: Could not order for user: Bob.

Caused by:
	0: Order number 1 failed.
	1: Hmm something went wrong making the hamburger.
```

#### What Would This Look Like Without Anyhow

Before Anyhow, if we wanted to accomplish something similar, we had to do:

```dart
void main() {
  print(order("Bob", 1));
}

Result<String, String> order(String user, int orderNumber) {
  final result = makeFood(orderNumber);
  switch (result) {
    case Ok(:final ok):
      return Ok("Order of $ok is complete for $user");
    case Err():
      Logging.w("Could not order for user: $user.");
      return result;
  }
}

Result<String, String> makeFood(int orderNumber) {
  if (orderNumber == 1) {
    final result = makeHamburger();
    if (result.isErr()) {
      Logging.w("Order number $orderNumber failed.");
    }
    return result;
  }
  else {
    return Ok("pasta");
  }
}

Result<String, String> makeHamburger() {
  // What is the context around this error??
  return Err("Hmm something went wrong making the hamburger.");
}
```

Which is more verbose/error-prone and may not be what we actually want. Since:

1. We may not want to log anything if the error state is
   known and can be recovered from
2. Related logs should be kept together (in the example, other functions could log before this Result had been handled)
3. We have no way to get the correct stack traces related to the original issue
4. We have no way to inspect "context", while with anyhow we can iterate through with `chain()`

Now with anyhow, we are able to better understand and handle errors in an idiomatic way.

### Base Result Type vs Anyhow Result Type
The base `Result` Type and the anyhow `Result` Type can be imported with
```dart
import 'package:anyhow/base.dart' as base;
```
or
```dart
import 'package:anyhow/anyhow.dart' as anyhow;
```
Respectively. Like in anyhow, these types have parity, thus can be used together
```dart
import 'package:anyhow/anyhow.dart' as anyhow;
import 'package:anyhow/base.dart' as base;

void main(){
  base.Result<int,anyhow.Error> x = anyhow.Ok(1); // valid
  anyhow.Result<int> y = base.Ok(1); // valid
  anyhow.Ok(1).context(1); // valid
  base.Ok(1).context(1); // not valid

}
```
The base `Result` type is the standard implementation of the `Result` type and the anyhow `Result` type is the anyhow 
implementation on top of the standard `Result` type.

## Configuration Options

Anyhow functionality can be changed by changing:

```text
Error.hasStackTrace;
Error.rootCauseFirst;
Error.stackTraceDisplayFormat;
```

Which is usually done at startup.

We can include Stack Trace with `Error.hasStackTrace = true`:

```text
Error: Could not order for user: Bob.

Caused by:
	0: Order number 1 failed.
	1: Hmm something went wrong making the hamburger.

StackTrace:
#0      AnyhowResultExtensions.context (package:anyhow/src/anyhow/anyhow_extensions.dart:12:29)
#1      order (package:anyhow/test/src/temp.dart:9:40)
... <OMITTED FOR EXAMPLE>
```

We can view the root cause first with `Error.displayFormat = ErrDisplayFormat.rootCauseFirst`

```text
Root Cause: Hmm something went wrong making the hamburger.

Additional Context:
	0: Order number 1 failed.
	1: Could not order for user: Bob.

StackTrace:
#0      bail (package:anyhow/src/anyhow/functions.dart:6:14)
#1      makeHamburger (package:anyhow/test/src/temp.dart:31:10)
... <OMITTED FOR EXAMPLE>
```

There is also `StackTraceDisplayFormat` if we want to include none, the main, or all stacktraces in the output.

## Adding Predictable Control Flow To Legacy Dart Code
At times, you may need to integrate with legacy code that may throw or code outside your project. To handle, you 
can just wrap in a helper function like `executeProtected`
```dart
void main() {
  Result<int> result = executeProtected(() => functionWillThrow());
  print(result);
}

int functionWillThrow() {
  throw "this message was thrown";
}
```
Output:
```text
Error: this message was thrown
```
## Dart Equivalent To The Rust "?" Operator
In Dart, the Rust "?" operator functionality in `x?`, where `x` is a `Result`, can be accomplished with
```dart
if (x case Err()) {
  return x.into();
}
```
`into` may be needed to change the `S` type of `Result<S,F>` for `x` to that of the functions return type if 
they are different.
`into` only exits if after the type check, so you will never mishandle a type change since the compiler will stop you.
Note: There also exists
`intoUnchecked` that does not require implicit cast of a `Result` Type. 
## How to Never Unwrap Incorrectly
In Rust, as here, it is possible to unwrap values that should not be unwrapped:
```dart
if (x.isErr()) {
  return x.unwrap(); // this will panic (should be "unwrapErr()")
}
```
To never unwrap incorrectly, simple do a typecheck with `is` or `case` instead of `isErr()`.
```dart
if (x case Err(:final err)){
    return err;
}
```
and vice versa
```dart
if (x case Ok(:final ok){
    return ok;
}
```
The type check does an implicit cast, and we now have access to the immutable error and ok value respectively.

Similarly, we can mimic Rust's `match` keyword, with Dart's `switch`
```dart
switch(x){
 case Ok(:final ok):
   print(ok);
 case Err(:final err):
   print(err);
}

final y = switch(x){
  Ok(:final ok) => ok,
  Err(:final err) => err,
};
```
Or declaratively with match
```dart
x.match((ok) => ok, (err) => err);
```
### Misc
#### Working with Futures
When working with `Future`s it is easy to make a mistake like this
```dart
Future.delayed(Duration(seconds: 1)); // Future not awaited
```
Where the future is not awaited. With Result's (Or any wrapped type) it is possible to make this mistake
```dart
await Ok(1).map((n) async => await Future.delayed(Duration(seconds: n))); // Outer "await" has no effect
```
The outer "await" has no effect since the value's type is `Result<Future<void>>` not `Future<Result<void>>`.
To address this use `toFutureResult()`
```dart
await Ok(1).map((n) async => await Future.delayed(Duration(seconds: n))).toFutureResult(); // Works as expected
```
To avoid these issues all together in regular Dart and with wrapped types like `Result`, it is recommended to enable 
these `Future` linting rules in `analysis_options.yaml`
```yaml
linter:
  rules:
    unawaited_futures: true # Future results in async function bodies must be awaited or marked unawaited using dart:async
    await_only_futures: true # "await" should only be used on Futures
    avoid_void_async: true # Avoid async functions that return void. (they should return Future<void>)
    #discarded_futures: true # Don’t invoke asynchronous functions in non-async blocks.

analyzer:
  errors:
    unawaited_futures: error
    await_only_futures: error
    avoid_void_async: error
    #discarded_futures: error
```
#### Working With Iterable Results
In addition to useful `.toErr()`, `.toOk()` extension methods, anyhow provides a `.toResult()` on types that can be 
converted to a single result. One of these is on `Iterable<Result<S,F>>`, which can turn into a single 
`Result<List<S>,F>`.
If 
using the anyhow `Result`, `Err`'s will be chained, if using the base `Result` The first `Err` if any will be used.
```dart
var result = [Ok(1), Ok(2), Ok(3)].toResult();
expect(result.unwrap(), [1, 2, 3]);

result = [Ok<int,int>(1), Err<int,int>(2), Ok<int,int>(3)].toResult();
expect(result.unwrapErr(), 2);
```
#### Panic
Rust vs Dart Error handling terminology:

| Dart Exception Type | Equivalent in Rust |
|---------------------|--------------------|
| Exception           | Error              |
| Error               | Panic              |

Thus, here `Error` implements Dart core `Exception` (Not to be confused with the 
Dart core `Error` type)
```dart
import 'package:anyhow/anyhow.dart' as anyhow;
import 'package:anyhow/base.dart' as base;

base.Result<String,anyhow.Error> x = anyhow.Err(1); // == base.Err(anyhow.Error(1));
```
And `Panic` implements Dart core `Error`.
```dart
if (x.isErr()) {
  return x.unwrap(); // this will throw a Panic (should be "unwrapErr()")
}
```
As with Dart core `Error`s, `Panic`s should never be caught.

Anyhow was designed with safety in mind. The only time anyhow will ever throw is if you `unwrap` incorrectly (as above),
in 
this case it will throw a `Panic`. See [How to Never Unwrap Incorrectly](#how-to-never-unwrap-incorrectly) section to 
avoid ever using `unwrap`.

#### Null and Unit

In Dart, `void` is used to indicate that a function doesn't return anything or a type should not be used, as such:
```dart
Result<void, void> x = Ok(1); // valid
Result<void, void> y = Err(1); // valid
int z = x.unwrap(); // not valid 
```

Since stricter types are preferred and `Err` cannot be null:
```dart
Result<void, void> x = Ok(null); // valid
Result<void, void> x = Err(null); // not valid
```

Therefore use `()` or `Unit`:

```dart
Unit == ().runtimeType; // true
Result<(), ()> x = Err(unit); // valid
Result<Unit, Unit> y = Err(()); // valid
x == y; // true

// Note:
// const unit = const ();
// const okay = const Ok(unit);
// const error = const Err(unit);
```

#### Infallible

`Infallible` is the error type for errors that can never happen. This can be useful for generic APIs that use Result
and parameterize the error type, to indicate that the result is always Ok.Thus these types expose `intoOk` and
`intoErr`.

```dart

Result<int, Infallible> x = Ok(1);
expect
(
x.intoOk(), 1);
Result<Infallible, int> w = Err(1);
expect(w.intoErr(), 1);
```

```
typedef Infallible = Never;
```
See examples for more.

[Result]: https://doc.rust-lang.org/std/result/enum.Result.html
[anyhow]: https://docs.rs/anyhow/latest/anyhow/
