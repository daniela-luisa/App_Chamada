import '../models/aluno_model.dart';
import '../models/chamada_model.dart';

class BancoLocal{

    static List<Student> getMockStudents(){
        return[
        Student(id: 1, username: 'Leonardo', password: '123', course:  'Engenharia de Software'),
        Student(id: 2, username: 'Daniela', password: '456', course:  'Engenharia de Software')
        ];
    }

    static List<ChamadaModel> getMockCall(){
    DateTime DateTimenow = DateTime.now();
    return[
      ChamadaModel(id: 1, dateTime: DateTimenow, course: 'Engenharia de Software', longitude: -122.084, latitude: 37.4219983),
      ChamadaModel(id: 2, dateTime: DateTimenow.add(Duration(minutes: 2)), course: 'Engenharia de Software', longitude: -122.084, latitude: 37.4219983),
      ChamadaModel(id: 3, dateTime: DateTimenow.add(Duration(minutes: 4)), course: 'Engenharia de Software', longitude: -122.084, latitude: 37.4219983),
      ChamadaModel(id: 4, dateTime: DateTimenow.add(Duration(minutes: 6)), course: 'Engenharia de Software', longitude: -122.084, latitude: 37.4219983)
    ];
  }

}


