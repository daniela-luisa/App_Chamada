import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart'; // Para calcular a distância novamente para o CSV

import '../services/chamadasService.dart';
import '../models/chamada_model.dart';
import '../widgets/bottom_nav.dart';

class ExportCsvPage extends StatefulWidget {
  const ExportCsvPage({super.key});

  @override
  State<ExportCsvPage> createState() => _ExportCsvPageState();
}

class _ExportCsvPageState extends State<ExportCsvPage> {
  String? _usuario;
  DateTime dataSelecionada = DateTime.now();
  bool _gerando = false; // Para controlar o loading no botão

  // Coordenadas da Aula (Copiadas do Service para cálculo de distância no relatório)
  static const double LAT_AULA = 37.4219983;
  static const double LNG_AULA = -122.084;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usuario = prefs.getString('usuario') ?? "Aluno Desconhecido";
    });
  }

  Future<void> _selecionarData() async {
    final DateTime? novaData = await showDatePicker(
      context: context,
      initialDate: dataSelecionada,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (novaData != null) {
      setState(() {
        dataSelecionada = novaData;
      });
    }
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year.toString();
    return "$dia/$mes/$ano";
  }

  Future<void> _baixarCSV() async {
    setState(() => _gerando = true);

    try {
      // 1. Carregar dados do Service
      final service = ChamadaService();
      List<ChamadaModel> todasChamadas = await service.carregarChamadas();

      // 2. Filtrar pela data selecionada
      final chamadasDoDia = todasChamadas.where((c) {
        return c.dateTime.year == dataSelecionada.year &&
            c.dateTime.month == dataSelecionada.month &&
            c.dateTime.day == dataSelecionada.day;
      }).toList();

      if (chamadasDoDia.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhum registro encontrado nesta data.')),
        );
        setState(() => _gerando = false);
        return;
      }

      // 3. Montar o cabeçalho do CSV
      // student_id,student_name,date,round,status,latitude,longitude,distance_meters,recorded_at,notes
      String csvContent =
          "student_id,student_name,date,round,status,latitude,longitude,distance_meters,recorded_at,notes\n";

      // 4. Preencher as linhas
      for (var c in chamadasDoDia) {
        // Recalcula distância para preencher o campo distance_meters
        double distanciaMetros = Geolocator.distanceBetween(
          LAT_AULA,
          LNG_AULA,
          c.latitude,
          c.longitude,
        );

        // Tratamento de dados para não quebrar o CSV
        String nomeAluno = _usuario ?? "N/A";
        String dataFormatada = "${dataSelecionada.year}-${dataSelecionada.month.toString().padLeft(2,'0')}-${dataSelecionada.day.toString().padLeft(2,'0')}";
        
        // Mapeando os campos
        // student_id: Usando um ID fixo ou hash, já que o app parece ser single-user local
        // round: Estou usando o nome do curso/aula como "round" ou rodada
        csvContent += 
            "101,$nomeAluno,$dataFormatada,${c.course},${c.presence ? 'Presente' : 'Falta'},${c.latitude},${c.longitude},${distanciaMetros.toStringAsFixed(2)},${c.dateTime.toIso8601String()},Gerado automaticamente\n";
      }

      // 5. Salvar o arquivo temporário
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/relatorio_${dataSelecionada.day}_${dataSelecionada.month}.csv";
      final file = File(path);
      
      await file.writeAsString(csvContent);

      // 6. Compartilhar o arquivo (permite salvar em Arquivos, enviar por email, etc)
      await Share.shareXFiles([XFile(path)], text: 'Relatório de Chamada - ${_formatarData(dataSelecionada)}');

    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao exportar: $e')),
      );
    } finally {
      setState(() => _gerando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Exportar Relatório CSV",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "O arquivo CSV contém os registros de presença automática gerados com base na sua localização.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _selecionarData,
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.red),
                        const SizedBox(width: 6),
                        Text(
                          "Selecionar data: ${_formatarData(dataSelecionada)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _gerando ? null : _baixarCSV, // Desabilita se estiver gerando
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C5BFF),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _gerando 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Text(
                            "Baixar CSV",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(context),
    );
  }
}