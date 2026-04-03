import 'package:flutter/material.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.church, color: Colors.white, size: 80),
              const SizedBox(height: 16),
              const Text(
                'Círio de Nazaré',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Belém do Pará',
                style: TextStyle(
                  color: Colors.blue[200],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 60),
              const Text(
                'Selecione uma rota para começar',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              _botaoRota(
                context,
                icon: Icons.directions_walk,
                label: 'Rota do Círio',
                descricao: 'Catedral da Sé → Basílica de Nazaré',
                rota: 'cirio',
              ),
              const SizedBox(height: 16),
              _botaoRota(
                context,
                icon: Icons.directions_walk,
                label: 'Rota da Trasladação',
                descricao: 'Basílica de Nazaré → Catedral da Sé',
                rota: 'trasladacao',
              ),
              const SizedBox(height: 16),
              _botaoRota(
                context,
                icon: Icons.my_location,
                label: 'Ir ao ponto inicial',
                descricao: 'Sua localização → Basílica de Nazaré',
                rota: 'usuario',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botaoRota(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String descricao,
    required String rota,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue[900],
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MapScreen(rotaInicial: rota),
            ),
          );
        },
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  descricao,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}