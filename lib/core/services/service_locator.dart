import 'package:get_it/get_it.dart';
import 'package:makanak/core/services/supabase_client_service.dart';
import 'package:makanak/core/services/supabase_database_service.dart';
import 'package:makanak/features/shop/data/repos/products_repo.dart';
import 'package:makanak/features/shop/data/repos/products_repo_impl.dart';
import 'package:makanak/features/shop/presentation/manager/products_cubit/products_cubit.dart';
import 'package:makanak/features/shops/data/repos/shops_repo.dart';
import 'package:makanak/features/shops/data/repos/shops_repo_impl.dart';
import 'package:makanak/features/shops/presentation/manager/shops_cubit/shops_cubit.dart';
import 'package:supabase/supabase.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  if (getIt.isRegistered<SupabaseClient>()) {
    return;
  }

  getIt.registerLazySingleton<SupabaseClient>(
    () => SupabaseClientService.client,
  );

  getIt.registerLazySingleton<SupabaseDatabaseService>(
    () => SupabaseDatabaseService(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<ShopsRepo>(
    () => ShopsRepoImpl(getIt<SupabaseDatabaseService>()),
  );

  getIt.registerLazySingleton<ProductsRepo>(
    () => ProductsRepoImpl(getIt<SupabaseDatabaseService>()),
  );

  getIt.registerFactory<ShopsCubit>(
    () => ShopsCubit(getIt<ShopsRepo>()),
  );

  getIt.registerFactory<ProductsCubit>(
    () => ProductsCubit(getIt<ProductsRepo>()),
  );
}
