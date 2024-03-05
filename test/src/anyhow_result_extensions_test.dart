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
    Result<int>? transposed = result.transposeOut();
    expect(transposed!.unwrap(), 0);
    result = Ok(null);
    transposed = result.transposeOut();
    expect(transposed, null);
    result = bail("");
    transposed = result.transposeOut();
    expect(transposed!.unwrapErr().downcast<String>().unwrap(), "");
  });

  group('toErr', () {
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
      expect(result.unwrapErr().downcast<String>().unwrap(), 'error');
    });

    test('already an Error', () {
      final Result<int> result = Error('error').toErr();

      expect(result, isA<Result<int>>());
      expect(result.unwrapErr().downcast<String>().unwrap(), isA<String>());
      expect(result.unwrapErr().downcast<String>().unwrap(), 'error');
    });

    test('throw AssertException if is a Result object', () {
      final Result<int> result = 'error'.toErr();
      expect(result.toErr, throwsA(isA<AssertionError>()));
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
  });
}

class X extends Error {
  X(super.cause);
}

class Y extends X {
  Y(super.cause);
}

class Z {}
