import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importações dos serviços
import 'package:desafio/servicos/usuario_servico.dart';
import 'package:desafio/servicos/contrato_servico.dart';
import 'package:desafio/servicos/clausula_servico.dart';
import 'package:desafio/servicos/capital_social_servico.dart';
import 'package:desafio/servicos/sede_servico.dart';
import 'package:desafio/servicos/administracao_servico.dart';
import 'package:desafio/servicos/pdf_analysis_servico.dart';

// Importações das telas
import 'package:desafio/app/telas/login_tela.dart';
import 'package:desafio/app/telas/home_tela.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioServico()),
        ChangeNotifierProvider(create: (_) => ContratoServico()),
        ChangeNotifierProvider(create: (_) => ClausulaServico()),
        ChangeNotifierProvider(create: (_) => CapitalSocialServico()),
        ChangeNotifierProvider(create: (_) => SedeServico()),
        ChangeNotifierProvider(create: (_) => AdministracaoServico()),
        ChangeNotifierProvider(create: (_) => PdfAnalysisServico()),
      ],
      child: MaterialApp(
        title: 'Nahero App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF2196F3),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: const LoginTela(),
        routes: {
          '/login': (context) => const LoginTela(),
          '/home': (context) => const HomeTela(),
        },
      ),
    );
  }
}