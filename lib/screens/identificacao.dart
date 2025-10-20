import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mock/banco_local.dart';
import '../services/locationService.dart';


class IdentificacaoPage extends StatefulWidget {
  const IdentificacaoPage({super.key});

  @override
  State<IdentificacaoPage> createState() => _IdentificacaoPageState();
}

class _IdentificacaoPageState extends State<IdentificacaoPage> {
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  String? _erro;

  @override
  void initState() {
    super.initState();
    _verificarUsuarioSalvo();
  }

  Future<void> _verificarUsuarioSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioSalvo = prefs.getString('usuario');
    if (usuarioSalvo != null && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _fazerLogin() async {
    final alunos = BancoLocal.getMockStudents();

    final alunoValido = alunos.any(
      (a) =>
          a.username == _usuarioController.text.trim() &&
          a.password == _senhaController.text.trim(),
    );

    if (!alunoValido) {
      setState(() => _erro = 'Usuário ou senha incorretos.');
      return;
    }

    // Obtém o aluno correto
    final aluno = alunos.firstWhere(
      (a) =>
          a.username == _usuarioController.text.trim() &&
          a.password == _senhaController.text.trim(),
    );

    // Solicita permissão de localização
    await LocationService.instance.getCurrentLocation();

    // Salva o login localmente
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario', aluno.username);
    await prefs.setString('curso', aluno.course);

    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 225, 224, 255),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Chamada',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Automática',
                        style: TextStyle(fontSize: 18, color: Color.fromARGB(221, 0, 0, 0)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  'Bem-vindo',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'O aplicativo usa sua localização para registrar presença automaticamente durante as aulas.',
                  style: TextStyle(color: Color.fromARGB(137, 0, 0, 0), fontSize: 14),
                ),
                const SizedBox(height: 30),

                TextField(
                controller: _usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Usuário',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de senha
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
                const SizedBox(height: 25),

                if (_erro != null) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      _erro!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                ],
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _fazerLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 80, 95, 255),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Permitir Localização e Continuar',
                      style: TextStyle( color:Color.fromARGB(255, 255, 255, 255),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Seus dados e localização são usados apenas para registrar presença nessa aula.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color:Color.fromARGB(137, 0, 0, 0), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
