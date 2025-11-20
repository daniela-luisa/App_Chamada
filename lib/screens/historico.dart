import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chamada_model.dart';
import '../services/chamadasService.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/header_chamada.dart';

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
    final lista = await service.carregarHistoricoChamadas(); // usa o histórico geral

    final prefs = await SharedPreferences.getInstance();
    _usuario = prefs.getString('usuario');

    setState(() {
      chamadas = lista;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Agrupa as chamadas por dia (yyyy-mm-dd)
    final Map<String, List<ChamadaModel>> agrupadoPorDia = {};
    for (var c in chamadas) {
      final key ="${c.dateTime.year.toString().padLeft(4, '0')}-${c.dateTime.month.toString().padLeft(2, '0')}-${c.dateTime.day.toString().padLeft(2, '0')}";
      agrupadoPorDia.putIfAbsent(key, () => []).add(c);
    }

    // Transforma em lista e ordena do dia mais recente pro mais antigo
    final diasOrdenados = agrupadoPorDia.entries.toList()
      ..sort((a, b) => b.value.first.dateTime.compareTo(a.value.first.dateTime));

    return Scaffold(
  backgroundColor: Colors.white,
  body: SafeArea(
    child: Column(
      children: [
        // TOPO AZUL (agora como widget)
        HeaderChamada(usuario: _usuario),

        // Título / Mensagem
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: chamadas.isEmpty ? const Center(
                      child: Text('Nenhum registro encontrado no histórico.', style: TextStyle(fontSize: 16),
                      ),
                    )
                  : const Align(
                      alignment: Alignment.center,
                      child: Text("Histórico de Presenças", style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),

            if (chamadas.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: diasOrdenados.length,
                  itemBuilder: (context, index) {
                    final entry = diasOrdenados[index];
                    final chamadasDoDia = entry.value;

                    // Pega curso e data do primeiro registro desse dia
                    final primeira = chamadasDoDia.first;
                    final data = primeira.dateTime;
                    final curso = primeira.course;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCE2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        title: Text("Curso: $curso", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold) ),
                        subtitle: Text("Data: ${_formatarData(data)}", style: const TextStyle(fontSize: 14) ),
                        children: [
                          const SizedBox(height: 4),
                          for (int i = 0; i < chamadasDoDia.length; i++)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Esquerda: nº da chamada + localização
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("${i + 1}ª Chamada", style: const TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text("Localização: "
                                          "${chamadasDoDia[i].latitude.toStringAsFixed(5)} | "
                                          "${chamadasDoDia[i].longitude.toStringAsFixed(5)}",
                                          style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),

                                  // Direita: texto + ícone de presença
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(chamadasDoDia[i].presence ? "Presente" : "Falta",
                                        style: TextStyle(
                                          color: chamadasDoDia[i].presence
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(chamadasDoDia[i].presence ? Icons.check_circle : Icons.cancel,
                                        color: chamadasDoDia[i].presence
                                            ? Colors.green
                                            : Colors.red,
                                        size: 22,
                                      ),
                                    ],
                                  ),
                                ],
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
