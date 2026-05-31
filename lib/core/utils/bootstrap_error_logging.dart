import 'package:flutter/foundation.dart';

void configureErrorLogging({required String libraryName}) {
  final previousFlutterErrorHandler = FlutterError.onError;
  final previousPlatformErrorHandler = PlatformDispatcher.instance.onError;

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (previousFlutterErrorHandler != null &&
        previousFlutterErrorHandler != FlutterError.presentError) {
      previousFlutterErrorHandler(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: libraryName,
        context: ErrorDescription('while dispatching an uncaught async error'),
      ),
    );

    return previousPlatformErrorHandler?.call(error, stackTrace) ?? false;
  };
}
