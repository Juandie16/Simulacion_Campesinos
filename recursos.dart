class Recursos {
  int papas = 0;
  int yucaKg = 0;
  int zanahoriaKg = 0;
  int lechugaKg = 0;

  /// Producción basada en horas simuladas acumuladas (ejemplo de lógica).
  /// - papas: 1000 cada 120 horas
  /// - yuca: 1kg cada 150 horas
  /// - zanahoria: 1kg cada 20 horas
  /// - lechuga: 1kg cada 10 horas
  void producirSegunAcumulado(int horasAcumuladas) {
    // papas
    while (horasAcumuladas >= 120) {
      horasAcumuladas -= 120;
      papas += 1000;
    }
    // yuca
    while (horasAcumuladas >= 150) {
      horasAcumuladas -= 150;
      yucaKg += 1;
    }
    // zanahoria
    while (horasAcumuladas >= 20) {
      horasAcumuladas -= 20;
      zanahoriaKg += 1;
    }
    // lechuga
    while (horasAcumuladas >= 10) {
      horasAcumuladas -= 10;
      lechugaKg += 1;
    }
  }
}
