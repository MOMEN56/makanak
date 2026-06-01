import 'package:makanak/core/deep_linking/app_deep_link.dart';

class PendingDeepLinkManager {
  AppDeepLink? _pendingLink;

  bool get hasPending => _pendingLink != null;

  void save(AppDeepLink link) {
    if (_pendingLink?.dedupeKey == link.dedupeKey) {
      return;
    }

    _pendingLink = link;
  }

  AppDeepLink? peek() => _pendingLink;

  AppDeepLink? take() {
    final pendingLink = _pendingLink;
    _pendingLink = null;
    return pendingLink;
  }

  void clear() {
    _pendingLink = null;
  }
}
