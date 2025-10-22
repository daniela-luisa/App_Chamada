import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chamada_model.dart';
import '../services/chamadasService.dart';
import '../widgets/chamada_card.dart';
import '../widgets/bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _usuario;
  List<ChamadaModel> chamadas = [];
  bool cicloFinalizado = false;
  final service = ChamadaService();

  final horariosFixos = [
    "19:45 - 19:50",
    "20:35 - 20:40",
    "21:25 - 21:30",
    "22:15 - 22:20"
  ];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final prefs = await SharedPreferences.getInstance();
    _usuario = prefs.getString('usuario');
    chamadas = await service.carregarChamadas();

    if (chamadas.any((c) => c.status == "A Iniciar")) {
      service.iniciarChamadas(chamadas, (i, status, presenca, {presence}) {
        setState(() {
          chamadas[i].status = status;
          chamadas[i].presencaTxt = presenca;
          if (presence != null) chamadas[i].presence = presence;
        });
      }).then((_) => setState(() => cicloFinalizado = true));
    } else {
      setState(() => cicloFinalizado = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataHoje = DateTime.now();
    final dataFormatada =
        "${dataHoje.day.toString().padLeft(2, '0')}/${dataHoje.month.toString().padLeft(2, '0')}/${dataHoje.year}";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            //TOPO AZUL 
            Container(
              color: const Color(0xFF4C5BFF),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _usuario ?? 'Carregando...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Chamada',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Automática',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //Cabeçalho “Chamadas” + Data
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chamadas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    dataFormatada,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            //Lista de chamadas
            Expanded(
              child: ListView.builder(
                itemCount: chamadas.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) => ChamadaCard(
                      chamada: chamadas[index],
                       horario: horariosFixos[index],
                      index: index, 
                    ),

              ),
            ),

            // 🔹 Mensagem final
            if (cicloFinalizado)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Chamadas concluídas e salvas com sucesso!',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ),
          ],
        ),
      ),

      // 🔹 Rodapé com botões
      bottomNavigationBar: BottomNav(context),
    );
  }
}
