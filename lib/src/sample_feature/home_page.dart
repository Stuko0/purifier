import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purifier/src/sample_feature/login_page.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  bool isOn = false;
  List<dynamic> notifications = [];
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  late Stream<DatabaseEvent> _dataStreamEvents;
  double co2Ppm = 0.0;
  double coPpm = 0.0;
  double airQuality=0.0;

  @override
  void initState() {
    super.initState();
    loadNotifications();
    _databaseReference.child('data').orderByChild('timestamp').limitToLast(1).onValue.listen((DatabaseEvent event){
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final latestEntry = data.values.first;
      setState(() {
        co2Ppm = latestEntry['co2_ppm'];
        print(co2Ppm);
        coPpm = latestEntry['co_ppm'];
        print(coPpm);
        airQuality=calculateAirQualityPercentage(co2Ppm, coPpm);
        print(airQuality);
      });
    });
    _dataStreamEvents = _databaseReference.child('events').onValue;
    _dataStreamEvents.listen((DatabaseEvent event){
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        isOn = data['event']=='Extractor encendido';
      });
    });
  }

  double calculateAirQualityPercentage(double co2, double co) {
    double totalPpm = co2 + co;
    if (totalPpm >= 5000) {
      return 0.0;
    } else if (totalPpm < 4999) {
      return (100 - ((totalPpm / 4499) * 100)).clamp(0.0, 100.0);
    }
    return 0.0;
  }

  Future<void> loadNotifications() async {
    try {
      final String response =
          await rootBundle.loadString('assets/files/notifications.json');
      final data = jsonDecode(response);
      setState(() {
        notifications = data;
      });
    } catch (e) {
      print("Error al cargar el archivo JSON: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Air Purifier",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const LoginPage();
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Welcome to AirPure",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(
              "From ATL",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.air_rounded,
                      color: airQuality >=61 ? Color(0xffa0d06b) :
                             airQuality >=31 ? Color(0xfff7664a) : Color(0xffec4134),
                      size: screenWidth * 0.15,
                    ),
                    Text(
                      "${airQuality.toStringAsFixed(2)}%",
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    const Text(
                      "Air quality",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.filter_alt_rounded,
                      color: Color(0xfff7e11d),
                      size: screenWidth * 0.15,
                    ),
                    Text(
                      "500",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    Text(
                      "Particles Filtered",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      maxLines: 2,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.ssid_chart_rounded,
                        color: Color(0xffa0d06b), size: screenWidth * 0.15),
                    Text(
                      "10",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    Text(
                      "Today's uses",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                )
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Manual Use",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Center(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          isOn
                              ? Icons.toggle_on_outlined
                              : Icons.toggle_off_outlined,
                          size: screenWidth * 0.17,
                          color: isOn
                              ? Colors.green.shade400
                              : Colors.red.shade400,
                        ),
                        label: Text(
                          isOn ? "Turn On" : "Turn Off",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll<Color>(
                                Colors.white60)),
                        onPressed: () {
                          setState(() {
                            isOn = !isOn;
                            _databaseReference.child('events').update({'event':isOn ? 'Extractor encendido' :  'Extractor apagado'});
                          });
                        },
                      ),
                    )
                  ],
                )),
            Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notifications",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    for (int i = 0; i<notifications.length; i++)...[
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5,
                                spreadRadius: 1
                              )
                            ]
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notifications[i]['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(notifications[i]['description']),
                              const SizedBox(height: 5),
                              Text("Origen: ${notifications[i]['origin']}"),
                              Text(
                                "Inicio: ${notifications[i]['start_time']}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                "Fin: ${notifications[i]['end_time']}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Purificación: ${notifications[i]['purification_percentage']}%",
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      )
                    ]
                  ],
                ))
          ],
        ),
      ),
    ));
  }
}
