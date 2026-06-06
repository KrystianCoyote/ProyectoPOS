import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../main.dart';
import 'productos_inactivos_page.dart';
import 'venta_page.dart';
import 'admin_options_page.dart';
import 'login_page.dart';

class DashboardPage extends StatelessWidget {
  final Usuario usuario;

  const DashboardPage({super.key, required this.usuario});

  bool get esAdmin => usuario.rol.toLowerCase() == 'administrador';

  void _cerrarSesion(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (width >= 1100) {
      crossAxisCount = 4;
    } else if (width >= 800) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    final opciones = <_DashItem>[
      _DashItem(
        titulo: "Productos activos",
        icono: Icons.inventory_2_outlined,
        color: Colors.deepPurple.shade300,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ListaProductosPage()),
          );
        },
      ),
      _DashItem(
        titulo: "Productos inactivos",
        icono: Icons.archive_outlined,
        color: Colors.blueGrey.shade400,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductosInactivosPage()),
          );
        },
      ),
      _DashItem(
        titulo: "Ir a ventas",
        icono: Icons.shopping_cart_checkout,
        color: Colors.green.shade400,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VentaPage()),
          );
        },
      ),
    ];

    if (esAdmin) {
      opciones.add(
        _DashItem(
          titulo: "Panel de administrador",
          icono: Icons.admin_panel_settings,
          color: Colors.orange.shade400,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminOptionsPage()),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("POS - Dashboard (${usuario.nombre})"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          // 1.1 → cuadrados un poco más anchos que altos, más compactos
          childAspectRatio: 1.1,
          children: opciones
              .map(
                (item) => _DashCard(
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

class _DashItem {
  final String titulo;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  _DashItem({
    required this.titulo,
    required this.icono,
    required this.color,
    required this.onTap,
  });
}

class _DashCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final Color color;
  final VoidCallback onTap;

  const _DashCard({
    super.key,
    required this.icono,
    required this.titulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.12),
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
