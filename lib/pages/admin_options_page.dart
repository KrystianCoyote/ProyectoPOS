// lib/pages/admin_options_page.dart
import 'package:flutter/material.dart';

import 'corte_caja_page.dart';
import 'historial_ventas_page.dart';
import 'gestion_usuarios_page.dart';
import 'seleccionar_impresora_page.dart';

class AdminOptionsPage extends StatelessWidget {
  const AdminOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (width >= 1100) {
      crossAxisCount = 4;
    } else if (width >= 800) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2; // 👈 para teléfono, 2 columnas
    }

    final opciones = <_AdminItem>[
      _AdminItem(
        titulo: 'Gestión de usuarios',
        icono: Icons.group,
        color: Colors.deepPurple.shade300,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const GestionUsuariosPage(),
            ),
          );
        },
      ),
      _AdminItem(
        titulo: 'Historial de ventas',
        icono: Icons.history,
        color: Colors.blue.shade400,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HistorialVentasPage(),
            ),
          );
        },
      ),
      _AdminItem(
        titulo: 'Corte de caja',
        icono: Icons.receipt_long,
        color: Colors.green.shade400,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CorteCajaPage(),
            ),
          );
        },
      ),
    ];
    // en AdminOptionsPage, en la lista de opciones, añade algo tipo:
    _AdminItem(
      titulo: 'Configurar impresora',
      icono: Icons.print,
      color: Colors.brown.shade400,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SeleccionarImpresoraPage(),
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de administrador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: opciones
              .map(
                (item) => _AdminCard(
              icono: item.icono,
              titulo: item.titulo,
              color: item.color,
              onTap: item.onTap,
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}

class _AdminItem {
  final String titulo;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  _AdminItem({
    required this.titulo,
    required this.icono,
    required this.color,
    required this.onTap,
  });
}

class _AdminCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    super.key,
    required this.icono,
    required this.titulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
