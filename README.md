# anyhow

[![Pub Version](https://img.shields.io/pub/v/anyhow.svg)](https://pub.dev/packages/anyhow)
[![Dart Package Docs](https://img.shields.io/badge/documentation-pub.dev-blue.svg)](https://pub.dev/documentation/anyhow/latest/)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://github.com/mcmah309/anyhow/actions/workflows/dart.yml/badge.svg)](https://github.com/mcmah309/anyhow/actions)

Anyhow offers versatile and idiomatic error handling capabilities to make your code safer, more maintainable, and
errors easier to debug.

This is accomplished through the use of the [Result] monad type and
an implementation of the popular Rust crate with the same name - [anyhow].
Anyhow will allow you to never throw another exception again and have a predictable control flow. When
errors do arise, you can add `context` to better understand the situation that led to the errors.
See [Anyhow Result Type Error Handling](#anyhow-result-type-error-handling) to jump right into an example.

Anyhow is built on the [rust_core] ecosystem, so it works well with other packages, but also works as a standalone 
package.

## Table of Contents

1. [What Is a Result Monad Type And Why Use it?](#what-is-a-result-monad-type-and-why-use-it)
2. [The Better Way To Handle Errors With Anyhow](#the-better-way-to-handle-errors-with-anyhow)
    - [Example](#example-code)
    - [What Would This Look Like Without Anyhow](#what-would-this-look-like-without-anyhow)
3. [Base Result Type vs Anyhow Result Type](#base-result-type-vs-anyhow-result-type)
4. [Configuration Options](#configuration-options)

## What Is a Result Monad Type And Why Use it?
If you are not familiar with the `Result` type, why it is needed, or it's usages, you can read up on all that here: 
[Result]

## The Better Way To Handle Errors With Anyhow
With the Anyhow `Result` type, we can now add any `Object` as context around errors. To do so, we can use `context` or
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

#### What Would This Look Like Without Anyhow
Before Anyhow, if we wanted to accomplish something similar with [Result], we had to do:

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
4. We have no way to inspect "context", while with anyhow we can iterate through with `chain()`

Now with anyhow, we are able to better understand and handle errors in an idiomatic way.

### Base Result Type vs Anyhow Result Type
The base `Result` type is re-exported from [Result], so this package could be standalone.
But most of the time you should just use the anyhow Result type.

The base `Result` Type and the anyhow `Result` Type can be imported with
```dart
import 'package:anyhow/base.dart' as base;
```
or
```dart
import 'package:anyhow/anyhow.dart' as anyhow;
```
Respectively. Like in anyhow, these types have parity (The Anyhow Result type is just a typedef), thus can be used 
together.
```dart
typedef Result<S> = base.Result<S, anyhow.Error>
```
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

If you don't want to import both libraries like above, and you need use both in the same file, you can just import the 
anyhow one and use the `Base` prefix where necessary.
```dart
import 'package:anyhow/anyhow.dart';

void main(){
  BaseResult<int,String> x = BaseErr("this is an error message");
  BaseResult<int, Error> y = x.mapErr(anyhow); // or just toAnyhowResult()
  Result<int> w = y; // just for explicitness in the example
  assert(w.unwrapErr().downcast<String>().unwrap() == "this is an error message");
}
```

## Configuration Options

Anyhow functionality can be changed by changing:

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


[Result]: https://github.com/mcmah309/rust_core/tree/master/lib/src/result
[anyhow]: https://docs.rs/anyhow/latest/anyhow/
[rust_core]: https://pub.dev/packages/rust_core
