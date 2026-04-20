import 'dart:convert';

import 'package:makanak/core/utils/app_keys.dart';
import 'package:supabase/supabase.dart';
import 'package:yet_another_json_isolate/yet_another_json_isolate.dart';

abstract final class SupabaseClientService {
  const SupabaseClientService._();

  static final SupabaseClient client = SupabaseClient(
    AppKeys.supabaseUrl,
    AppKeys.supabaseAnonKey,
    isolate: _InlineJsonIsolate(),
  );
}

class _InlineJsonIsolate extends YAJsonIsolate {
  @override
  Future<void> initialize() async {}

  @override
  Future<dynamic> decode(String json) async {
    return jsonDecode(json);
  }

  @override
  Future<String> encode(Object? json) async {
    return jsonEncode(json);
  }

  @override
  Future<void> dispose() async {}
}
