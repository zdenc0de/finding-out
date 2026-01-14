import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String _supabaseUrl = 'https://fnveucrdccqwzovptxqa.supabase.co';
  static const String _supabaseAnonKey = 'sb_publishable_OH5BFsmIYfz1JeP-8tyg2Q_h4AilslW';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}