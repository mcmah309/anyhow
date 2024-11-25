/// Anyhow implementation on top of the 'rust_core' Result type.
library anyhow;

export 'src/error.dart';
export 'src/guard.dart';

export 'package:rust/src/result/result.dart'
    hide
        Result,
        Ok,
        Err,
        FutureResult,
        guard,
        guardAsync,
        guardAsyncResult,
        guardResult;
