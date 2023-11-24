import 'package:anyhow/base.dart';
import 'package:test/test.dart';

void main() {
  test('flatten', () {
    Result<Result<int, x>, y> w = Ok(Ok(0));
    expect(w.flatten(), isA<Result<int, x>>());
    Result<Result<int, y>, x> v = Ok(Ok(0));
    expect(v.flatten(), isA<Result<int, y>>());
  });

  test('Infallible', () {
    Result<int, Infallible> x = Ok(1);
    expect(x.intoOk(), 1);
    Result<Infallible, int> w = Err(1);
    expect(w.intoErr(), 1);
  });
}

class x extends Object {}
class y extends x {}
class z {}