import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendContactMessage() {
    if (_formKey.currentState!.validate()) {
      final message = _messageController.text;

      // TODO: Integrar con paquete de email (ej. url_launcher) o servicio de backend.
      // Por ahora, simulamos el envío exitoso.

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '¡Mensaje enviado con éxito a Nummo! Gracias por tu contacto.',
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ayuda y Soporte',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            // Banner de bienvenida superior
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
                      'Encontrá respuestas rápidas sobre Nummo o dejanos tu mensaje directo al equipo.',
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
                content:
                    'Podés añadir o editar categorías directamente desde el formulario de nuevo gasto, o desde el menú de configuración de categorías.',
              ),
              const Divider(height: 1, indent: 16),
              _buildExpansionTile(
                context,
                title: '¿Qué significan las metas y las insignias?',
                content:
                    'Nummo usa gamificación para ayudarte a ahorrar. Al cumplir tus objetivos mensuales de ahorro, desbloqueás medallas que mejoran tu nivel en la app.',
              ),
              const Divider(height: 1, indent: 16),
              _buildExpansionTile(
                context,
                title: '¿Mis datos bancarios están seguros?',
                content:
                    '¡Completamente! Nummo es una herramienta de registro manual offline y local, lo que significa que no nos conectamos a tus cuentas de banco reales ni guardamos información en servidores externos sin tu consentimiento.',
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Dejanos tus comentarios o dudas'),

            // Sección del cuadro de texto unificado
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Escribí tu pregunta, sugerencia, comentario o queja acá abajo. Te responderemos al mail de tu cuenta de Nummo.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      minLines: 3,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText:
                            'Ej: Hola equipo de Nummo, encontré un problema en la pantalla de metas...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, escribe un mensaje antes de enviar.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _sendContactMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text(
                        'Enviar mensaje',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Legal'),
            _buildHelpCard([
              ListTile(
                leading: Icon(
                  Icons.description_outlined,
                  color: theme.colorScheme.primary.withOpacity(0.6),
                ),
                title: const Text('Términos y Condiciones'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () {
                  //link
                },
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(
                  Icons.privacy_tip_outlined,
                  color: theme.colorScheme.primary.withOpacity(0.6),
                ),
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
      child: Column(children: children),
    );
  }

  Widget _buildExpansionTile(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      iconColor: Theme.of(context).colorScheme.secondary,
      collapsedIconColor: Colors.black45,
      childrenPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      shape: const Border(),
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
