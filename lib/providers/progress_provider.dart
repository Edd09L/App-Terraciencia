import 'package:flutter/material.dart';
import '../data/topics_database.dart';

/// Proveedor de estado global para administrar el progreso y las calificaciones de los temas.
class ProgressProvider extends ChangeNotifier {
  // Mapa de calificaciones por código de tema (0.0 a 100.0)
  final Map<String, double> _topicScores = {};

  ProgressProvider() {
    // Inicializar calificaciones
    for (var topic in allTopics) {
      _topicScores[topic.id] = 0.0;
    }
  }

  /// Obtiene la calificación de un tema específico.
  double getScore(String code) {
    return _topicScores[code] ?? 0.0;
  }

  /// Determina si un tema/estampita está desbloqueado (calificación >= 90).
  bool isUnlocked(String code) {
    return getScore(code) >= 90.0;
  }

  /// Actualiza la calificación de un tema y notifica a los escuchas.
  void setScore(String code, double score) {
    _topicScores[code] = score.clamp(0.0, 100.0);
    notifyListeners();
  }

  /// Desbloquea todos los temas (calificaciones a 100.0) para fines de prueba o premio final.
  void unlockAll() {
    for (var code in _topicScores.keys) {
      _topicScores[code] = 100.0;
    }
    notifyListeners();
  }

  /// Restablece todas las calificaciones a sus valores predeterminados.
  void resetProgress() {
    for (var code in _topicScores.keys) {
      _topicScores[code] = 0.0;
    }
    notifyListeners();
  }
}
