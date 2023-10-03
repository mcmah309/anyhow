import 'package:anyhow/anyhow.dart';
import 'package:anyhow/src/result_extensions.dart';
import 'package:test/test.dart';

void main() {
  test('flatten', () {
    Result<Result<int,x>,y> w = Ok(Ok(0));
    expect(w.flatten(), isA<Result<int,x>>());
    Result<Result<int,y>,x> v = Ok(Ok(0));
    expect(v.flatten(), isA<Result<int,y>>());
    Result<Result<int,z>,x> q = Ok(Ok(0));
    expect(q.flatten(), isA<Result<int,Object>>());
  });

  test('transpose', () {
    Result<int?,String> result = Ok(0);
    Result<int,String>? transposed = result.transpose();
    expect(transposed!.unwrap(), 0);
    result = Ok(null);
    transposed = result.transpose();
    expect(transposed, null );
    result = Err("");
    transposed = result.transpose();
    expect(transposed!.unwrapErr(), "");
  });

  group('toError', () {
    test('without result type', () {
      final result = 'error'.toErr();

      expect(result, isA<Result<dynamic, String>>());
      expect(result.unwrapErrOrNull(), isA<String>());
      expect(result.unwrapErrOrNull(), 'error');
    });

    test('with result type', () {
      final Result<int, String> result = 'error'.toErr();

      expect(result, isA<Result<int, String>>());
      expect(result.unwrapErrOrNull(), isA<String>());
      expect(result.unwrapErrOrNull(), 'error');
    });

    test('throw AssertException if is a Result object', () {
      final Result<int, String> result = 'error'.toErr();
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
      final Result<String, int> result = 'ok'.toOk();

      expect(result, isA<Result<String, int>>());
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

class x extends Object {}
class y extends x {}
class z {}
