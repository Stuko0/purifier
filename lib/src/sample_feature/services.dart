import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  Future<List<Map<String, dynamic>>> getEventsWithData() async {
    DatabaseEvent eventsSnapshot = await _databaseReference.child('events').orderByChild('timestamp').once();
    if (eventsSnapshot.snapshot.value != null) {
      final eventsData = eventsSnapshot.snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> eventsWithData = [];

      for (var eventKey in eventsData.keys) {
        var event = eventsData[eventKey];
        DatabaseEvent dataSnapshot = await _databaseReference.child('data')
            .orderByChild('timestamp')
            .equalTo(event['timestamp'])
            .once();

        if (dataSnapshot.snapshot.value != null) {
          final data = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
          var dataEntry = data.values.first; // Asumiendo que solo hay un documento con el timestamp coincidente
          print(eventsWithData);
          eventsWithData.add({
            'event': event['event'],
            'timestamp': event['timestamp'],
            'origin': event['origin'],
            'co2_ppm': dataEntry['co2_ppm'],
            'co_ppm': dataEntry['co_ppm'],
          });
        }
      }

      // Ordenar los resultados por timestamp
      eventsWithData.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

      return eventsWithData;
    } else {
      return [];
    }
  }
}
