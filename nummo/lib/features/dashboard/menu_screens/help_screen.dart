import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda y Soporte'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // Banner de bienvenida superior para soporte premium
          Card(
            color: theme.colorScheme.primary,
            margin: const EdgeInsets.only(bottom: 24.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Cómo podemos ayudarte hoy?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Encontrá respuestas rápidas sobre Nummo o ponete en contacto con el equipo.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          _buildSectionTitle(context, 'Preguntas Frecuentes'),
          _buildHelpCard([
            _buildExpansionTile(
              context,
              title: '¿Cómo añado una nueva categoría de gastos?',
              content: 'Podés añadir o editar categorías directamente desde el formulario de nuevo gasto, o desde el menú de configuración de categorías.',
            ),
            const Divider(height: 1, indent: 16),
            _buildExpansionTile(
              context,
              title: '¿Qué significan las metas y las insignias?',
              content: 'Nummo usa gamificación para ayudarte a ahorrar. Al cumplir tus objetivos mensuales de ahorro, desbloqueás medallas que mejoran tu nivel en la app.',
            ),
            const Divider(height: 1, indent: 16),
            _buildExpansionTile(
              context,
              title: '¿Mis datos bancarios están seguros?',
              content: '¡Completamente! Nummo es una herramienta de registro manual offline y local, lo que significa que no nos conectamos a tus cuentas de banco reales ni guardamos información en servidores externos sin tu consentimiento.',
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Canales de Contacto'),
          _buildHelpCard([
            ListTile(
              leading: Icon(Icons.chat_bubble_outline, color: theme.colorScheme.secondary),
              title: const Text('Chat de Soporte en Vivo'),
              subtitle: const Text('Escribinos y te responderemos a la brevedad'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: NAVEGACIÓN - Abre pantalla de chat de soporte interno
              },
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: Icon(Icons.email_outlined, color: theme.colorScheme.secondary),
              title: const Text('Enviar un Correo Electrónico'),
              subtitle: const Text('soporte@nummo.com'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: ACCIÓN - Abre la app de correo externa predeterminada
              },
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: Icon(Icons.bug_report_outlined, color: theme.colorScheme.secondary),
              title: const Text('Reportar un Error (Bug)'),
              subtitle: const Text('Ayudanos a mejorar la app enviando capturas'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: NAVEGACIÓN - Lleva al formulario de reporte técnico de fallos
              },
            ),
          ]),

          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Legal'),
          _buildHelpCard([
            ListTile(
              leading: Icon(Icons.description_outlined, color: theme.colorScheme.primary.withOpacity(0.6)),
              title: const Text('Términos y Condiciones'),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () {
                // TODO: ACCIÓN - Abrir URL o pantalla de vista de texto legal
              },
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: theme.colorScheme.primary.withOpacity(0.6)),
              title: const Text('Política de Privacidad'),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () {
                // TODO: ACCIÓN - Abrir URL o pantalla de políticas de privacidad
              },
            ),
          ]),
          const SizedBox(height: 24),
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

  Widget _buildHelpCard(List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildExpansionTile(BuildContext context, {required String title, required String content}) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      iconColor: Theme.of(context).colorScheme.secondary,
      collapsedIconColor: Colors.black45,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      shape: const Border(), // Quita las líneas externas del ExpansionTile al expandirse
      collapsedShape: const Border(),
      children: [
        Text(
          content,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white70 
                : Colors.black,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}