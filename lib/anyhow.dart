// Anyhow implementation on top of Base
library anyhow;

export 'base.dart'
    hide
        executeProtected,
        executeProtectedAsync,
        executeProtectedAsyncResult,
        executeProtectedResult,
        Result,
        Ok,
        Err,
        FutureResult,
        ToOkExtension,
        ToErrExtension;
export 'src/anyhow/anyhow_error.dart';
export 'src/anyhow/execute_protected.dart';
