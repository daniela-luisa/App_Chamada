//rotas 

import 'package:flutter/material.dart';
import '../screens/identificacao.dart';
import '../screens/home.dart';

Map<String, WidgetBuilder> appRoutes = {
  '/identificacao': (_) => const IdentificacaoPage(),
  '/home': (_) => const HomePage(),
};


// import 'package:flutter/material.dart';
// import '../screens/exportar_csv.dart';
// import '../screens/home.dart';

// final Map<String, WidgetBuilder> routes = {
//   '/': (context) => HomeScreen(),
//   '/exportar': (context) => ExportarCsvScreen(),
// };
