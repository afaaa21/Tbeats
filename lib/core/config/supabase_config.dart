import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static String? _url;
  static String? _anonKey;

  static String get supabaseUrl => _url ?? '';
  static String get supabaseAnonKey => _anonKey ?? '';

  static Future<void> initialize() async {
    _url = dotenv.env['SUPABASE_URL'];
    _anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (_url == null || _anonKey == null) {
      throw Exception('Missing Supabase URL or Anon Key in .env file.');
    }

    // Inisialisasi Supabase
    await Supabase.initialize(
      url: _url!,
      anonKey: _anonKey!,
    );
  }

  // Getter untuk memudahkan akses Supabase client di file lain
  static SupabaseClient get client => Supabase.instance.client;
}

