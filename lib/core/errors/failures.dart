import 'package:equatable/equatable.dart';

enum FailureKind { generic, network }

class Failure extends Equatable {
  const Failure(this.message, {this.kind = FailureKind.generic});

  const Failure.network(this.message) : kind = FailureKind.network;

  final String message;
  final FailureKind kind;

  bool get isNetwork => kind == FailureKind.network;

  @override
  List<Object?> get props => [message, kind];
}
