import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/features/app_remote_config/domain/entities/app_access_result.dart';
import 'package:makanak/features/app_remote_config/domain/repos/app_remote_config_repo.dart';
import 'package:makanak/features/app_remote_config/presentation/manager/app_remote_config_cubit/app_remote_config_state.dart';

class AppRemoteConfigCubit extends Cubit<AppRemoteConfigState> {
  AppRemoteConfigCubit(this._repo) : super(const AppRemoteConfigInitial());

  final AppRemoteConfigRepo _repo;
  bool _hasChecked = false;

  Future<void> checkAccessOnce() async {
    if (_hasChecked) return;

    _hasChecked = true;
    await _loadAccess();
  }

  Future<void> retry() async {
    await _loadAccess();
  }

  Future<void> _loadAccess() async {
    emit(const AppRemoteConfigLoading());

    try {
      final result = await _repo.checkAppAccess();
      if (isClosed) return;

      emit(AppRemoteConfigResolved(result));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('App remote config check failed. Allowing startup.');
        debugPrint('$error');
        debugPrint('$stackTrace');
      }

      if (isClosed) return;

      emit(const AppRemoteConfigResolved(AppAccessResult.allowed()));
    }
  }
}
