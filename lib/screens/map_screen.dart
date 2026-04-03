import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/routes_data.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String rotaSelecionada = 'cirio'; // 'cirio', 'trasladacao', 'usuario'
  LatLng? userLocation;
  List<LatLng> rotaUsuario = [];

  @override
  void initState() {
    super.initState();
    _carregarLocalizacao();
  }

  Future<void> _carregarLocalizacao() async {
    final location = await LocationService.getCurrentLocation();
    if (location != null) {
      setState(() {
        userLocation = location;
        // Rota simples do usuário até o ponto inicial (linha reta)
        // Idealmente usar uma API de rotas aqui
        rotaUsuario = [location, pontoInicioCirio];
      });
    }
  }

  List<LatLng> get rotaAtual {
    switch (rotaSelecionada) {
      case 'trasladacao':
        return rotaTrasladacao;
      case 'usuario':
        return rotaUsuario;
      default:
        return rotaCirio;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Círio de Nazaré'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Botões de seleção de rota
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _botaoRota('Círio', 'cirio'),
                _botaoRota('Trasladação', 'trasladacao'),
                _botaoRota('Ir ao início', 'usuario'),
              ],
            ),
          ),

          // Mapa
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: pontoInicioCirio,
                initialZoom: 14,
              ),
              children: [
                // Camada do mapa (OpenStreetMap, gratuito)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.cesupa.cirio_nazare',
                ),

                // Linha da rota
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: rotaAtual,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),

                // Marcadores
                MarkerLayer(
                  markers: [
                    // Ponto inicial fixo
                    Marker(
                      point: pontoInicioCirio,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),

                    // Localização do usuário
                    if (userLocation != null)
                      Marker(
                        point: userLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoRota(String label, String valor) {
    final selecionado = rotaSelecionada == valor;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selecionado ? Colors.blue[800] : Colors.grey[300],
        foregroundColor: selecionado ? Colors.white : Colors.black,
      ),
      onPressed: () => setState(() => rotaSelecionada = valor),
      child: Text(label),
    );
  }
}