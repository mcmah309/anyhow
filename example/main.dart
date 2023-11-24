import 'package:anyhow/anyhow.dart';

void main() {
  print(order("Bob", 1));
}

Result<String> order(String user, int orderNumber) {
  final result = makeFood(orderNumber).context("Could not order for user: $user.");
  switch (result) {
    // Could also use "if(result.isOk())" and "unwrap()"
    case Ok(:final ok):
      return Ok("Order of $ok is complete for $user");
    case Err():
      return result;
  }
}

Result<String> makeFood(int orderNumber) {
  if (orderNumber == 1) {
    return makeHamburger().context("Order number $orderNumber failed.");
  } else {
    return Ok("pasta");
  }
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