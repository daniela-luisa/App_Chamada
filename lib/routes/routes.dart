import 'package:flutter/material.dart';
import '../screens/identificacao.dart';
import '../screens/home.dart';
// import '../screens/historico.dart';
// import '../screens/exportar_csv.dart';

Map<String, WidgetBuilder> appRoutes = {
  '/identificacao': (_) => const IdentificacaoPage(),
  '/home': (_) => const HomePage(),
  // '/historico': (_) => const HistoricoPage(),
  // '/csv': (_) => const CsvPage(),
};
