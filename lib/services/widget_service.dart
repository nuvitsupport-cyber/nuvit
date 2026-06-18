import 'package:home_widget/home_widget.dart';

class WidgetService {

  // =========================================================
  // UPDATE HOME WIDGET
  // =========================================================

  static Future<void> updateEnergyWidget({
    required int batteryCapacity,
    required String autonomy,
    required String weather,
    required int readinessScore,
  }) async {

    // Battery
    await HomeWidget.saveWidgetData<String>(
      'battery',
      '$batteryCapacity Wh',
    );

    // Autonomy
    await HomeWidget.saveWidgetData<String>(
      'autonomy',
      autonomy,
    );

    // Weather
    await HomeWidget.saveWidgetData<String>(
      'weather',
      weather,
    );

    // Readiness
    await HomeWidget.saveWidgetData<String>(
      'readiness',
      '$readinessScore%',
    );

    // Update widget
    await HomeWidget.updateWidget(
      name: 'NuvitWidgetProvider',
      iOSName: 'NuvitWidget',
    );
  }
}