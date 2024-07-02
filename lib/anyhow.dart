/// Anyhow implementation on top of the 'rust_core' Result type.
library anyhow;

export 'base.dart'
    hide
        guard,
        guardAsync,
        guardAsyncResult,
        guardResult,
        Result,
        Ok,
        Err,
        FutureResult,
        ToOkExtension,
        ToErrExtension;
export 'src/anyhow/anyhow_error.dart';
export 'src/anyhow/execute_protected.dart';
