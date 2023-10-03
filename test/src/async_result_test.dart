
import 'package:anyhow/anyhow.dart';
import 'package:test/test.dart';

void main() {
  group('flatMap', () {
    test('async ', () async {
      final result = await const Ok(1) //
          .toAsyncResult()
          .flatMap((ok) async => Ok(ok * 2));
      expect(result.unwrapOrNull(), 2);
    });

    test('sink', () async {
      final result = await const Ok(1) //
          .toAsyncResult()
          .flatMap((ok) => Ok(ok * 2));
      expect(result.unwrapOrNull(), 2);
    });
  });

  group('flatMapError', () {
    test('async ', () async {
      final result = await const Err(1) //
          .toAsyncResult()
          .flatMapError((error) async => Err(error * 2));
      expect(result.unwrapErrOrNull(), 2);
    });

    test('sink', () async {
      final result = await const Err(1) //
          .toAsyncResult()
          .flatMapError((error) => Err(error * 2));
      expect(result.unwrapErrOrNull(), 2);
    });
  });

  test('map', () async {
    final result = await const Ok(1) //
        .toAsyncResult()
        .map((ok) => ok * 2);

    expect(result.unwrapOrNull(), 2);
    expect(const Err(2).toAsyncResult().map((x) => x), completes);
  });

  test('mapError', () async {
    final result = await const Err(1) //
        .toAsyncResult()
        .mapError((error) => error * 2);
    expect(result.unwrapErrOrNull(), 2);
    expect(const Ok(2).toAsyncResult().mapError((x) => x), completes);
  });

  group('swap', () {
    test('Ok to Error', () async {
      final result = const Ok<int, String>(0).toAsyncResult();
      final swap = await result.swap();

      expect(swap.unwrapErrOrNull(), 0);
    });

    test('Error to Ok', () async {
      final result = const Err<String, int>(0).toAsyncResult();
      final swap = await result.swap();

      expect(swap.unwrapOrNull(), 0);
    });
  });

  group('match', () {
    test('Ok', () async {
      final result = const Ok<int, String>(0).toAsyncResult();
      final futureValue = result.match((x) => x, (e) => -1);
      expect(futureValue, completion(0));
    });

    test('Error', () async {
      final result = const Err<String, int>(0).toAsyncResult();
      final futureValue = result.match((x) => x, (e) => e);
      expect(futureValue, completion(0));
    });
  });

  group('unwrapOrNull and unwrapErrOrNull', () {
    test('Ok', () async {
      final result = const Ok<int, String>(0).toAsyncResult();

      expect(result.isOk(), completion(true));
      expect(result.unwrapOrNull(), completion(0));
    });

    test('Error', () async {
      final result = const Err<String, int>(0).toAsyncResult();

      expect(result.isErr(), completion(true));
      expect(result.unwrapErrOrNull(), completion(0));
    });
  });

  group('unwrap', () {
    test('Ok', () {
      final result = const Ok<int, String>(0).toAsyncResult();
      expect(result.unwrap(), completion(0));
    });

    test('Error', () {
      final result = const Err<String, int>(0).toAsyncResult();
      expect(result.unwrap, throwsA(isA<Panic>()));
    });
  });

  group('unwrapOrElse', () {
    test('Ok', () {
      final result = const Ok<int, String>(0).toAsyncResult();
      final value = result.unwrapOrElse((f) => -1);
      expect(value, completion(0));
    });

    test('Error', () {
      final result = const Err<int, int>(0).toAsyncResult();
      final value = result.unwrapOrElse((f) => 2);
      expect(value, completion(2));
    });
  });

  group('unwrapOr', () {
    test('Ok', () {
      final result = const Ok<int, String>(0).toAsyncResult();
      final value = result.unwrapOr(-1);
      expect(value, completion(0));
    });

    test('Error', () {
      final result = const Err<int, int>(0).toAsyncResult();
      final value = result.unwrapOr(2);
      expect(value, completion(2));
    });
  });

  group('inspect', () {
    test('Ok', () {
      const Ok<int, String>(0) //
          .toAsyncResult()
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
      const Err<int, String>('error') //
          .toAsyncResult()
          .inspect((ok) {})
          .inspectErr(
        expectAsync1(
          (value) {
            expect(value, 'error');
          },
        ),
      );
    });
  });
}
