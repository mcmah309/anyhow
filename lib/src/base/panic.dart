import '../../base.dart';
import 'dart:core' as Core;

/// As with [Error], [Panic] represents a state that should never happen and thus should never be caught.
class Panic extends Core.Error {
  final Result result;
  final Core.String? reason;

  Panic(this.result, [this.reason]);

  @Core.override
  Core.String toString() {
    return 'Panic: ${reason == null ? "" : reason} on an ${result.runtimeType} with value: $result';
  }
}