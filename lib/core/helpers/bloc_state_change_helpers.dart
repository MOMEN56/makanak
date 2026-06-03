bool didFlagChange<T>({
  required T previous,
  required T current,
  required bool Function(T state) flagOf,
}) {
  return flagOf(previous) != flagOf(current);
}

bool didRefreshFailureIdChange<T>({
  required T previous,
  required T current,
  required Object? Function(T state) refreshFailureOf,
  required int Function(T state) refreshFailureIdOf,
}) {
  final currentRefreshFailure = refreshFailureOf(current);
  if (currentRefreshFailure == null) {
    return false;
  }

  return refreshFailureIdOf(previous) != refreshFailureIdOf(current);
}
