**Nama : LILIS THALISA**
**Nim : 362458302020**

 **Deskripsi**
Modul ini membahas integrasi layanan lokasi (GPS) dan peta digital dalam aplikasi Flutter. Mahasiswa akan membuat aplikasi sederhana bernama "Geo-Catatan" yang
 memungkinkan pengguna menandai lokasi pada peta dan menyimpan catatan terkait lokasi tersebut.
 
 **TugasMandiri**
1.KustomisasiMarker:Ubahikonmarkeragarberbeda-bedatergantungjenis catatan(misal:Toko,Rumah,Kantor).
2.HapusData:Tambahkanfituruntukmenghapusmarkeryangsudahdibuat.
3. SimpanData: (Opsional)GunakanSharedPreferencesatauHiveagardata tidakhilangsaataplikasiditutup.
  
**Langkah - Langkah**
  1.Membuat projek flutter dengan menambahkan depedensi 
      dependencies:
      flutter:
        sdk: flutter
      flutter_map: ^6.1.0
      latlong2: ^0.9.0
      shared_preferences: ^2.2.2
      geolocator: ^14.0.2
      geocoding: ^2.0.5
      google_maps_flutter: ^2.14.0
  2. Mengatur ijin akses lokasi
    <user-permissions android:name="android.permissions.ACCESS_FINE_LOCATION" />
    <user-permissions android:name="android.permissions.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />
  3.Membuat catatan model
    import 'package:latlong2/latlong.dart' as latlong;
    
    class CatatanModel {
      final String id;
      final latlong.LatLng position;
      final String note;
      final String address;
      final String type; 
    
      CatatanModel({
        required this.id,
        required this.position,
        required this.note,
        required this.address,
        required this.type,
      });
 4.Membuat Main
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

**Hasil**

![geomobile rumah](https://github.com/user-attachments/assets/a5cb208c-9127-42b1-9b41-192557efa97f)


![geomobile hapus rumah](https://github.com/user-attachments/assets/add23230-df4b-4b25-9e43-8fff953e03f3)
