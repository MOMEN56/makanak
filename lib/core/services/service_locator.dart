import 'package:get_it/get_it.dart';
import 'package:makanak/core/data/repos/address_repository_impl.dart';
import 'package:makanak/core/domain/repos/address_repository.dart';
import 'package:makanak/core/presentation/manager/address_cubit/address_cubit.dart';
import 'package:makanak/core/services/google_sign_in_service.dart';
import 'package:makanak/core/services/supabase_auth_service.dart';
import 'package:makanak/core/services/supabase_client_service.dart';
import 'package:makanak/core/services/supabase_database_service.dart';
import 'package:makanak/features/auth/data/repos/auth_repo_impl.dart';
import 'package:makanak/features/auth/domain/repos/auth_repo.dart';
import 'package:makanak/features/auth/presentation/manager/auth_cubit/auth_cubit.dart';
import 'package:makanak/features/cart/data/repos/cart_repository_impl.dart';
import 'package:makanak/features/cart/domain/repos/cart_repository.dart';
import 'package:makanak/features/cart/presentation/manager/cart_cubit/cart_cubit.dart';
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

  getIt.registerLazySingleton<GoogleSignInService>(GoogleSignInService.new);

  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(
      getIt<SupabaseAuthService>(),
      getIt<SupabaseDatabaseService>(),
      getIt<GoogleSignInService>(),
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

  getIt.registerFactory<ShopsCubit>(() => ShopsCubit(getIt<ShopsRepo>()));

  getIt.registerFactory<ProductsCubit>(
    () => ProductsCubit(getIt<ProductsRepo>()),
  );

  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepo>()));

  getIt.registerLazySingleton<CartCubit>(
    () => CartCubit(getIt<CartRepository>()),
  );

  getIt.registerLazySingleton<AddressCubit>(
    () => AddressCubit(getIt<AddressRepository>()),
  );
}
