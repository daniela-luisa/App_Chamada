import '../mock/banco_local.dart';
import '../models/aluno_model.dart';
import '../exception/loginException.dart';

class LoginService {

  static Student login(String username, String password) {
    final students = BancoLocal.getMockStudents();

    final user = students.firstWhere((s) => s.username == username && s.password == password,
      orElse: () => throw LoginException('Usuário ou senha incorretos'),
    );

    return user;
  }
}

