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
  List<ChamadaModel> chamadas,
  Function atualizarUI,
) async {
  for (int i = 0; i < chamadas.length; i++) {
    await Future.delayed(const Duration(seconds: 2));
    // Começa a rodada
    atualizarUI(i,"Em Andamento","Detectando localização...", presence: chamadas[i].presence,);
    await Future.delayed(const Duration(seconds: 2));

    // Localização inicial
    final posicaoInicial = await LocationService.instance.getCurrentLocation();

    // Salva localização e horário na chamada
    chamadas[i].latitude = posicaoInicial.latitude;
    chamadas[i].longitude = posicaoInicial.longitude;
    chamadas[i].dateTime = DateTime.now();

    final presente = await verificarPresenca(posicaoInicial);

    if (presente) { atualizarUI(i,"Em Andamento","Presente", presence: true,);

      // Simula a janela de tempo (tipo 5 minutos -> aqui 5 segundos)
      await Future.delayed(const Duration(seconds: 5));

      // Só agora encerra a rodada
      atualizarUI(i,"Encerrada", "Presente", presence: true,);
      await Future.delayed(const Duration(seconds: 2));
    } else {
      atualizarUI( i,"Em Andamento","Fora da área, aguardando...", presence: false,);

      // Espera a janela toda
      await Future.delayed(const Duration(seconds: 5));

      // Verifica de novo no final da chamada
      final posicaoFinal =
          await LocationService.instance.getCurrentLocation();
      chamadas[i].latitude = posicaoFinal.latitude;
      chamadas[i].longitude = posicaoFinal.longitude;

      final presenteDepois = await verificarPresenca(posicaoFinal);

      if (presenteDepois) {
        // Entrou na área a tempo
        atualizarUI(i,"Encerrada","Presente (entrou a tempo)",presence: true,);
      } else {
        // Confirmou falta só no final
        atualizarUI(i,"Encerrada","Falta", presence: false,);
      await Future.delayed(const Duration(seconds: 2));

      }
    }
  }

  await salvarResultados(chamadas);
}



Future<void> salvarResultados(List<ChamadaModel> chamadas) async {
  final prefs = await SharedPreferences.getInstance();

  final lista = chamadas
      .map((c) => {
            'id': c.id,
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

  // Ainda salva o "dia atual" pra tela Home (sempre o último ciclo)
  await prefs.setString('chamadas_dia', jsonEncode(lista));
  await prefs.setString('data_chamadas', hojeStr);

  // Carrega histórico acumulado
  final historicoStr = prefs.getString('historico_chamadas');
  List<dynamic> historico =
      historicoStr != null ? jsonDecode(historicoStr) : [];

  // Verifica se esse dia já existe no histórico
  final jaTemDia = historico.any((m) {
    final data = DateTime.parse(m['data'] as String);
    return data.year == hoje.year &&
        data.month == hoje.month &&
        data.day == hoje.day;
  });

  //  Se já tem chamadas desse dia no histórico, nao adiciona de novo (mantém as primeiras)
  if (jaTemDia) {
    return;
  }

  // Se ainda não tem, adiciona esse conjunto de chamadas
  historico.addAll(lista);

  await prefs.setString('historico_chamadas', jsonEncode(historico));
}


Future<List<ChamadaModel>> carregarHistoricoChamadas() async {
  final prefs = await SharedPreferences.getInstance();
  final dados = prefs.getString('historico_chamadas');

  if (dados == null) return [];

  final List<dynamic> jsonList = jsonDecode(dados);

  final chamadas = jsonList
      .map((m) => ChamadaModel(
            id: m['id'],
            dateTime: DateTime.parse(m['data']),
            course: m['curso'],
            latitude: (m['latitude'] as num).toDouble(),
            longitude: (m['longitude'] as num).toDouble(),
            presence: m['presente'],
            status: "Encerrada",
            presencaTxt: m['presente'] ? "Presente" : "Falta",
          ))
      .toList();

  // 🔹 Ordena do mais recente pro mais antigo (opcional mas fica bonito)
  chamadas.sort((a, b) => b.dateTime.compareTo(a.dateTime));

  return chamadas;
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
