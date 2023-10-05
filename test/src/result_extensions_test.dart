import 'package:anyhow/anyhow.dart';
import 'package:anyhow/src/result_extensions.dart';
import 'package:test/test.dart';

void main() {
  test('flatten', () {
    Result<Result<int,x>,y> w = Ok(Ok(0));
    expect(w.flatten(), isA<Result<int,x>>());
    Result<Result<int,y>,x> v = Ok(Ok(0));
    expect(v.flatten(), isA<Result<int,y>>());
  });

  test('transpose', () {
    Result<int?,AnyhowError> result = Ok(0);
    Result<int,AnyhowError>? transposed = result.transpose();
    expect(transposed!.unwrap(), 0);
    result = Ok(null);
    transposed = result.transpose();
    expect(transposed, null );
    result = anyhow("");
    transposed = result.transpose();
    expect(transposed!.unwrapErr().downcast<String>().unwrap(), "");
  });

  group('toError', () {
    test('without result type', () {
      final result = 'error'.toErr();

      expect(result, isA<Result<dynamic, AnyhowError>>());
      expect(result.unwrapErr().downcast<String>().unwrap(), isA<String>());
      expect(result.unwrapErr().downcast<String>().unwrap(), 'error');
    });

    test('with result type', () {
      final Result<int, AnyhowError> result = 'error'.toErr();

      expect(result, isA<Result<int, AnyhowError>>());
      expect(result.unwrapErr().downcast<String>().unwrap(), isA<String>());
      expect(result.unwrapErrOrNull()!.downcast<String>().unwrap(), 'error');
    });

    test('throw AssertException if is a Result object', () {
      final Result<int, AnyhowError> result = 'error'.toErr();
      expect(result.toErr, throwsA(isA<AssertionError>()));
    });

    test('throw AssertException if is a Future object', () {
      expect(Future.value().toErr, throwsA(isA<AssertionError>()));
    });
  });

  group('toOk', () {
    test('without result type', () {
      final result = 'ok'.toOk();

      expect(result, isA<Result<String, dynamic>>());
      expect(result.unwrapOrNull(), 'ok');
    });

    test('with result type', () {
      final Result<String, AnyhowError> result = 'ok'.toOk();

      expect(result, isA<Result<String, AnyhowError>>());
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

class x extends AnyhowError {
  x(super.cause);
}
class y extends x {
  y(super.cause);
}
class z {}
