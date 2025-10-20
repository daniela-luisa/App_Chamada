import 'package:flutter/material.dart';
import 'routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Presença',
      initialRoute: '/identificacao', // primeira tela
      routes: appRoutes,              // usa o mapa acima
    );
  }
}


// import 'package:app_chamada/services/callService.dart';
// import 'mock/banco_local.dart';
// import 'services/services.dart';

// void main() async {
//   //Testando classes inciais
//   try {
//     final students = BancoLocal.getMockStudents();
//     final calls = BancoLocal.getMockCall();

//     // Login
//     final user = LoginService.login('Leonardo', '123');

//     // Inicializa service de chamadas 
//     final callService = CallService(calls);

//     // Carregar chamadas do curso 
//     final userCalls = callService.getCallsByCourse(user.course);

//     // Pega cordenada atual
//     final position = await LocationService.instance.getCurrentLocation();

//     // Verifica se esta entre 100 metros do local da chamada
//     callService.verifyPresence(userCalls.first, position.latitude, position.longitude, 100);

//     // Marca presença 
//     callService.setPresence(userCalls.first);

//     print('Presença marcada para chamada ID: ${userCalls.first.id}');
//   } catch (e) {
//     print('Erro: $e');
//   }
// }
