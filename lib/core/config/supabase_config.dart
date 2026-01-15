import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String _supabaseUrl = 'https://inmhbokqttbvmavwrecw.supabase.co';
  static const String _supabaseAnonKey = 'sb_publishable_qNquc3PSDhi3CGZ931RAkQ_IXIu99F5';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}