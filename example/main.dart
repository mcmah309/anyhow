import 'package:anyhow/anyhow.dart';

void main() {
  //Error.stackTraceDisplayFormat = StackTraceDisplayFormat.full;
  print(order("Bob", 1));
}

Result<String> order(String user, int orderNumber) {
  final result = makeFood(orderNumber).context("Could not order for user: $user.");
  if (result case Ok(:final ok)) {
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

//Output:
// Error: Could not order for user: Bob.
//
// Caused by:
//    0: Order number 1 failed.
//    1: Hmm something went wrong making the hamburger.
//
// StackTrace:
// #0      AnyhowResultExtensions.context (package:anyhow/src/anyhow/anyhow_extensions.dart:12:29)
// #1      order (package:anyhow/test/src/temp.dart:9:40)
// #2      main (package:anyhow/example/main.dart:5:9)
// ... <OMITTED FOR EXAMPLE>