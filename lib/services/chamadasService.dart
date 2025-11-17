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

    if (dadosSalvos != null) {
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
    } else {
      return BancoLocal.getMockCall();
    }
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
              //'data': c.dateTime.toIso8601String(),
              'data': DateTime.now().toIso8601String(),
              'curso': c.course,
              'latitude': c.latitude,
              'longitude': c.longitude,
              'presente': c.presence,
            })
        .toList();

        print(jsonEncode(lista));

    await prefs.setString('chamadas_dia', jsonEncode(lista));
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
