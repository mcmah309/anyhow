import 'package:anyhow/anyhow.dart';

void main() {
  Result err = bail("This is a single error");
  if (err case Ok(:final ok)) {
    print(ok);
  }
  print(err.unwrapErr());
  err = err.context("This is context for the error");
  err = err.context("This is also more context for the error");
  for (final (index, chainedErr) in err.unwrapErr().chain().indexed) {
    print("chain $index: ${chainedErr.downcast<String>().unwrap()}");
  }
  final root = err.unwrapErr().rootCause();
  if (root.isType<String>()) {
    String rootErr = root.downcast<String>().unwrap();
    print("The root error was a String with root value '$rootErr'");
  }
}
// Output:
// Error: This is a single error
//
// chain 0: This is also more context for the error
// chain 1: This is context for the error
// chain 2: This is single error
// The root error was a String with root value 'This is a single error'
