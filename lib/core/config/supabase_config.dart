import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String _supabaseUrl = 'https://fnveucrdccqwzovptxqa.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZudmV1Y3JkY2Nxd3pvdnB0eHFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg0MDg1NTgsImV4cCI6MjA4Mzk4NDU1OH0.a6WXbR5wJWeifx6zEyXo1JRG8CEkP30eBu2HnexNTm0';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}