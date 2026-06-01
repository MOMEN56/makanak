import 'package:makanak/core/errors/database_exception.dart';
import 'package:makanak/core/errors/failures.dart';
import 'package:makanak/core/utils/app_strings.dart';

abstract final class FailureMapper {
  const FailureMapper._();

  static Failure fromDatabaseException(
    DatabaseException error, {
    required String genericMessage,
    String networkMessage = AppStrings.networkActionError,
  }) {
    if (error.isNetwork) {
      return Failure.network(networkMessage);
    }

    return Failure(genericMessage);
  }
}
