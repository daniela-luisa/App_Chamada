import 'package:flutter/material.dart';
import '../../models/chamada_model.dart';

class ChamadaCard extends StatelessWidget {
  final ChamadaModel chamada;
  final String horario;
   final int index;

  const ChamadaCard({super.key, required this.chamada, required this.horario, required this.index,});

  String _statusPresenca() {
    if (chamada.status == "A Iniciar") return "Aguardando";
    if (chamada.status == "Em Andamento" && !chamada.presence) {
      return "Detectando Localização";
    }
    if (chamada.status == "Encerrada") {
      return chamada.presence ? "Presente" : "Falta";
    }
    return "";
  }

  Color _corStatus() {
    switch (chamada.status) {
      case "Em Andamento":
        return Colors.orange;
      case "Encerrada":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 187, 203, 255),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${index + 1}ª Chamada',
             style: const TextStyle(
             fontSize: 20,
             fontWeight: FontWeight.w600,
            ),
          ),
              Text(
                chamada.status,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _corStatus(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _statusPresenca(),
            style: TextStyle(
              color: chamada.presence
                  ? Colors.green
                  : (chamada.status == "Encerrada"
                      ? Colors.red
                      : Colors.black54),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              horario,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
