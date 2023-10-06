# anyhow

[![Pub Version](https://img.shields.io/pub/v/anyhow.svg)](https://pub.dev/packages/anyhow)
[![Dart Package Docs](https://img.shields.io/badge/documentation-pub.dev-blue.svg)](https://pub.dev/documentation/anyhow/latest/)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

Taking inspiration from the Rust crate of the same name, "[anyhow]", this Dart package offers versatile and idiomatic 
error handling capabilities.

"anyhow" not only faithfully embodies Rust's standard [Result] monad type but also brings the renowned Rust "anyhow" 
crate into the Dart ecosystem. You can seamlessly employ both the Result type and the Anyhow Result type, either in 
conjunction or independently, to suit your error-handling needs.

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
## The Better Ways To Handle Errors With Anyhow
#### What Is a Result Monad Type And Why Use it?
A monad is just a wrapper around an object that provides a standard way of interacting with the inner object. The 
`Result` monad is used in place of throwing exceptions. Instead of a function throwing an exception, the function 
returns a `Result`, which can either be a `Ok` (Success) or `Err` (Error/Failure), `Result` is the type union 
between the two. Before using the inner object, you need to check the type of the `Result` through `isOk()` or 
`isErr()`, or you can directly `unwrap()` if you know an error is impossible. Doing so allows you to 
either resolve any potential issues in the calling function or pass the error up the chain until a function resolves 
the issue. This provides predictable control flow to your program, eliminating many potential bugs and countless 
hours of debugging.

### Result Type Error Handling
With the base `Result` type, there is no more undefined behaviour due to control flow.
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
With the Anyhow `Result` type, we now can know and add context around errors. To do so, we can add `context` or 
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
  return bail("Hmm something went wrong making the hamburger.");
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
and we can swap the order with `Error.displayFormat = ErrDisplayFormat.stackTrace`
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
In Dart, the Rust "?" operator in `x?`, where `x` is a `Result`, can be mimicked with
```dart
if (x.isErr()) {
  return x.as();
}
```
"as" may be needed to change the `Ok` type of `x` to that of the calling function if they are different. 

See examples for more.

[Result]: https://doc.rust-lang.org/std/result/enum.Result.html
[anyhow]: https://docs.rs/anyhow/latest/anyhow/
