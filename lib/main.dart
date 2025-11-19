import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'catatan_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<CatatanModel> _savedNotes = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // LOAD DATA
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString("catatan_list");

    if (raw != null) {
      List decoded = jsonDecode(raw);
      setState(() {
        _savedNotes.clear();
        _savedNotes.addAll(
          decoded.map((e) => CatatanModel.fromMap(e)).toList(),
        );
      });
    }
  }
  
  // SAVE DATA
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    List<Map<String, dynamic>> raw =
        _savedNotes.map((e) => e.toMap()).toList();

    prefs.setString("catatan_list", jsonEncode(raw));
  }


  // ICON TYPE
  Icon _iconByType(String type) {
    switch (type) {
      case "rumah":
        return const Icon(Icons.home, color: Colors.green, size: 40);

      case "toko":
        return const Icon(Icons.store, color: Colors.blue, size: 40);

      case "kantor":
        return const Icon(Icons.business, color: Colors.orange, size: 40);

      default:
        return const Icon(Icons.location_on, color: Colors.red, size: 40);
    }
  }

  // FIND MY LOCATION
  Future<void> _findMyLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position pos = await Geolocator.getCurrentPosition();

    if (!mounted) return; // FIX async gap error

    _mapController.move(
      latlong.LatLng(pos.latitude, pos.longitude),
      15,
    );
  }

  // ADD MARKER (LONG PRESS)
  void _handleLongPress(TapPosition _, latlong.LatLng point) async {
    List<Placemark> placemarkList =
        await placemarkFromCoordinates(point.latitude, point.longitude);

    String alamat = placemarkList.first.street ?? "Alamat tidak dikenal";

    TextEditingController noteCtrl = TextEditingController();
    String selectedType = "rumah";

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Lokasi"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  hintText: "Catatan...",
                ),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: "rumah", child: Text("Rumah")),
                  DropdownMenuItem(value: "toko", child: Text("Toko")),
                  DropdownMenuItem(value: "kantor", child: Text("Kantor")),
                ],
                onChanged: (v) {
                  setState(() {
                    selectedType = v!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _savedNotes.add(
                    CatatanModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      position: point,
                      note: noteCtrl.text,
                      address: alamat,
                      type: selectedType,
                    ),
                  );
                });
                _saveData();
                Navigator.pop(context);
              },
              child: const Text("Simpan"),
            )
          ],
        );
      },
    );
  }

  // DELETE MARKER
  void _deleteMarker(int index) {
    setState(() {
      _savedNotes.removeAt(index);
    });
    _saveData();
  }

  void _deleteMarkerDialog(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Marker?"),
        content: Text(_savedNotes[index].note),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteMarker(index);
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          )
        ],
      ),
    );
  }

  // =====================
  // BUILD UI
  // =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geo-Catatan")),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const latlong.LatLng(-6.2, 106.8),
          initialZoom: 13,
          onLongPress: _handleLongPress,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          MarkerLayer(
            markers: List.generate(_savedNotes.length, (i) {
              final item = _savedNotes[i];

              return Marker(
                point: item.position,
                width: 50,
                height: 50,
                child: GestureDetector(
                  onTap: () => _deleteMarkerDialog(i),
                  child: _iconByType(item.type),
                ),
              );
            }),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _findMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}