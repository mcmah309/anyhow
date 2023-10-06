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

Result<int> makeFood(String order) {
  return makeHamburger().context("order was $order.");
}

Result<int> makeHamburger() {
  if(true) {
    return bail("Hmm something went wrong making the hamburger.");
  }
  return Ok(0);
}

// Output:
// Error: Bob ordered.
//
// Caused by:
// 0: order was pizza.
// 1: Hmm something went wrong making the hamburger.