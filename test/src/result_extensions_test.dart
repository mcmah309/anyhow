import 'package:anyhow/anyhow.dart';
import 'package:anyhow/src/result_extensions.dart';
import 'package:test/test.dart';

void main() {
  test('flatten', () {
    AResult<AResult<int,x>,y> w = Ok(Ok(0));
    expect(w.flatten(), isA<AResult<int,x>>());
    AResult<AResult<int,y>,x> v = Ok(Ok(0));
    expect(v.flatten(), isA<AResult<int,y>>());
  });

  test('transpose', () {
    AResult<int?,Error> result = Ok(0);
    AResult<int,Error>? transposed = result.transpose();
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

      expect(result, isA<AResult<dynamic, Error>>());
      expect(result.unwrapErr().downcast<String>().unwrap(), isA<String>());
      expect(result.unwrapErr().downcast<String>().unwrap(), 'error');
    });

    test('with result type', () {
      final AResult<int, Error> result = 'error'.toErr();

      expect(result, isA<AResult<int, Error>>());
      expect(result.unwrapErr().downcast<String>().unwrap(), isA<String>());
      expect(result.unwrapErrOrNull()!.downcast<String>().unwrap(), 'error');
    });

    test('throw AssertException if is a Result object', () {
      final AResult<int, Error> result = 'error'.toErr();
      expect(result.toErr, throwsA(isA<AssertionError>()));
    });

    test('throw AssertException if is a Future object', () {
      expect(Future.value().toErr, throwsA(isA<AssertionError>()));
    });
  });

  group('toOk', () {
    test('without result type', () {
      final result = 'ok'.toOk();

      expect(result, isA<AResult<String, dynamic>>());
      expect(result.unwrapOrNull(), 'ok');
    });

    test('with result type', () {
      final AResult<String, Error> result = 'ok'.toOk();

      expect(result, isA<AResult<String, Error>>());
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
