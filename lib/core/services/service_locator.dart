import 'package:get_it/get_it.dart';
import 'package:makanak/core/data/data_sources/address_local_data_source.dart';
import 'package:makanak/core/data/data_sources/address_remote_data_source.dart';
import 'package:makanak/core/data/repos/address_repository_impl.dart';
import 'package:makanak/core/deep_linking/deep_link_navigator.dart';
import 'package:makanak/core/deep_linking/deep_link_parser.dart';
import 'package:makanak/core/deep_linking/deep_link_service.dart';
import 'package:makanak/core/deep_linking/pending_deep_link_manager.dart';
import 'package:makanak/core/domain/repos/address_repository.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_cubit.dart';
import 'package:makanak/core/services/google_sign_in_service.dart';
import 'package:makanak/core/services/services.dart';
import 'package:makanak/core/services/supabase_auth_service.dart';
import 'package:makanak/core/services/supabase_client_service.dart';
import 'package:makanak/features/app_remote_config/data/data_sources/app_remote_config_local_data_source.dart';
import 'package:makanak/features/app_remote_config/data/data_sources/app_remote_config_remote_data_source.dart';
import 'package:makanak/features/app_remote_config/data/repos/app_remote_config_repo_impl.dart';
import 'package:makanak/features/app_remote_config/domain/repos/app_remote_config_repo.dart';
import 'package:makanak/features/app_remote_config/presentation/manager/app_remote_config_cubit/app_remote_config_cubit.dart';
import 'package:makanak/features/auth/data/data_sources/profile_remote_data_source.dart';
import 'package:makanak/features/auth/data/repos/auth_repo_impl.dart';
import 'package:makanak/features/auth/domain/repos/auth_repo.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:makanak/features/cart/services/cart_availability_service.dart';
import 'package:makanak/features/cart/data/repos/cart_repository_impl.dart';
import 'package:makanak/features/cart/data/services/cart_local_storage.dart';
import 'package:makanak/features/cart/domain/repos/cart_repository.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit_registry.dart';
import 'package:makanak/features/cart/presentation/manager/checkout_cubit/checkout_cubit.dart';
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
  _registerAppRemoteConfigFeature();
  _registerShopsFeature();
  _registerProductsFeature();
  _registerAddressFeature();
  _registerOrdersFeature();
  _registerNotificationsFeature();
  _registerAuthFeature();
  _registerDeepLinkingFeature();
  _registerCartFeature();
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

void _registerAppRemoteConfigFeature() {
  getIt.registerLazySingleton<AppRemoteConfigRemoteDataSource>(
    () => AppRemoteConfigRemoteDataSource(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<AppRemoteConfigLocalDataSource>(
    AppRemoteConfigLocalDataSource.new,
  );

  getIt.registerLazySingleton<AppRemoteConfigRepo>(
    () => AppRemoteConfigRepoImpl(
      getIt<AppRemoteConfigRemoteDataSource>(),
      getIt<AppRemoteConfigLocalDataSource>(),
    ),
  );

  getIt.registerFactory<AppRemoteConfigCubit>(
    () => AppRemoteConfigCubit(getIt<AppRemoteConfigRepo>()),
  );
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
  getIt.registerLazySingleton<AddressLocalDataSource>(
    AddressLocalDataSource.new,
  );

  getIt.registerLazySingleton<AddressRemoteDataSource>(
    () => AddressRemoteDataSource(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(
      getIt<AddressRemoteDataSource>(),
      getIt<AddressLocalDataSource>(),
      getIt<SupabaseAuthService>(),
    ),
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

void _registerDeepLinkingFeature() {
  getIt.registerLazySingleton<PendingDeepLinkManager>(
    PendingDeepLinkManager.new,
  );

  getIt.registerLazySingleton<DeepLinkParser>(DeepLinkParser.new);

  getIt.registerLazySingleton<DeepLinkNavigator>(
    () => DeepLinkNavigator(
      getIt<SupabaseAuthService>(),
      getIt<ShopsRepo>(),
      getIt<ProductsRepo>(),
      getIt<PendingDeepLinkManager>(),
    ),
  );

  getIt.registerFactory<DeepLinkService>(
    () => DeepLinkService(getIt<DeepLinkParser>(), getIt<DeepLinkNavigator>()),
  );
}

void _registerCartFeature() {
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(getIt<OrdersRemoteDataSource>()),
  );

  getIt.registerLazySingleton<CartAvailabilityService>(
    () => CartAvailabilityService(getIt<ProductsRepo>(), getIt<ShopsRepo>()),
  );

  getIt.registerFactoryParam<CartCubit, String, void>(
    (userId, _) => CartCubit(
      getIt<ProductsRepo>(),
      getIt<CartAvailabilityService>(),
      userId: userId,
    ),
  );

  getIt.registerFactory<CheckoutCubit>(
    () => CheckoutCubit(
      getIt<CartRepository>(),
      getIt<CartAvailabilityService>(),
      getIt<ShopsRepo>(),
    ),
  );

  getIt.registerLazySingleton<CartCubitRegistry>(
    () => CartCubitRegistry((userId) => getIt<CartCubit>(param1: userId)),
    dispose: (registry) => registry.disposeAll(),
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
