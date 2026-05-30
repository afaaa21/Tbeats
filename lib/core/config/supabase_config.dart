import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    // Mengambil URL dan Key dari file .env
    final String? url = dotenv.env['SUPABASE_URL'];
    final String? anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      throw Exception('Missing Supabase URL or Anon Key in .env file.');
    }

    // Inisialisasi Supabase
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  // Getter untuk memudahkan akses Supabase client di file lain
  static SupabaseClient get client => Supabase.instance.client;
}
