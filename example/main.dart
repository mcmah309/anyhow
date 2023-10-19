import 'package:anyhow/anyhow.dart';

void main() {
  print(order("Bob", 1));
}

Result<String> order(String user, int orderNumber) {
  final result = makeFood(orderNumber).context("$user ordered.");
  switch (result) {
    case Ok(:final ok):
      return Ok("Order of $ok is complete for $user");
    case Err():
      return result;
  }
}

Result<String> makeFood(int orderNumber) {
  if (orderNumber == 1) {
    return makeHamburger().context("order was $orderNumber.");
  } else {
    return Ok("pasta");
  }
}

Result<String> makeHamburger() {
  return bail("Hmm something went wrong making the hamburger.");
}

//Output:
// Error: Bob ordered.
//
// Caused by:
//  0: order was 1.
//  1: Hmm something went wrong making the hamburger.