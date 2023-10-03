import '../anyhow.dart';

/// As with [Error], [Panic] represents a state that should never happen and thus should never be caught.
class Panic extends Error {
  final Result result;
  final String? reason;

  Panic(this.result, [this.reason]);

  @override
  String toString() {
    return 'Panic: ${reason == null ? "" : reason} on an ${result.runtimeType} with value: $result';
  }
}