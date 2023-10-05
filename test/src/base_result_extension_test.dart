import 'package:anyhow/base.dart';
import 'package:test/test.dart';

void main() {
  test('flatten', () {
    Result<Result<int, x>, y> w = Ok(Ok(0));
    expect(w.flatten(), isA<Result<int, x>>());
    Result<Result<int, y>, x> v = Ok(Ok(0));
    expect(v.flatten(), isA<Result<int, y>>());
  });
}

class x extends Object {}
class y extends x {}
class z {}