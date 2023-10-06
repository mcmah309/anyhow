
import 'package:anyhow/anyhow.dart';

void main(){
  final Result err = bail("This is single error");
  if(err.isOk()){
    print("Ok");
  }
  print(err.unwrapErr());
  err.context("This is context for the error");
  err.context(Exception("This is also context for error"));
  for(final (index, chainedErr) in err.unwrapErr().chain().indexed){
    print("chain $index: $chainedErr");
  }
  if(err.unwrapErr().isType<String>()){
    String rootErr = err.unwrapErr().downcast<String>().unwrap();
    print("The root error was a String with root value '$rootErr'");
  }
}
// Output:
// Error: This is single error
//
// chain 0: This is single error
// chain 1: This is context for the error
// chain 2: Exception: This is also context for error
// The root error was a String with root value 'This is single error'