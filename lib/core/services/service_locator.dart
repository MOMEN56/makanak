import 'package:get_it/get_it.dart';
import 'package:makanak/core/data/data_sources/address_remote_data_source.dart';
import 'package:makanak/core/data/repos/address_repository_impl.dart';
import 'package:makanak/core/domain/repos/address_repository.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_cubit.dart';
import 'package:makanak/core/services/services.dart';
import 'package:makanak/core/services/google_sign_in_service.dart';
import 'package:makanak/core/services/supabase_auth_service.dart';
import 'package:makanak/core/services/supabase_client_service.dart';
import 'package:makanak/features/admin_notifications/data/services/manual_notification_service.dart';
import 'package:makanak/features/admin_notifications/presentation/manager/admin_send_notification_cubit/admin_send_notification_cubit.dart';
import 'package:makanak/features/auth/data/data_sources/profile_remote_data_source.dart';
import 'package:makanak/features/auth/data/repos/auth_repo_impl.dart';
import 'package:makanak/features/auth/domain/repos/auth_repo.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:makanak/features/cart/data/repos/cart_repository_impl.dart';
import 'package:makanak/features/cart/data/services/cart_local_storage.dart';
import 'package:makanak/features/cart/domain/repos/cart_repository.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit_registry.dart';
import 'package:makanak/features/notifications/data/data_sources/push_token_remote_data_source.dart';
import 'package:makanak/features/notifications/data/repos/notifications_repository.dart';
import 'package:makanak/features/notifications/data/repos/notifications_repository_impl.dart';
import 'package:makanak/features/order_history/data/data_sources/orders_remote_data_source.dart';
import 'package:makanak/features/order_history/data/repos/order_history_repository_impl.dart';
import 'package:makanak/features/order_history/domain/repos/order_history_repository.dart';
import 'package:makanak/features/order_history/presentation/manager/order_details_cubit/order_details_cubit.dart';
import 'package:makanak/features/order_history/presentation/manager/order_history_cubit/order_history_cubit.dart';
import 'package:makanak/features/shop/data/data_sources/products_remote_data_source.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
import 'package:makanak/features/shop/data/repos/products_repo_impl.dart';
import 'package:makanak/features/shop/presentation/manager/products_cubit/products_cubit.dart';
import 'package:makanak/features/shops/data/data_sources/shops_remote_data_source.dart';
import 'package:makanak/features/shops/data/repos/shops_repo.dart';
import 'package:makanak/features/shops/data/repos/shops_repo_impl.dart';
import 'package:makanak/features/shops/presentation/manager/shops_cubit/shops_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

bool _isInitialized = false;

void setupServiceLocator() {
  if (_isInitialized) return;
  _isInitialized = true;

  _registerCoreServices();
  _registerShopsFeature();
  _registerProductsFeature();
  _registerAddressFeature();
  _registerOrdersFeature();
  _registerNotificationsFeature();
  _registerAuthFeature();
  _registerCartFeature();
  _registerAdminNotificationsFeature();
}

void _registerCoreServices() {
  getIt.registerLazySingleton<SupabaseClient>(
    () => SupabaseClientService.client,
  );

  getIt.registerLazySingleton<SupabaseAuthService>(
    () => SupabaseAuthService(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<GoogleSignInService>(GoogleSignInService.new);
}

void _registerShopsFeature() {
  getIt.registerLazySingleton<ShopsRemoteDataSource>(
    () => ShopsRemoteDataSource(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<ShopsRepo>(
    () => ShopsRepoImpl(getIt<ShopsRemoteDataSource>()),
  );

  getIt.registerFactory<ShopsCubit>(() => ShopsCubit(getIt<ShopsRepo>()));
}

void _registerProductsFeature() {
  getIt.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSource(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<ProductsRepo>(
    () => ProductsRepoImpl(getIt<ProductsRemoteDataSource>()),
  );

  getIt.registerFactory<ProductsCubit>(
    () => ProductsCubit(getIt<ProductsRepo>()),
  );
}

void _registerAddressFeature() {
  getIt.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSource(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(getIt<AddressRemoteDataSource>()),
  );

  getIt.registerFactory<AddressCubit>(
    () =>
        AddressCubit(getIt<AddressRepository>(), getIt<SupabaseAuthService>()),
  );
}

void _registerOrdersFeature() {
  getIt.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSource(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<OrderHistoryRepository>(
    () => OrderHistoryRepositoryImpl(getIt<OrdersRemoteDataSource>()),
  );

  getIt.registerFactory<OrderHistoryCubit>(
    () => OrderHistoryCubit(getIt<OrderHistoryRepository>()),
  );

  getIt.registerFactory<OrderDetailsCubit>(
    () => OrderDetailsCubit(getIt<OrderHistoryRepository>()),
  );
}

void _registerNotificationsFeature() {
  getIt.registerLazySingleton<PushTokenRemoteDataSource>(
    () => PushTokenRemoteDataSource(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<PushNotificationService>(
    () => PushNotificationService(
      getIt<PushTokenRemoteDataSource>(),
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
}

void _registerAuthFeature() {
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(
      getIt<SupabaseAuthService>(),
      getIt<ProfileRemoteDataSource>(),
      getIt<GoogleSignInService>(),
      getIt<PushNotificationService>(),
    ),
  );

  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepo>()));
}

void _registerCartFeature() {
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(getIt<OrdersRemoteDataSource>()),
  );

  getIt.registerFactoryParam<CartCubit, String, void>(
    (userId, _) => CartCubit(
      getIt<CartRepository>(),
      getIt<ProductsRepo>(),
      userId: userId,
    ),
  );

  getIt.registerLazySingleton<CartCubitRegistry>(
    () => CartCubitRegistry((userId) => getIt<CartCubit>(param1: userId)),
    dispose: (registry) => registry.disposeAll(),
  );
}

void _registerAdminNotificationsFeature() {
  getIt.registerLazySingleton<ManualNotificationService>(
    () => ManualNotificationService(getIt<SupabaseClient>()),
  );

  getIt.registerFactory<AdminSendNotificationCubit>(
    () => AdminSendNotificationCubit(getIt<ManualNotificationService>()),
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
