import 'package:flutter/material.dart';
import 'package:flutter_application_1/enum/selected_routes.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/routes_data.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  final SelectedRoutes rotaInicial;
  const MapScreen({super.key, required this.rotaInicial});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late SelectedRoutes rotaSelecionada;
  SelectedRoutes ultimaRotaPrincipal = SelectedRoutes.cirio;
  LatLng? userLocation;
  List<LatLng> rotaUsuario = [];

  @override
  void initState() {
    super.initState();
    rotaSelecionada = widget.rotaInicial;
    _carregarLocalizacao();
  }

  Future<void> _carregarLocalizacao() async {
    final location = await LocationService.getCurrentLocation();
    if (location != null) {
      setState(() => userLocation = location);
      _atualizarRotaUsuario();
    }
  }

  void _atualizarRotaUsuario() {
    if (userLocation == null) return;

    setState(() {
      if (ultimaRotaPrincipal == SelectedRoutes.cirio) {
        rotaUsuario = [userLocation!, pontoInicioCirio];
      } else {
        rotaUsuario = [userLocation!, pontoInicioTransladacao];
      }
    });
  }

  List<LatLng> get rotaAtual {
    switch (rotaSelecionada) {
      case SelectedRoutes.trasladacao:
        return rotaTrasladacao;
      case SelectedRoutes.user:
        return rotaUsuario;
      default:
        return rotaCirio;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rota - Círio de Nazaré'),
        backgroundColor: const Color.fromARGB(166, 98, 0, 255),
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
                _botaoRota('Círio', SelectedRoutes.cirio),
                _botaoRota('Trasladação', SelectedRoutes.trasladacao),
                _botaoRota('Ir ao início', SelectedRoutes.user),
              ],
            ),
          ),

          // Mapa
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: userLocation ?? pontoInicioCirio,
                initialZoom: 14,
              ),
              children: [
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
                    if (rotaAtual.isNotEmpty)
                      Marker(
                        point: rotaAtual.last,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),

                      if (rotaAtual.isNotEmpty && rotaSelecionada != SelectedRoutes.user)
                      Marker(
                        point: rotaAtual.first,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.church,
                          color: Colors.green,
                          size: 40,
                        ),
                      ),

                      if (rotaAtual.isNotEmpty && rotaSelecionada == SelectedRoutes.user)
                      Marker(
                        point: rotaAtual.first,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.push_pin_outlined,
                          color: Colors.green,
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

  Widget _botaoRota(String label, SelectedRoutes valor) {
    final selecionado = rotaSelecionada == valor;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selecionado
            ? const Color.fromARGB(166, 98, 0, 255)
            : const Color.fromARGB(255, 178, 149, 211),
        foregroundColor: selecionado ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          if (valor != SelectedRoutes.user) {
            ultimaRotaPrincipal = valor; 
          }
          rotaSelecionada = valor;
        });
        _atualizarRotaUsuario();
      },
      child: Text(label),
    );
  }
}