import 'package:anyhow/anyhow.dart';

void main() {
  Result err = bail("This is a single error");
  if (err case Ok(:final okay)) {
    print(okay);
  }
  print(err.unwrapErr());
  err = err.context("This is context for the error");
  err = err.context("This is also more context for the error");
  for (final (index, chainedErr) in err.unwrapErr().chain().indexed) {
    print("chain $index: ${chainedErr.downcast<String>().unwrap()}");
  }
  var rootError = err.unwrapErr().rootCause();
  if (rootError.isType<String>()) {
    String rootErr = rootError.downcast<String>().unwrap();
    print("The root error was a String with root value '$rootErr'");
  }
  Result<int> x = bail("this is an error message").context(1).into();
  var rootInner = x.unwrapErr().rootCause().downcastUnchecked();
  switch (rootInner) {
    case String():
      print("String found");
    default:
      print("Default reached");
  }
}
// Output:
// This is a single error
//
// chain 0: This is also more context for the error
// chain 1: This is context for the error
// chain 2: This is single error
// The root error was a String with root value 'This is a single error'
// String found
