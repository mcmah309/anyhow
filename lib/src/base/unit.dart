import '../../base.dart';

/// Type alias for (). Used for a [Result] when the returned value does not matter. Preferred over void since
/// forces stricter types. See [unit], [okay], and [error]
typedef Unit = ();

const unit = const ();
const okay = const Ok(unit);
const error = const Err(unit);
