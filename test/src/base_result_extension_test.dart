import 'package:anyhow/base.dart';
import 'package:test/test.dart';

void main() {
  test('flatten', () {
    Result<Result<int, X>, Y> w = Ok(Ok(0));
    expect(w.flatten(), isA<Result<int, X>>());
    Result<Result<int, Y>, X> v = Ok(Ok(0));
    expect(v.flatten(), isA<Result<int, Y>>());
  });

  test('Infallible', () {
    Result<int, Infallible> x = Ok(1);
    expect(x.intoOk(), 1);
    Result<Infallible, int> w = Err(1);
    expect(w.intoErr(), 1);
  });
}

class X extends Object {}

class Y extends X {}

class Z {}
