import 'package:makanak/features/app_remote_config/domain/entities/app_access_result.dart';

abstract class AppRemoteConfigRepo {
  Future<AppAccessResult> checkAppAccess();
}
