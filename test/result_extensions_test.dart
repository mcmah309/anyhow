import 'package:anyhow/anyhow.dart';
import 'package:test/test.dart';

void main() {
  test('flatten', () {
    Result<Result<int>> w = Ok(Ok(0));
    expect(w.flatten(), isA<Result<int>>());
    Result<Result<int>> v = Ok(Err(Error(1)));
    expect(v.flatten(), isA<Result<int>>());
  });

  test('transpose', () {
    Result<int?> result = Ok(0);
    Result<int>? transposed = result.transpose();
    expect(transposed!.unwrap(), 0);
    result = Ok(null);
    transposed = result.transpose();
    expect(transposed, null);
    result = bail("");
    transposed = result.transpose();
    expect(transposed!.unwrapErr().downcast<String>().unwrap(), "");
  });
}

class X extends Error {
  X(super.cause);
}

class Y extends X {
  Y(super.cause);
}

class Z {}
