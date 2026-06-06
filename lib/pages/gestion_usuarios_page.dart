// lib/pages/gestion_usuarios_page.dart
import 'package:flutter/material.dart';

class GestionUsuariosPage extends StatelessWidget {
  const GestionUsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de usuarios'),
      ),
      body: const Center(
        child: Text(
          'Pantalla de gestión de usuarios (pendiente de implementar).',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
