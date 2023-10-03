import 'package:anyhow/anyhow.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

void main() {

  group('factories', () {
    test('Ok.unit', () {
      final result = Ok.unit();
      expect(result.unwrap(), unit);
    });

    test('Ok.unit Result', () {
      Result<Unit, Exception> fn() {
        return Ok.unit();
      }

      final result = fn();
      expect(result.unwrap(), unit);
    });

    test('Error.unit', () {
      final result = Err.unit();
      expect(result.unwrapErrOrNull(), unit);
    });

    test('Error.unit Result', () {
      Result<String, Unit> fn() {
        return Err.unit();
      }

      final result = fn();
      expect(result.unwrapErr(), unit);
    });
  });

  test('Result.ok', () {
    final result = Result.ok(0);
    expect(result.unwrap(), 0);
  });

  test('Result.error', () {
    final result = Result.err(0);
    expect(result.unwrapErr(), 0);
  });

  test("Result.isOk", () {
    Result result = Result.ok(0);
    late int ok;
    if (result.isOk()) {
      ok = result.unwrap();
    }

    expect(ok, isA<int>());
    expect(result.isErr(), isFalse);
  });

  test("Result.err", () {
    Result result = Result.err(0);
    late int err;
    if (result.isErr()) {
      err = result.unwrapErr();
    }

    expect(err, isA<int>());
    expect(result.isOk(), isFalse);
  });

  test('equatable', () {
    expect(const Ok(1) == const Ok(1), isTrue);
    expect(const Ok(1).hashCode == const Ok(1).hashCode, isTrue);

    expect(const Err(1) == const Err(1), isTrue);
    expect(const Err(1).hashCode == const Err(1).hashCode, isTrue);
  });

  group('Map', () {
    test('Ok', () {
      final result = ok(4);
      final result2 = result.map((ok) => '=' * ok);

      expect(result2.unwrapOrNull(), '====');
    });

    test('Error', () {
      final result = err<String, int>(4);
      final result2 = result.map((ok) => 'change');

      expect(result2.unwrapOrNull(), isNull);
      expect(result2.unwrapErrOrNull(), 4);
    });
  });

  group('MapError', () {
    test('Ok', () {
      const result = Ok<int, int>(4);
      final result2 = result.mapError((error) => '=' * error);

      expect(result2.unwrapOrNull(), 4);
      expect(result2.unwrapErrOrNull(), isNull);
    });

    test('Error', () {
      const result = Err<String, int>(4);
      final result2 = result.mapError((error) => 'change');

      expect(result2.unwrapOrNull(), isNull);
      expect(result2.unwrapErrOrNull(), 'change');
    });
  });

  group('flatMap', () {
    test('Ok', () {
      const result = Ok<int, int>(4);
      final result2 = result.flatMap((ok) => Ok('=' * ok));

      expect(result2.unwrapOrNull(), '====');
    });

    test('Error', () {
      const result = Err<String, int>(4);
      final result2 = result.flatMap(Ok.new);

      expect(result2.unwrapOrNull(), isNull);
      expect(result2.unwrapErrOrNull(), 4);
    });
  });

  group('flatMapError', () {
    test('Error', () {
      const result = Err<int, int>(4);
      final result2 = result.flatMapError((error) => Err('=' * error));

      expect(result2.unwrapErrOrNull(), '====');
    });

    test('Ok', () {
      const result = Ok<int, String>(4);
      final result2 = result.flatMapError(Err.new);

      expect(result2.unwrapOrNull(), 4);
      expect(result2.unwrapErrOrNull(), isNull);
    });
  });

  test('toAsyncResult', () {
    const result = Ok(0);

    expect(result.toAsyncResult(), isA<AsyncResult>());
  });

  group('swap', () {
    test('Ok to Error', () {
      const result = Ok<int, String>(0);
      final swap = result.swap();

      expect(swap.unwrapErrOrNull(), 0);
    });

    test('Error to Ok', () {
      const result = Err<String, int>(0);
      final swap = result.swap();

      expect(swap.unwrapOrNull(), 0);
    });
  });

  group('match', () {
    test('Ok', () {
      const result = Ok<int, String>(0);
      final futureValue = result.match((x) => x, (e) => -1);
      expect(futureValue, 0);
    });

    test('Error', () {
      const result = Err<String, int>(0);
      final futureValue = result.match((ok) => -1, (x) => x);
      expect(futureValue, 0);
    });
  });

  group('unwrap', () {
    test('Ok', () {
      const result = Ok<int, String>(0);
      expect(result.unwrap(), 0);
    });

    test('Error', () {
      const result = Err<String, int>(0);
      expect(result.unwrap, throwsA(isA<Panic>()));
    });
  });

  group('unwrapOr', () {
    test('Ok', () {
      const result = Ok<int, String>(0);
      final value = result.unwrapOr(-1);
      expect(value, 0);
    });

    test('Error', () {
      const result = Err<int, int>(0);
      final value = result.unwrapOr(2);
      expect(value, 2);
    });
  });

  group('unwrapOrElse', () {
    test('Ok', () {
      const result = Ok<int, String>(0);
      final value = result.unwrapOrElse((f) => -1);
      expect(value, 0);
    });

    test('Error', () {
      const result = Err<int, int>(0);
      final value = result.unwrapOrElse((f) => 2);
      expect(value, 2);
    });
  });

  group('unwrapOrNull', () {
    test('Ok', () {
      const result = Ok<int, String>(0);
      final value = result.unwrapOrNull();
      expect(value, 0);
    });

    test('Error', () {
      const result = Err<int, int>(0);
      final value = result.unwrapOrNull();
      expect(value, null);
    });
  });

  group('unwrapErr', () {
    test('Ok', () {
      const result = Ok<int, String>(0);
      expect(result.unwrapErr, throwsA(isA<Panic>()));
    });

    test('Error', () {
      const result = Err<String, int>(0);
      expect(result.unwrapErr(), 0);
    });
  });

  group('unwrapErrOr', () {
    test('Ok', () {
      const result = Ok<int, String>(0);
      final value = result.unwrapErrOr("");
      expect(value, "");
    });

    test('Error', () {
      const result = Err<int, int>(0);
      final value = result.unwrapErrOr(2);
      expect(value, 0);
    });
  });

  group('unwrapErrOrElse', () {
    test('Ok', () {
      const result = Ok<int, String>(0);
      final value = result.unwrapErrOrElse((f) => "");
      expect(value, "");
    });

    test('Error', () {
      const result = Err<int, int>(0);
      final value = result.unwrapErrOrElse((f) => 2);
      expect(value, 0);
    });
  });

  group('unwrapErrOrNull', () {
    test('Ok', () {
      const result = Ok<int, String>(0);
      final value = result.unwrapErrOrNull();
      expect(value, null);
    });

    test('Error', () {
      const result = Err<int, int>(0);
      final value = result.unwrapErrOrNull();
      expect(value, 0);
    });
  });
}
