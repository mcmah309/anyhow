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
    expect(transposed, null );
    result = bail("");
    transposed = result.transpose();
    expect(transposed!.unwrapErr().downcast<String>().unwrap(), "");
  });

  group('toError', () {
    test('without result type', () {
      final result = 'error'.toErr();

      expect(result, isA<Result<dynamic>>());
      expect(result.unwrapErr().downcast<String>().unwrap(), isA<String>());
      expect(result.unwrapErr().downcast<String>().unwrap(), 'error');
    });

    test('with result type', () {
      final Result<int> result = 'error'.toErr();

      expect(result, isA<Result<int>>());
      expect(result.unwrapErr().downcast<String>().unwrap(), isA<String>());
      expect(result.err()!.downcast<String>().unwrap(), 'error');
    });

    test('throw AssertException if is a Result object', () {
      final Result<int> result = 'error'.toErr();
      expect(result.toErr, throwsA(isA<AssertionError>()));
    });

    test('throw AssertException if is a Future object', () {
      expect(Future.value().toErr, throwsA(isA<AssertionError>()));
    });
  });

  group('toOk', () {
    test('without result type', () {
      final result = 'ok'.toOk();

      expect(result, isA<Result<String>>());
      expect(result.unwrapOrNull(), 'ok');
    });

    test('with result type', () {
      final Result<String> result = 'ok'.toOk();

      expect(result, isA<Result<String>>());
      expect(result.unwrapOrNull(), 'ok');
    });

    test('throw AssertException if is a Result object', () {
      final result = 'ok'.toOk();
      expect(result.toOk, throwsA(isA<AssertionError>()));
    });

    test('throw AssertException if is a Future object', () {
      expect(Future.value().toOk, throwsA(isA<AssertionError>()));
    });
  });
}

class x extends Error {
  x(super.cause);
}
class y extends x {
  y(super.cause);
}
class z {}