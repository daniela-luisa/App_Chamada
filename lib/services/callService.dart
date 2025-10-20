import 'package:app_chamada/exception/callException.dart';
import 'package:geolocator/geolocator.dart';
import '../models/chamada_model.dart';

class CallService {
  final List<ChamadaModel> _calls;

  CallService(this._calls);

  List<ChamadaModel> getCallsByCourse(String course) {
    final filtered = _calls.where((c) => c.course == course).toList();
    if (filtered.isEmpty)
      throw CallException('No calls found for the course "$course"');
    return filtered;
  }

  bool setPresence(ChamadaModel call) {
    final now = DateTime.now();
    if (call.dateTime.year != now.year || call.dateTime.month != now.month || call.dateTime.day != now.day) {
      throw CallException('It is not possible to book attendance for another date');
    }
    final difference = now.difference(call.dateTime).inMinutes.abs();
    if (difference > 5) {
      throw CallException( 'Attendance can only be marked within 5 minutes of the call time');
    }
    call.presence = true;
    return true;
  }

  bool verifyPresence(ChamadaModel call, double latitude, double longitude, int meters){ //Melhor aqui ou na classe location ?
    final distance = Geolocator.distanceBetween(call.latitude, call.longitude, latitude, longitude);
    if(distance > meters){
      throw CallException( 'Location greater than "$meters" meters');
    }return true;
  }

}
