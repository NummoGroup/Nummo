import 'package:flutter/material.dart';
import 'package:nummo/core/theme/app_theme.dart';
import 'package:nummo/features/dashboard/menu_screens/profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  //bool _biometricEnabled = false;
  //bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: Theme.of(context).textTheme.titleLarge,
          ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _buildSectionTitle(context, 'Cuenta y Finanzas'),
          _buildSettingsCard(
            context,
            children: [
              ListTile(
                leading: Icon(Icons.person_outline, color: theme.colorScheme.primary),
                title: const Text('Editar Perfil'),
                subtitle: const Text('Nombre, correo y avatar'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                },
              ),
              const Divider(height: 1, indent: 56),
              /*ListTile(
                leading: Icon(Icons.account_balance_wallet_outlined, color: theme.colorScheme.primary),
                title: const Text('Mis Cuentas y Tarjetas'),
                subtitle: const Text('Gestionar métodos de pago y saldos iniciales'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: NAVEGACIÓN - Lleva a la pantalla de gestión de cuentas financieras
                },
              ),*/
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(Icons.monetization_on_outlined, color: theme.colorScheme.primary),
                title: const Text('Moneda Principal'),
                subtitle: const Text('ARS (\$)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: ACCIÓN - Abre un BottomSheet/Dialog para cambiar tipo de moneda
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          _buildSectionTitle(context, 'Preferencias'),
          _buildSettingsCard(
            context,
            children: [
              SwitchListTile(
                secondary: Icon(Icons.notifications_none, color: theme.colorScheme.primary),
                title: const Text('Notificaciones Diarias'),
                subtitle: const Text('Recordatorios de registro de gastos'),
                value: _notificationsEnabled,
                activeColor: theme.colorScheme.secondary,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const Divider(height: 1, indent: 56),
              /*SwitchListTile(
                secondary: Icon(Icons.fingerprint, color: theme.colorScheme.primary),
                title: const Text('Seguridad Biométrica'),
                subtitle: const Text('Desbloquear con huella o rostro'),
                value: _biometricEnabled,
                activeColor: theme.colorScheme.secondary,
                onChanged: (bool value) {
                  setState(() {
                    _biometricEnabled = value;
                  });
                },
              ),*/
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                secondary: Icon(Icons.dark_mode_outlined, color: theme.colorScheme.primary),
                title: const Text('Modo Oscuro'),
                subtitle: const Text('Forzar aspecto oscuro en la interfaz'),
                value: AppTheme.themeNotifier.value == ThemeMode.dark, 
                activeColor: theme.colorScheme.secondary,
                onChanged: (bool value) {
                  AppTheme.themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                  
                  setState(() {}); 
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          _buildSectionTitle(context, 'Datos'),
          _buildSettingsCard(
            context,
            children: [
              /*ListTile(
                leading: Icon(Icons.cloud_upload_outlined, color: theme.colorScheme.primary),
                title: const Text('Copia de Seguridad'),
                subtitle: const Text('Sincronizar tus datos financieros'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: ACCIÓN - Iniciar backup en la nube
                },
              ),*/
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Eliminar Datos', style: TextStyle(color: Colors.redAccent)),
                subtitle: const Text('Borrar todo el historial local'),
                onTap: () {
                  // TODO: ACCIÓN - Mostrar diálogo de confirmación crítica
                },
              ),
            ],
          ),

          const SizedBox(height: 32),
          Center(
            child: Text(
              'Nummo v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias, // Evita que los bordes del ListTile sobresalgan del Card
      child: Column(
        children: children,
      ),
    );
  }
}