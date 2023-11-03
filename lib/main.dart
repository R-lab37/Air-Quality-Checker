import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String location = 'Loading...';
  String airQuality = 'Unknown';

  @override
  void initState() {
    super.initState();
    getLocationAndAirQuality();
  }

  Future<void> getLocationAndAirQuality() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      setState(() {
        location =
            'Latitude: ${position.latitude.toStringAsFixed(2)}, Longitude: ${position.longitude.toStringAsFixed(2)}';
      });

      String apiKey = 'ENTER_YOUR_API_KEY'; //Simply Log in to openwethermap api
      String apiUrl =
          'http://api.openweathermap.org/data/2.5/air_pollution?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey';

      var response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        int aqi = data['list'][0]['main']['aqi'];
        setState(() {
          airQuality = getAirQualityStatus(aqi);
        });
      } else {
        setState(() {
          airQuality = 'Failed to fetch air quality';
        });
      }
    } catch (e) {
      setState(() {
        airQuality = 'Error: $e';
      });
    }
  }

  String getAirQualityStatus(int aqi) {
    if (aqi == 1) {
      return 'Good';
    } else if (aqi == 2) {
      return 'Fair';
    } else if (aqi == 3) {
      return 'Moderate';
    } else if (aqi == 4) {
      return 'Poor';
    } else if (aqi == 5) {
      return 'Very Poor';
    } else {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Air Quality Checker'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Location: $location',
                style: TextStyle(fontSize: 20),
              ),
              Text(
                'Air Quality: $airQuality',
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
