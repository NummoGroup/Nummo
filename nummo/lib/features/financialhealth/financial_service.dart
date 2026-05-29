import 'package:http/http.dart' as http;
import 'dart:convert';
import 'financial_model.dart';

class FinancialHealthService {
  // Usar localhost para desarrollo en PC local
  static const String _apiBaseUrl = 'http://localhost:8000';
  static const String _predictEndpoint = '/predecir';

  /// Calcula el porcentaje de salud financiera
  ///
  /// Parámetros:
  /// - [ingresos]: Total de ingresos del usuario
  /// - [gastos]: Total de gastos del usuario
  /// - [ahorro]: Total ahorrado del usuario
  /// - [comprasImpulsivas]: Escala de 1 a 10 de compras impulsivas (1=nada, 10=máximo)
  Future<FinancialHealth> calculateFinancialHealth({
    required double ingresos,
    required double gastos,
    required double ahorro,
    required double comprasImpulsivas,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl$_predictEndpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'ingresos': ingresos,
              'gastos': gastos,
              'ahorro': ahorro,
              'compras_impulsivas': comprasImpulsivas,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('La solicitud a la API tardó demasiado tiempo');
            },
          );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return FinancialHealth.fromJson(jsonData);
      } else {
        throw Exception(
          'Error de la API: ${response.statusCode} - ${response.body}',
        );
      }
    } on Exception catch (e) {
      throw Exception('Error al conectar con la API: $e');
    }
  }
}
