import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desafio/servicos/autenticacao_servico.dart';
import 'package:desafio/servicos/recado_servico.dart';
import 'package:desafio/app/telas/login_tela.dart';
import 'package:desafio/app/telas/cadastro_tela.dart';
import 'package:desafio/app/telas/home_tela.dart';
import 'package:desafio/app/telas/recados_tela.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // Inicializar o database factory para desktop platforms
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AutenticacaoServico()),
        ChangeNotifierProvider(create: (context) => RecadoServico()),
      ],
      child: MaterialApp(
        title: 'Desafio App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const LoginTela(),
          '/cadastro': (context) => const CadastroTela(),
          '/home': (context) => const HomeTela(),
          '/recados': (context) => const RecadosTela(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authService = Provider.of<AutenticacaoServico>(
      context,
      listen: false,
    );

    // Inicializar o serviço de autenticação
    await authService.inicializar();

    // Aguardar um pouco para mostrar a splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Navegar para a tela apropriada
      if (authService.isLogado) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flutter_dash, size: 120, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'Desafio App',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
