
import 'package:anyhow/anyhow.dart';
import 'package:test/test.dart';

void main() {
  group('flatMap', () {
    test('async ', () async {
      final result = await const Ok(1) //
          .toFutureResult()
          .andThen((ok) async => Ok(ok * 2));
      expect(result.unwrapOrNull(), 2);
    });

    test('sink', () async {
      final result = await const Ok(1) //
          .toFutureResult()
          .andThen((ok) => Ok(ok * 2));
      expect(result.unwrapOrNull(), 2);
    });
  });

  group('flatMapError', () {
    test('async ', () async {
      final result = await bail(1) //
          .toFutureResult()
          .andThenErr((error) async => bail(error.downcast<int>().unwrap() * 2));
      expect(result.err()!.downcast<int>().unwrap(), 2);
    });

    test('sink', () async {
      final result = await bail(1) //
          .toFutureResult()
          .andThenErr((error) => bail(error.downcast<int>().unwrap() * 2));
      expect(result.err()!.downcast<int>().unwrap(), 2);
    });
  });

  test('map', () async {
    final result = await const Ok(1) //
        .toFutureResult()
        .map((ok) => ok * 2);

    expect(result.unwrapOrNull(), 2);
    expect(bail(2).toFutureResult().map((x) => x), completes);
  });

  test('mapError', () async {
    final result = await bail(1) //
        .toFutureResult()
        .mapErr((error) => Error(error.downcast<int>().unwrap() * 2));
    expect(result.err()!.downcast<int>().unwrap(), 2);
    expect(const Ok(2).toFutureResult().mapErr((x) => x), completes);
  });

  group('match', () {
    test('Ok', () async {
      final result = const Ok(0).toFutureResult();
      final futureValue = result.match((x) => x, (e) => -1);
      expect(futureValue, completion(0));
    });

    test('Error', () async {
      final result = bail(0).toFutureResult();
      final futureValue = result.match((x) => x, (e) => e.downcast<int>().unwrap());
      expect(futureValue, completion(0));
    });
  });

  group('unwrapOrNull and unwrapErrOrNull', () {
    test('Ok', () async {
      final result = const Ok(0).toFutureResult();

      expect(result.isOk(), completion(true));
      expect(result.unwrapOrNull(), completion(0));
    });

    test('Error', () async {
      final result = bail(0).toFutureResult();

      expect(result.isErr(), completion(true));
      expect(result.unwrapErr().downcast<int>().unwrap(), completion(0));
    });
  });

  group('unwrap', () {
    test('Ok', () {
      final result = const Ok(0).toFutureResult();
      expect(result.unwrap(), completion(0));
    });

    test('Error', () {
      final result = bail(0).toFutureResult();
      expect(result.unwrap, throwsA(isA<Panic>()));
    });
  });

  group('unwrapOrElse', () {
    test('Ok', () {
      final result = const Ok(0).toFutureResult();
      final value = result.unwrapOrElse((f) => -1);
      expect(value, completion(0));
    });

    test('Error', () {
      final result = bail(0).toFutureResult();
      final value = result.unwrapOrElse((f) => 2);
      expect(value, completion(2));
    });
  });

  group('unwrapOr', () {
    test('Ok', () {
      final result = const Ok(0).toFutureResult();
      final value = result.unwrapOr(-1);
      expect(value, completion(0));
    });

    test('Error', () {
      final result = bail(0).toFutureResult();
      final value = result.unwrapOr(2);
      expect(value, completion(2));
    });
  });

  group('inspect', () {
    test('Ok', () {
      const Ok(0) //
          .toFutureResult()
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
      bail('error') //
          .toFutureResult()
          .inspect((ok) {})
          .inspectErr(
        expectAsync1(
          (value) {
            expect(value, Error('error'));
          },
        ),
      );
    });
  });
}
