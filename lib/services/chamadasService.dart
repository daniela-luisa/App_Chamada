import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../models/chamada_model.dart';
import '../mock/banco_local.dart';
import 'locationService.dart';

class ChamadaService {
  Future<List<ChamadaModel>> carregarChamadas() async {
    final prefs = await SharedPreferences.getInstance();
    final dadosSalvos = prefs.getString('chamadas_dia');
    final dataSalva = prefs.getString('data_chamadas');

    // Data "de hoje" apenas com ano-mês-dia
    final hoje = DateTime.now();
    final hojeStr =
        "${hoje.year.toString().padLeft(4, '0')}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";

    // 🔹 Se temos dados salvos E a data é de hoje → reaproveita as chamadas
    if (dadosSalvos != null && dataSalva == hojeStr) {
      final List<dynamic> json = jsonDecode(dadosSalvos);
      return json
          .map((m) => ChamadaModel(
                id: m['id'],
                dateTime: DateTime.parse(m['data']),
                course: m['curso'],
                latitude: m['latitude'],
                longitude: m['longitude'],
                presence: m['presente'],
                status: "Encerrada",
                presencaTxt: m['presente'] ? "Presente" : "Falta",
              ))
          .toList();
    }

    // 🔹 Se NÃO temos dados ou a data é diferente → é um novo dia
    // limpa o que tinha e gera novas chamadas
    await prefs.remove('chamadas_dia');
    await prefs.remove('data_chamadas');

    final chamadas = BancoLocal.getMockCall();

    // Garante estado inicial para o novo dia
    for (var c in chamadas) {
      c.status = "A Iniciar";
      c.presence = false;
      c.presencaTxt = "";
    }

    return chamadas;
  }


  Future<void> iniciarChamadas(
      List<ChamadaModel> chamadas, Function atualizarUI) async {
    for (int i = 0; i < chamadas.length; i++) {
      atualizarUI(i, "Em Andamento", "Detectando Localização");

      await Future.delayed(const Duration(seconds: 2));
      final posicao = await LocationService.instance.getCurrentLocation();
      final presente = await verificarPresenca(posicao);

      atualizarUI(i, "Encerrada", presente ? "Presente" : "Falta",
          presence: presente);

      await Future.delayed(const Duration(seconds: 5));
    }

    await salvarResultados(chamadas);
  }

  Future<void> salvarResultados(List<ChamadaModel> chamadas) async {
    final prefs = await SharedPreferences.getInstance();

    final lista = chamadas
        .map((c) => {
              'id': c.id,
              // Mantém a data da chamada (agendada) em vez de sobrescrever com o "agora"
              'data': c.dateTime.toIso8601String(),
              'curso': c.course,
              'latitude': c.latitude,
              'longitude': c.longitude,
              'presente': c.presence,
            })
        .toList();

    // Data de referência do ciclo (apenas ano-mês-dia)
    final hoje = DateTime.now();
    final hojeStr =
        "${hoje.year.toString().padLeft(4, '0')}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";

    print(jsonEncode(lista));

    await prefs.setString('chamadas_dia', jsonEncode(lista));
    await prefs.setString('data_chamadas', hojeStr);
  }




  Future<bool> verificarPresenca(Position posicao) async {
    const double LAT_AULA = 37.4219983;
    const double LNG_AULA = -122.084;
    const double DISTANCIA_MAX = 100;

    final distancia = Geolocator.distanceBetween(
      LAT_AULA,
      LNG_AULA,
      posicao.latitude,
      posicao.longitude,
    );

    return distancia <= DISTANCIA_MAX;
  }
}
