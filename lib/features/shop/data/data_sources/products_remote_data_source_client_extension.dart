import 'package:makanak/features/shop/data/data_sources/products_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

extension ProductsRemoteDataSourceClientExtension on ProductsRemoteDataSource {
  SupabaseClient get supabaseClient {
    // ignore: invalid_use_of_protected_member
    return client;
  }
}
