import 'package:flutter/widgets.dart';

class AppRouteTracker {
  AppRouteTracker._();

  static String? currentRouteName;
}

final appRouteObserver = AppRouteObserver();

class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppRouteTracker.currentRouteName = route.settings.name;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppRouteTracker.currentRouteName = previousRoute?.settings.name;
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    AppRouteTracker.currentRouteName = newRoute?.settings.name;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppRouteTracker.currentRouteName = previousRoute?.settings.name;
    super.didRemove(route, previousRoute);
  }
}
