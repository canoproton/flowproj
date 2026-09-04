/// ============================================
/// PONTO DE ENTRADA DO APLICATIVO
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'presentation/providers/auth/auth_provider.dart';
import 'presentation/providers/usuarios/usuarios_provider.dart'; // ✅ ADICIONAR

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await SupabaseConfig.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..initialize(),
        ),
        // ✅ ADICIONAR O USUARIOSPROVIDER
        ChangeNotifierProvider(
          create: (context) => UsuariosProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'SocialFlow',
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}