import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:makanak/core/helper/print_helper.dart';
import 'package:makanak/core/utils/bloc/safe_emit_mixin.dart';
import 'package:makanak/features/app_remote_config/domain/entities/app_access_result.dart';
import 'package:makanak/features/app_remote_config/domain/repos/app_remote_config_repo.dart';
import 'package:makanak/features/app_remote_config/presentation/manager/app_remote_config_cubit/app_remote_config_state.dart';

class AppRemoteConfigCubit extends Cubit<AppRemoteConfigState>
    with SafeEmitMixin<AppRemoteConfigState> {
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
      safeEmit(AppRemoteConfigResolved(result));
    } catch (error, stackTrace) {
      PrintHelper.error(
        'App remote config check failed. Allowing startup.',
        error: error,
        stackTrace: stackTrace,
        tag: 'RemoteConfig',
      );

      safeEmit(const AppRemoteConfigResolved(AppAccessResult.allowed()));
    }
  }
}
