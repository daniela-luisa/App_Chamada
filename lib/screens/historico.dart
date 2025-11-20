import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chamada_model.dart';
import '../services/chamadasService.dart';
import '../widgets/bottom_nav.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  String? _usuario;
  List<ChamadaModel> chamadas = [];

  @override
  void initState() {
    super.initState();
    _carregarChamadas();
  }

Future<void> _carregarChamadas() async {
  final service = ChamadaService();
  final lista = await service.carregarHistoricoChamadas();

  final prefs = await SharedPreferences.getInstance();
  _usuario = prefs.getString('usuario');

  setState(() {
    chamadas = lista;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            
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

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: chamadas.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum registro encontrado no histórico.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 10),
                        Text(
                          "Histórico de Presenças",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
            ),

            if (chamadas.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: chamadas.length,
                  itemBuilder: (context, i) {
                    final c = chamadas[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Curso: ${c.course}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Data: ${_formatarData(c.dateTime)}"),
                          Text("Status: ${c.status}"),
                          Text("Presença: ${c.presence ? "Presente" : "Falta"}"),
                          Text(
                            "Localização: "
                            "${c.latitude.toStringAsFixed(5)} | "
                            "${c.longitude.toStringAsFixed(5)}",
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              c.presence ? Icons.check_circle : Icons.cancel,
                              color: c.presence ? Colors.green : Colors.red,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNav(context),
    );
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString().substring(2);
    return "$dia/$mes/$ano";
  }
}
