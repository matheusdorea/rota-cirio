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

    if (widget.rotaInicial != SelectedRoutes.user) {
    ultimaRotaPrincipal = widget.rotaInicial;
    }

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
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.blue[200],
        currentIndex: rotaSelecionada == SelectedRoutes.cirio
            ? 0
            : rotaSelecionada == SelectedRoutes.trasladacao
                ? 1
                : 2,
        onTap: (index) {
          final rotas = [
            SelectedRoutes.cirio,
            SelectedRoutes.trasladacao,
            SelectedRoutes.user,
          ];
          setState(() {
            if (rotas[index] != SelectedRoutes.user) {
              ultimaRotaPrincipal = rotas[index];
            }
            rotaSelecionada = rotas[index];
          });
          _atualizarRotaUsuario();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: 'Círio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: 'Trasladação',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.my_location),
            label: 'Ir ao início',
          ),
        ],
      ),

      body: FlutterMap(
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
              // Ponto final
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

              // Ponto inicial (igreja) — só nas rotas fixas
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
    );
  }
}