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
      Result<Unit, AnyhowError> fn() {
        return Ok.unit();
      }

      final result = fn();
      expect(result.unwrap(), unit);
    });
  });

  test('Result.ok', () {
    final result = Result.ok(0);
    expect(result.unwrap(), 0);
  });

  test('Result.error', () {
    final result = anyhow(0);
    expect(result.unwrapErr().downcast<int>().unwrap(), 0);
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
    Anyhow<dynamic> result = anyhow(0);
    late int err;
    if (result.isErr()) {
      err = result.unwrapErr().downcast<int>().unwrap();
    }

    expect(err, isA<int>());
    expect(result.isOk(), isFalse);
  });

  test('equatable', () {
    expect(const Ok(1) == const Ok(1), isTrue);
    expect(const Ok(1).hashCode == const Ok(1).hashCode, isTrue);

    expect(anyhow(1) == anyhow(1), isTrue);
    expect(anyhow(1).hashCode == anyhow(1).hashCode, isTrue);
  });

  group('Map', () {
    test('Ok', () {
      final result = Ok(4);
      final result2 = result.map((ok) => '=' * ok);

      expect(result2.unwrapOrNull(), '====');
    });

    test('Error', () {
      final result = Err<String, AnyhowError>(AnyhowError(4));
      final result2 = result.map((ok) => 'change');

      expect(result2.unwrapOrNull(), isNull);
      expect(result2.unwrapErrOrNull()?.downcast<int>().unwrap(), 4);
    });
  });

  group('MapError', () {
    test('Ok', () {
      const result = Ok<int, AnyhowError>(4);
      final result2 = result.mapErr((error) => AnyhowError('=' * error.downcast<int>().unwrap()));

      expect(result2.unwrapOrNull(), 4);
      expect(result2.unwrapErrOrNull(), isNull);
    });

    test('Error', () {
      final result = 4.toErr();
      final result2 = result.mapErr((error) => AError('change'));

      expect(result2.unwrapOrNull(), isNull);
      expect(result2.unwrapErrOrNull(), AError('change'));
    });
  });

  group('flatMap', () {
    test('Ok', () {
      final result = 4.toOk();
      final result2 = result.flatMap((ok) => Ok('=' * ok));

      expect(result2.unwrapOrNull(), '====');
    });

    test('Error', () {
      final result = 4.toErr();
      final result2 = result.flatMap(Ok.new);

      expect(result2.unwrapOrNull(), isNull);
      expect(result2.unwrapErrOrNull(), AError(4));
    });
  });

  group('flatMapError', () {
    test('Error', () {
      final result = 4.toErr();
      final result2 = result.flatMapErr((error) => ('=' * error.downcast<int>().unwrap()).toErr());

      expect(result2.unwrapErrOrNull(), AError('===='));
    });

    test('Ok', () {
      const result = Ok(4);
      final result2 = result.flatMapErr(Err.new);

      expect(result2.unwrapOrNull(), 4);
      expect(result2.unwrapErrOrNull(), isNull);
    });
  });

  test('toAsyncResult', () {
    const result = Ok(0);

    expect(result.toFutureResult(), isA<FutureResult>());
  });

  group('match', () {
    test('Ok', () {
      const result = Ok(0);
      final futureValue = result.match((x) => x, (e) => -1);
      expect(futureValue, 0);
    });

    test('Error', () {
      final result = 0.toErr();
      final futureValue = result.match((ok) => -1, (x) => x);
      expect(futureValue, AError(0));
    });
  });

  group('unwrap', () {
    test('Ok', () {
      const result = Ok(0);
      expect(result.unwrap(), 0);
    });

    test('Error', () {
      final result = 0.toErr();
      expect(result.unwrap, throwsA(isA<Panic>()));
    });
  });

  group('unwrapOr', () {
    test('Ok', () {
      final result = Ok(0);
      final value = result.unwrapOr(-1);
      expect(value, 0);
    });

    test('Error', () {
      final result = Err.anyhow(0);
      final value = result.unwrapOr(2);
      expect(value, 2);
    });
  });

  group('unwrapOrElse', () {
    test('Ok', () {
      final result = Ok(0);
      final value = result.unwrapOrElse((f) => -1);
      expect(value, 0);
    });

    test('Error', () {
      final result = Err.anyhow(0);
      final value = result.unwrapOrElse((f) => 2);
      expect(value, 2);
    });
  });

  group('unwrapOrNull', () {
    test('Ok', () {
      const result = Ok<int, AnyhowError>(0);
      final value = result.unwrapOrNull();
      expect(value, 0);
    });

    test('Error', () {
      final result = Err.anyhow(0);
      final value = result.unwrapOrNull();
      expect(value, null);
    });
  });

  group('unwrapErr', () {
    test('Ok', () {
      const result = Ok(0);
      expect(result.unwrapErr, throwsA(isA<Panic>()));
    });

    test('Error', () {
      final result = anyhow(0);
      expect(result.unwrapErr(), AError(0));
    });
  });

  group('unwrapErrOr', () {
    test('Ok', () {
      final result = Ok(0);
      final value = result.unwrapErrOr(AError(""));
      expect(value, AError(""));
    });

    test('Error', () {
      final result = Err.anyhow(0);
      final value = result.unwrapErrOr(AError(""));
      expect(value, AError(0));
    });
  });

  group('inspect', () {
    test('Ok', () {
      const Ok(0)
          .inspectErr((error) {})
          .inspect(
        expectAsync1(
              (value) {
            expect(value, 0);
          },
        ),
      );
    });

    test('Error', () {
      Err.anyhow('error')
          .inspect((ok) {})
          .inspectErr(
        expectAsync1(
              (value) {
            expect(value, AError('error'));
          },
        ),
      );
    });
  });

  group('unwrapErrOrElse', () {
    test('Ok', () {
      const result = Ok(0);
      final value = result.unwrapErrOrElse((f) => AError(""));
      expect(value, AError(""));
    });

    test('Error', () {
      final result = Err.anyhow(0);
      final value = result.unwrapErrOrElse((f) => AError(2));
      expect(value, AError(0));
    });
  });

  group('unwrapErrOrNull', () {
    test('Ok', () {
      const result = Ok(0);
      final value = result.unwrapErrOrNull();
      expect(value, null);
    });

    test('Error', () {
      final result = Err<int, AnyhowError>(AError(0));
      final value = result.unwrapErrOrNull();
      expect(value, AError(0));
    });
  });

  test('printing error', () {
    Result error = anyhow(Exception("Root cause"));
    AnyhowError.displayFormat = ErrDisplayFormat.traditionalAnyhow;
    expect(error.toString(), 'Error: Exception: Root cause\n');
    AnyhowError.displayFormat = ErrDisplayFormat.stackTrace;
    expect(error.toString(), 'Root Cause: Exception: Root cause\n');
    error = order();
    AnyhowError.displayFormat = ErrDisplayFormat.traditionalAnyhow;
    //print(error.toString());
    expect(error.toString(), """
Error: Bob ordered.

Caused by:
	0: order was pizza.
	1: Hmm something went wrong making the hamburger.
""");
    AnyhowError.displayFormat = ErrDisplayFormat.stackTrace;
    // print(error.toString());
    expect(error.toString(), """
Root Cause: Hmm something went wrong making the hamburger.

Additional Context:
	0: order was pizza.
	1: Bob ordered.
""");
  });

  test('printing error with stacktrace', () {
    AnyhowError.hasStackTrace = true;
    AnyhowError.stackTraceDisplayFormat = StackTraceDisplayFormat.none;
    Result error = anyhow(Exception("Root cause"));
    AnyhowError.displayFormat = ErrDisplayFormat.traditionalAnyhow;
    expect(error.toString(), 'Error: Exception: Root cause\n');
    AnyhowError.displayFormat = ErrDisplayFormat.stackTrace;
    expect(error.toString(), 'Root Cause: Exception: Root cause\n');
    error = order();
    AnyhowError.displayFormat = ErrDisplayFormat.traditionalAnyhow;
    //print(error.toString());
    expect(error.toString(), """
Error: Bob ordered.

Caused by:
	0: order was pizza.
	1: Hmm something went wrong making the hamburger.
""");
    AnyhowError.displayFormat = ErrDisplayFormat.stackTrace;
    // print(error.toString());
    expect(error.toString(), """
Root Cause: Hmm something went wrong making the hamburger.

Additional Context:
	0: order was pizza.
	1: Bob ordered.
""");


    AnyhowError.stackTraceDisplayFormat = StackTraceDisplayFormat.one;
    error = anyhow(Exception("Root cause"));
    AnyhowError.displayFormat = ErrDisplayFormat.traditionalAnyhow;
    expect(error.toString(), startsWith("""
Error: Exception: Root cause

StackTrace:
"""));
    AnyhowError.displayFormat = ErrDisplayFormat.stackTrace;
    expect(error.toString(), startsWith("""
Root Cause: Exception: Root cause

StackTrace:
"""));
    error = order();
    AnyhowError.displayFormat = ErrDisplayFormat.traditionalAnyhow;
    //print(error.toString());
    expect(error.toString(), startsWith("""
Error: Bob ordered.

Caused by:
	0: order was pizza.
	1: Hmm something went wrong making the hamburger.

StackTrace:
"""));
    AnyhowError.displayFormat = ErrDisplayFormat.stackTrace;
    // print(error.toString());
    expect(error.toString(), startsWith("""
Root Cause: Hmm something went wrong making the hamburger.

Additional Context:
	0: order was pizza.
	1: Bob ordered.

StackTrace:
"""));


  AnyhowError.stackTraceDisplayFormat = StackTraceDisplayFormat.full;
  error = anyhow(Exception("Root cause"));
  AnyhowError.displayFormat = ErrDisplayFormat.traditionalAnyhow;
  expect(error.toString(), startsWith("""
Error: Exception: Root cause

Main StackTrace:
"""));
  expect(error.toString(), isNot(contains("Additional StackTraces")));
  AnyhowError.displayFormat = ErrDisplayFormat.stackTrace;
  expect(error.toString(), startsWith("""
Root Cause: Exception: Root cause

Main StackTrace:
"""));
  expect(error.toString(), isNot(contains("Additional StackTraces")));
  error = order();
  AnyhowError.displayFormat = ErrDisplayFormat.traditionalAnyhow;
  //print(error.toString());
  expect(error.toString(), startsWith("""
Error: Bob ordered.

Caused by:
	0: order was pizza.
	1: Hmm something went wrong making the hamburger.

Main StackTrace:
"""));
    expect(error.toString(), contains("Additional StackTraces"));
  AnyhowError.displayFormat = ErrDisplayFormat.stackTrace;
  // print(error.toString());
  expect(error.toString(), startsWith("""
Root Cause: Hmm something went wrong making the hamburger.

Additional Context:
	0: order was pizza.
	1: Bob ordered.

Main StackTrace:
"""));
  expect(error.toString(), contains("Additional StackTraces"));
});
}

Result order() {
  final user = "Bob";
  final food = "pizza";
  return makeFood(food).context("$user ordered.");
}

Result makeFood(String order) {
  return makeHamburger().context("order was $order.");
}

Result makeHamburger() {
  return anyhow("Hmm something went wrong making the hamburger.");
}
