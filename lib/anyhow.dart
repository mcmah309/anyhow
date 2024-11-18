/// Anyhow implementation on top of the 'rust_core' Result type.
library anyhow;

export 'src/anyhow/anyhow_error.dart';

export 'package:rust/src/result/result.dart' show Ok, Err;
export 'package:rust/src/result/guard.dart';
export 'package:rust/src/result/record_to_result_extensions.dart';
export 'package:rust/src/result/result_extensions.dart';
