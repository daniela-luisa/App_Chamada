class ChamadaModel {
  final int id; 
  final DateTime dateTime;
  final String course;
  final double latitude;
  final double longitude;
  bool _presence;

  String status;
  String presencaTxt; 

  ChamadaModel({
    required this.id,
    required this.dateTime,
    required this.course,
    required this.latitude,
    required this.longitude,
    this.status = "A Iniciar",
    this.presencaTxt = "Aguardando",
    bool presence = false,
  }) : _presence = presence; //atributo privado, incializado e depois "setado" 

  bool get presence => _presence;

  set presence(bool value){
    _presence = value;
  }
}