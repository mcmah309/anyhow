# anyhow

[![Pub Version](https://img.shields.io/pub/v/anyhow.svg)](https://pub.dev/packages/anyhow)
[![Dart Package Docs](https://img.shields.io/badge/documentation-pub.dev-blue.svg)](https://pub.dev/documentation/anyhow/latest/)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://github.com/mcmah309/anyhow/actions/workflows/dart.yml/badge.svg)](https://github.com/mcmah309/anyhow/actions)

`anyhow` offers versatile and idiomatic error handling capabilities to make your code safer, more maintainable, and
errors easier to debug.

This is accomplished through the use of the `Result` monad type and
an implementation of the popular Rust crate with the same name - [anyhow].
`anyhow` will allow you to never throw another exception again and have a predictable control flow. When
errors do arise, you can add `context` to better understand the situation that led to the errors.
See [here](#the-better-way-to-handle-errors-with-anyhow) to jump right into an example.

## What Is a Result Monad Type And Why Use it?
If you are not familiar with the `Result` type, why it is needed, or it's usages, you can read up on all that here: 
[article](https://mcmah309.github.io/#/blog/the_result_type_in_dart)

## The Better Way To Handle Errors With Anyhow
Before `anyhow`, with a regular `Result` type, we had no way to know the context around `Err`s. `anyhow` fixes this and 
more!
With the `anyhow` `Result` type, we can now add any `Object` as context around errors. To do so, we can use `context` or
`withContext` (lazily). Either will only have an effect if a `Result` is the `Err` subclass. In the following
example we will use `String`s as the context, but using `Exception`s, especially for the root cause is common practice
as well.
```dart
import 'package:anyhow/anyhow.dart';

void main() {
  print(order("Bob", 1));
}

Result<String> order(String user, int orderNumber) {
  final result = makeFood(orderNumber).context("Could not order for user: $user.");
  if(result case Ok(:final ok)) {
    return Ok("Order of $ok is complete for $user");
  }
  return result;
}

Result<String> makeFood(int orderNumber) {
  if (orderNumber == 1) {
    return makeHamburger().context("Order number $orderNumber failed.");
  }
  return Ok("pasta");
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
	
StackTrace:
#0      AnyhowResultExtensions.context (package:anyhow/src/anyhow/anyhow_extensions.dart:12:29)
#1      order (package:anyhow/test/src/temp.dart:9:40)
#2      main (package:anyhow/example/main.dart:5:9)
... <OMITTED FOR EXAMPLE>
```
Now we know keep a record of exactly what was happening at each level in the call stack!

#### What Would This Look Like Without Anyhow
Before `anyhow`, if we wanted to accomplish something similar with `Result`, we had to do:

```dart
void main() {
  print(order("Bob", 1));
}

Result<String, String> order(String user, int orderNumber) {
  final result = makeFood(orderNumber);
  if(result case Ok(:final ok)) {
    return Ok("Order of $ok is complete for $user");
  }
  Logging.w("Could not order for user: $user.");
  return result;
}

Result<String, String> makeFood(int orderNumber) {
  if (orderNumber == 1) {
    final result = makeHamburger();
    if (result.isErr()) {
      Logging.w("Order number $orderNumber failed.");
    }
    return result;
  }
  return Ok("pasta");
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
4. We have no way to inspect "context", while with `anyhow` we can iterate through with `chain()`

Now with `anyhow`, we are able to better understand and handle errors in an idiomatic way!

## Configuration Options

`anyhow` functionality can be changed by changing:

```text
Error.hasStackTrace;
Error.displayFormat;
Error.stackTraceDisplayFormat;
Error.stackTraceDisplayModifier;
```

Which is usually done at startup.

* `hasStackTrace`: With `Error.hasStackTrace = false`, we can exclude capturing a stack trace:

```text
Error: Could not order for user: Bob.

Caused by:
	0: Order number 1 failed.
	1: Hmm something went wrong making the hamburger.
```

* `displayFormat`: We can view the root cause first with `Error.displayFormat = ErrDisplayFormat.rootCauseFirst`

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

* `stackTraceDisplayFormat`: if we want to include `none`, the `main`, or `all` stacktraces in the output.


* `stackTraceDisplayModifier`: Modifies the stacktrace during display. Useful for adjusting
  number of frames to include during display/logging.

## Anyhow Result Type vs Rust Result Type
The `Result` type for this package is just a typedef of the `Result` type in the [rust] package -
```dart
import 'package:rust/rust.dart' as rust;

typedef Result<S> = rust.Result<S, Error>
```
Thus they can be used together -
```dart
import 'package:anyhow/anyhow.dart' as anyhow;
import 'package:rust/rust.dart';

void main(){
  Result<int,anyhow.Error> x = Ok(1);
  anyhow.Result<int> y = Ok(1); // or
  Ok(1).context(1);
}
```
or
```dart
import 'package:anyhow/anyhow.dart';
import 'package:rust/rust.dart' hide Result;

void main(){
  Result<int> x = Ok(1);
  Ok(1).context(1);
}
```

## Downcasting
Downcasting is the process of getting the inner error from an an anyhow `Error`.
```dart
import 'package:anyhow/anyhow.dart';

void main(){
  Result<int> x = bail("this is an error message");
  Error error = x.unwrapErr();
  assert(error.downcast<String>().unwrap() == "this is an error message");
  assert(error.downcastUnchecked() == "this is an error message"); // or
}
```
This may be useful when you want to inspect the root error type.
```dart
import 'package:anyhow/anyhow.dart';

void main(){
  Result<int> x = bail("this is an error message").context(1);
  final rootInner = x.unwrapErr().rootCause().downcastUnchecked();
  switch(rootInner) {
    case String():
      print("String found");
    default:
      print("Default reached");
  }
}
```
Since anyhow makes the trade off that you do not care about the underlying causes inner type,
which allows your api's to be more composable and concise, 
downcasting is expected to be used sparingly.

[anyhow]: https://docs.rs/anyhow/latest/anyhow/
[rust]: https://pub.dev/packages/rust_core
