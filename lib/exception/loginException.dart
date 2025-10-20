class LoginException implements Exception { //Classe de exception para login 
  final String message;

  LoginException(this.message);

  @override
  String toString() => 'LoginException: $message';
}