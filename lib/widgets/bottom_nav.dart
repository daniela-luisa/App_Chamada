import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final BuildContext context;
  const BottomNav(this.context, {super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: const Color(0xFF4C5BFF),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _botao(Icons.home, "Início", '/home'),
            _botao(Icons.history, "Histórico", '/historico'),
            _botao(Icons.download, "CSV", '/csv'),
          ],
        ),
      ),
    );
  }

  Widget _botao(IconData icon, String label, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
