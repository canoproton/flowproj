import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    
    // Opções adicionais (opcional)
    // Supabase.instance.client.options = const SupabaseClientOptions(
    //   auth: AuthOptions(
    //     autoRefreshToken: true,
    //     persistSession: true,
    //     detectSessionInUrl: true,
    //   ),
    // );
  }

  static SupabaseClient get client => _client;
}