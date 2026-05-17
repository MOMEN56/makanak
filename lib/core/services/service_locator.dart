import 'package:get_it/get_it.dart';
import 'package:makanak/core/data/repos/address_repository_impl.dart';
import 'package:makanak/core/domain/repos/address_repository.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_cubit.dart';
import 'package:makanak/core/services/services.dart';
import 'package:makanak/core/services/google_sign_in_service.dart';
import 'package:makanak/core/services/supabase_auth_service.dart';
import 'package:makanak/core/services/supabase_client_service.dart';
import 'package:makanak/core/services/supabase_database_service.dart';
import 'package:makanak/features/admin_notifications/data/services/manual_notification_service.dart';
import 'package:makanak/features/admin_notifications/presentation/manager/admin_send_notification_cubit/admin_send_notification_cubit.dart';
import 'package:makanak/features/auth/data/repos/auth_repo_impl.dart';
import 'package:makanak/features/auth/domain/repos/auth_repo.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:makanak/features/cart/data/repos/cart_repository_impl.dart';
import 'package:makanak/features/cart/data/services/cart_local_storage.dart';
import 'package:makanak/features/cart/domain/repos/cart_repository.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit_registry.dart';
import 'package:makanak/features/notifications/data/repos/notifications_repository.dart';
import 'package:makanak/features/notifications/data/repos/notifications_repository_impl.dart';
import 'package:makanak/features/order_history/data/repos/order_history_repository_impl.dart';
import 'package:makanak/features/order_history/domain/repos/order_history_repository.dart';
import 'package:makanak/features/order_history/presentation/manager/order_history_cubit/order_history_cubit.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
import 'package:makanak/features/shop/data/repos/products_repo_impl.dart';
import 'package:makanak/features/shop/presentation/manager/products_cubit/products_cubit.dart';
import 'package:makanak/features/shops/data/repos/shops_repo.dart';
import 'package:makanak/features/shops/data/repos/shops_repo_impl.dart';
import 'package:makanak/features/shops/presentation/manager/shops_cubit/shops_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

bool _isInitialized = false;

void setupServiceLocator() {
  if (_isInitialized) return;
  _isInitialized = true;

  getIt.registerLazySingleton<SupabaseClient>(
    () => SupabaseClientService.client,
  );

  getIt.registerLazySingleton<SupabaseDatabaseService>(
    () => SupabaseDatabaseService(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<SupabaseAuthService>(
    () => SupabaseAuthService(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<ManualNotificationService>(
    () => ManualNotificationService(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(
      getIt<SupabaseDatabaseService>(),
      getIt<SupabaseClient>(),
    ),
    dispose: (service) => service.dispose(),
  );

  getIt.registerLazySingleton<NotificationsRepository>(
    () => SupabaseNotificationsRepository(
      getIt<SupabaseClient>(),
      getIt<PushNotificationService>(),
    ),
    dispose: (repository) => repository.dispose(),
  );

  getIt.registerLazySingleton<GoogleSignInService>(GoogleSignInService.new);

  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(
      getIt<SupabaseAuthService>(),
      getIt<SupabaseDatabaseService>(),
      getIt<GoogleSignInService>(),
      getIt<PushNotificationService>(),
    ),
  );

  getIt.registerLazySingleton<ShopsRepo>(
    () => ShopsRepoImpl(getIt<SupabaseDatabaseService>()),
  );

  getIt.registerLazySingleton<ProductsRepo>(
    () => ProductsRepoImpl(getIt<SupabaseDatabaseService>()),
  );

  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(getIt<SupabaseDatabaseService>()),
  );

  getIt.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(getIt<SupabaseDatabaseService>()),
  );

  getIt.registerLazySingleton<OrderHistoryRepository>(
    () => OrderHistoryRepositoryImpl(getIt<SupabaseDatabaseService>()),
  );

  getIt.registerFactory<ShopsCubit>(() => ShopsCubit(getIt<ShopsRepo>()));

  getIt.registerFactory<ProductsCubit>(
    () => ProductsCubit(getIt<ProductsRepo>()),
  );

  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepo>()));

  getIt.registerFactory<AdminSendNotificationCubit>(
    () => AdminSendNotificationCubit(getIt<ManualNotificationService>()),
  );

  getIt.registerFactoryParam<CartCubit, String, void>(
    (userId, _) => CartCubit(getIt<CartRepository>(), userId: userId),
  );

  getIt.registerLazySingleton<CartCubitRegistry>(
    () => CartCubitRegistry((userId) => getIt<CartCubit>(param1: userId)),
    dispose: (registry) => registry.disposeAll(),
  );

  getIt.registerFactory<AddressCubit>(
    () =>
        AddressCubit(getIt<AddressRepository>(), getIt<SupabaseAuthService>()),
  );

  getIt.registerFactory<OrderHistoryCubit>(
    () => OrderHistoryCubit(getIt<OrderHistoryRepository>()),
  );
}

Future<void> resetAuthenticatedSessionState() async {
  await CartLocalStorage.clearLegacyCart();
  await getIt<CartCubitRegistry>().disposeAll();
}

String requireAuthenticatedUserId() {
  final userId = getIt<SupabaseAuthService>().currentSession?.user.id.trim();
  if (userId == null || userId.isEmpty) {
    throw StateError('CartCubit can only be created after sign in.');
  }

  return userId;
}
