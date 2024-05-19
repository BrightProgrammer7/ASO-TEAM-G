import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

import '../apikey/api.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _currentLatitude;
  String? _currentLongitude;


  // Raw coordinates got from  OpenRouteService
  List listOfPoints = [];
  // Conversion of listOfPoints into LatLng(Latitude, Longitude) list of points
  List<LatLng> points = [];
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  // Method to consume the OpenRouteService API
  getCoordinates() async {
    _getCurrentLocation();
    // Requesting for openrouteservice api
    var response = await http.get(getRouteUrl("$_currentLongitude,$_currentLatitude",
        '-8.484377991664413,33.24287081309106'));

    setState(() {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        listOfPoints = data['features'][0]['geometry']['coordinates'];
        points = listOfPoints
            .map((p) => LatLng(p[1].toDouble(), p[0].toDouble()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Cinema'),
        backgroundColor: Colors.black, // Fond noir
        titleTextStyle: TextStyle(
          color: Colors.white, // Couleur du texte blanc
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
            zoom: 15,
            center: LatLng(
            double.parse(_currentLatitude!),
            double.parse(_currentLongitude!),
      ),
        ),
        children: [
          // Layer that adds the map
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
          ),
          // Layer that adds points the map



          // Polylines layer
          PolylineLayer(
            polylineCulling: false,
            polylines: [
              Polyline(
                  points: points, color: Colors.black, strokeWidth: 5),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => getCoordinates(),
        child: const Icon( Icons.route,
          color: Colors.white,
        ),
      ),
    );
  }
  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLatitude = '${position.latitude}';
        _currentLongitude = '${position.longitude}';
      });

      print("LATITUDE : $_currentLatitude");
      print("LONGITUDE : $_currentLongitude");
    } catch (e) {
      print("Erreur: $e");
    }
  }
}