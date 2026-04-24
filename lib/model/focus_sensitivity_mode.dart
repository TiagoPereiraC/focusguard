enum FocusSensitivityMode {
  low,
  balanced,
  high,
  extreme,
}

extension FocusSensitivityModeUi on FocusSensitivityMode {
  String get label {
    switch (this) {
      case FocusSensitivityMode.low:
        return 'Baja';
      case FocusSensitivityMode.balanced:
        return 'Equilibrada';
      case FocusSensitivityMode.high:
        return 'Alta';
      case FocusSensitivityMode.extreme:
        return 'Extrema';
    }
  }

  String get description {
    switch (this) {
      case FocusSensitivityMode.low:
        return 'Menos interrupciones por movimientos leves.';
      case FocusSensitivityMode.balanced:
        return 'Balance entre precision y rapidez de deteccion.';
      case FocusSensitivityMode.high:
        return 'Detecta giros con menos evidencia.';
      case FocusSensitivityMode.extreme:
        return 'Maxima sensibilidad ante cualquier giro.';
    }
  }
}