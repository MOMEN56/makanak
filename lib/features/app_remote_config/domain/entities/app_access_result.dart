import 'package:equatable/equatable.dart';

enum AppAccessStatus { allowed, forceUpdate, maintenance }

class AppAccessResult extends Equatable {
  const AppAccessResult({required this.status, this.message, this.updateUrl});

  const AppAccessResult.allowed()
    : status = AppAccessStatus.allowed,
      message = null,
      updateUrl = null;

  final AppAccessStatus status;
  final String? message;
  final String? updateUrl;

  @override
  List<Object?> get props => [status, message, updateUrl];
}
