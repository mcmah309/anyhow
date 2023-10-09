# anyhow

[![Pub Version](https://img.shields.io/pub/v/anyhow.svg)](https://pub.dev/packages/anyhow)
[![Dart Package Docs](https://img.shields.io/badge/documentation-pub.dev-blue.svg)](https://pub.dev/documentation/anyhow/latest/)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Taking inspiration from the Rust crate of the same name, "[anyhow]", this Dart package offers versatile and idiomatic 
error handling capabilities.

"anyhow" not only faithfully embodies Rust's standard [Result] monad type but also brings the renowned Rust "anyhow" 
crate into the Dart ecosystem, allowing you to add `context` to `Err`s. You can seamlessly employ both the Standard 
(Base) Result type and the Anyhow Result  type, either in conjunction or independently, to suit your error-handling 
needs.

## Table of Contents

* [What Is a Result Monad Type And Why Use it?](#what-is-a-result-monad-type-and-why-use-it)
* [Intro to Usage](#intro-to-usage)
    - [Regular Dart Error handling](#regular-dart-error-handling)
        - [What's Wrong with Solution?](#whats-wrong-with-solution)
    - [The Better Ways To Handle Errors With Anyhow](#the-better-ways-to-handle-errors-with-anyhow)
        - [Base Result Type Error Handling](#base-result-type-error-handling)
        - [Anyhow Result Type Error Handling](#anyhow-result-type-error-handling)
        - [Base Result Type vs Anyhow Result Type](#base-result-type-vs-anyhow-result-type)
    - [Adding Predictable Control Flow To Legacy Dart Code](#adding-predictable-control-flow-to-legacy-dart-code)
    - [Dart Equivalent To The Rust "?" Operator](#dart-equivalent-to-the-rust--operator)
    - [How to Never Unwrap Incorrectly](#how-to-never-unwrap-incorrectly)
* [Misc](#misc)
    - [Working with Futures](#working-with-futures)
    - [Working With Iterable Results](#working-with-iterable-results)
    - [Panic](#panic)
    - [Unit](#unit)

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
    print(order());
  } catch(e) {
    print(e);
  }
}

String order() {
  final user = "Bob";
  final food = "pizza";
  makeFood(food);
  return "Order Complete";
}

String makeFood(String order) {
  return makeHamburger();
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
  print(order());
}

Result<String,String> order() {
  final user = "Bob";
  final food = "pizza";
  final result = makeFood(food);
  if(result.isOk()){
    return Ok("Order Complete");
  }
  return result;
}

Result<String,String> makeFood(String order) {
  return makeHamburger();
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
  print(order());
}

Result order() {
  final user = "Bob";
  final food = "pizza";
  final result = makeFood(food).context("$user ordered.");
  if(result.isOk()){
    return Ok("Order Complete");
  }
  return result;
}

Result<String> makeFood(String order) {
  return makeHamburger().context("order was $order.");
}

Result<String> makeHamburger() {
  return bail("Hmm something went wrong making the hamburger."); // bail(...) == Err(Error(...))
}
```
#### Output
```text
Error: Bob ordered.

Caused by:
	0: order was pizza.
	1: Hmm something went wrong making the hamburger.
```
and we can include Stack Trace with `Error.hasStackTrace = true`:
```text
Error: Bob ordered.

Caused by:
	0: order was pizza.
	1: Hmm something went wrong making the hamburger.

StackTrace:
#0      new Error (package:anyhow/src/anyhow/anyhow_error.dart:36:48)
#1      AnyhowErrExtensions.context (package:anyhow/src/anyhow/anyhow_extensions.dart:46:15)
#2      AnyhowResultExtensions.context (package:anyhow/src/anyhow/anyhow_extensions.dart:12:29)
... <OMITTED FOR EXAMPLE>
```
or we view the root cause first with `Error.displayFormat = ErrDisplayFormat.stackTrace`
```text
Root Cause: Hmm something went wrong making the hamburger.

Additional Context:
	0: order was pizza.
	1: Bob ordered.

StackTrace:
#0      new Error (package:anyhow/src/anyhow/anyhow_error.dart:36:48)
#1      bail (package:anyhow/src/anyhow/functions.dart:6:14)
#2      makeHamburger (package:anyhow/test/src/temp.dart:31:10)
... <OMITTED FOR EXAMPLE>
```
Before Anyhow, if we wanted to accomplish something similar, we could do
```dart
Result<String,String> order() {
  final user = "Bob";
  final food = "pizza";
  final result = makeFood(food);
  if(result.isErr()){
    Logging.w("$user ordered.");
    return result;
  }
  return Ok("Order Complete");
}

Result<String,String> makeFood(String order) {
  final result = makeHamburger();
  if(result.isErr()){
    Logging.w("order was $order.");
    return result;
  }
  return result;
}

Result<String,String> makeHamburger() {
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

## Adding Predictable Control Flow To Legacy Dart Code
At times, you may need to integrate with legacy code that may throw or code outside your project. To handle, you 
can just wrap in a helper function like `executeProtected`
```dart
void main() {
  Result<int> result = executeProtected(() => functionMayThrow());
  print(result);
}

int functionMayThrow(){
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
`into` only exits if `x` is type `Err`, so you will never mishandle a type change. Note: There also exists 
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
    discarded_futures: true # Don’t invoke asynchronous functions in non-async blocks.

analyzer:
  errors:
    unawaited_futures: error
    await_only_futures: error
    avoid_void_async: error
    discarded_futures: error
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

#### Unit
In Dart, void can be a generic type, but not a return type:
```dart
Result<void,int> x = Ok(null) // not valid
```
To solve this, when you do not care about the return value, use the constant `unit` and type `Unit` over `void`:
```dart
Result<Unit,int> x = Ok(unit) // valid
```


See examples for more.

[Result]: https://doc.rust-lang.org/std/result/enum.Result.html
[anyhow]: https://docs.rs/anyhow/latest/anyhow/
