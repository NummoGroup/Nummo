import 'package:flutter/material.dart';
import 'package:nummo/features/auth/auth_screens/welcome_screen.dart';
import 'package:nummo/features/dashboard/menu_screens/help_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- HEADER DEL PERFIL (Limpio y directo) ---
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black12,
              backgroundImage: NetworkImage(
                'https://ui-avatars.com/api/?name=Usuario+Nummo&background=1A237E&color=fff&size=128',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nombre Usuario',
              style: textTheme.headlineMedium?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            const SizedBox(height: 40),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Configuración General',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildProfileOption(
              context,
              icon: Icons.account_circle_outlined,
              title: 'Datos de la cuenta',
              onTap: () {
                //to-do: edit profile
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.notifications_none,
              title: 'Notificaciones y Recordatorios',
              onTap: () {},
            ),
            _buildProfileOption(
              context,
              icon: Icons.security,
              title: 'Privacidad y Seguridad',
              onTap: () {},
            ),
            _buildProfileOption(
              context,
              icon: Icons.help_outline,
              title: 'Centro de Ayuda',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpScreen()),
                );
              },
            ),

            const SizedBox(height: 32),

            // --- BOTÓN DE CERRAR SESIÓN ---
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                  ); // Simula el cierre de sesión volviendo a la pantalla anterior (reemplazar por  función real de logout)
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.redAccent),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  foregroundColor: Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // El widget auxiliar se mantiene para conservar la estética de las tarjetas
  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black38),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            16,
          ), // Bordes redondeados heredados del tema
        ),
      ),
    );
  }
}
