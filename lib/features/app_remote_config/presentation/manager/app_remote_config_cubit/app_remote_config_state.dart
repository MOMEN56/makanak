import 'package:equatable/equatable.dart';
import 'package:makanak/features/app_remote_config/domain/entities/app_access_result.dart';

sealed class AppRemoteConfigState extends Equatable {
  const AppRemoteConfigState();

  @override
  List<Object?> get props => [];
}

class AppRemoteConfigInitial extends AppRemoteConfigState {
  const AppRemoteConfigInitial();
}

class AppRemoteConfigLoading extends AppRemoteConfigState {
  const AppRemoteConfigLoading();
}

class AppRemoteConfigResolved extends AppRemoteConfigState {
  const AppRemoteConfigResolved(this.result);

  final AppAccessResult result;

  @override
  List<Object?> get props => [result];
}
