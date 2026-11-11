class _ResolverRequest<T> {
  const _ResolverRequest({
    required this.writerId,
    required this.value,
    required this.priority,
    required this.sequence,
  });

  final int writerId;
  final T value;
  final int priority;
  final int sequence;
}

/// Resolves competing writers by priority, then by request order.
///
/// Each writer has one active request. The highest priority request wins;
/// among requests with the same priority, the most recent request wins. When
/// there are no requests, [value] returns [defaultValue]. Writers are
/// identified by integer IDs, so the resolver does not retain writer objects.
class Resolver<T> {
  Resolver({required this.defaultValue});

  /// The value returned when there are no active requests.
  final T defaultValue;

  final Map<int, _ResolverRequest<T>> _requests = {};
  int _nextSequence = 0;

  /// The currently selected value, or [defaultValue] if there are no requests.
  T get value {
    final request = _winningRequest;
    return request == null ? defaultValue : request.value;
  }

  /// The ID of the writer whose request currently wins, or `null` if none.
  int? get winningWriterId => _winningRequest?.writerId;

  /// The winning request's priority, or `null` if there are no requests.
  int? get winningPriority => _winningRequest?.priority;

  /// Whether any writers currently have active requests.
  bool get hasRequests => _requests.isNotEmpty;

  /// Adds or replaces the request from [writerId].
  ///
  /// A higher [priority] takes precedence. The most recent request wins a
  /// tie, including when a writer updates its own request.
  void request(int writerId, T value, {int priority = 0}) {
    _requests[writerId] = _ResolverRequest<T>(
      writerId: writerId,
      value: value,
      priority: priority,
      sequence: _nextSequence++,
    );
  }

  /// Removes the request from [writerId], returning whether one existed.
  bool release(int writerId) => _requests.remove(writerId) != null;

  /// Removes all active requests.
  void clear() {
    _requests.clear();
  }

  _ResolverRequest<T>? get _winningRequest {
    _ResolverRequest<T>? winner;
    for (final request in _requests.values) {
      if (winner == null ||
          request.priority > winner.priority ||
          (request.priority == winner.priority &&
              request.sequence > winner.sequence)) {
        winner = request;
      }
    }
    return winner;
  }
}