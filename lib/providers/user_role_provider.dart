import 'package:flutter/material.dart';

/// Proveedor de estado para el rol del usuario y el modo de proyección.
///
/// Controla:
/// - [isDocente]: si el usuario actual es docente (habilita controles extra).
/// - [isProjectionMode]: si el modo proyección está activo (aumenta tamaños
///   de fuente y oculta controles de evaluación para presentar en clase).
class UserRoleProvider extends ChangeNotifier {
  bool _isDocente = false;
  bool _isProjectionMode = false;

  /// Indica si el usuario actual tiene rol de docente.
  bool get isDocente => _isDocente;

  /// Indica si el modo proyección está activo.
  bool get isProjectionMode => _isProjectionMode;

  /// Factor de escala de texto para modo proyección (1.0 normal, 1.4 proyección).
  double get textScaleFactor => _isProjectionMode ? 1.4 : 1.0;

  /// Alterna el rol del usuario entre alumno y docente.
  void toggleRole() {
    _isDocente = !_isDocente;
    // Si ya no es docente, desactivar modo proyección
    if (!_isDocente) {
      _isProjectionMode = false;
    }
    notifyListeners();
  }

  /// Establece el rol de docente directamente.
  void setDocente(bool value) {
    _isDocente = value;
    if (!_isDocente) {
      _isProjectionMode = false;
    }
    notifyListeners();
  }

  /// Alterna el modo proyección (solo disponible para docentes).
  void toggleProjectionMode() {
    if (_isDocente) {
      _isProjectionMode = !_isProjectionMode;
      notifyListeners();
    }
  }
}
