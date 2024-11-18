/// Anyhow implementation on top of the 'rust_core' Result type.
library anyhow;

export 'src/error.dart';
export 'src/guard.dart';

export 'package:rust/src/result/result.dart' show FutureResultExtension;
export 'package:rust/src/result/record_to_result_extensions.dart';
export 'package:rust/src/result/result_extensions.dart';
